%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
%
% crabsort.m
% https://github.com/sg-s/crabsort
% Srinivas Gorur-Shandilya

classdef crabsort < handle & matlab.mixin.CustomDisplay & UpdateableHandle

    properties


        % spike detection parameters
        sdp (1,1) crabsort.spikeDetectionParameters = crabsort.spikeDetectionParameters.default()


        % holds spiketimes of all neurons on all nerves
        spikes


    end % end properties 


    properties (Transient = true)

        % file handling 
        file_name
        path_name

        R  % this holds the dimensionality reduced data

        channel_to_work_with double

        pref struct % stores the preferences

        % debug
        verbosity (1,1) double = 0;

        % common data to all files in this folder
        common 

        debug_mode (1,1) logical = false;

        PostPredictAction crabsort.postPredictAction

        futz_factor double = ones(100,1)*.85

    end



    properties (SetAccess = protected, Transient = true)

        % UI
        handles % a structure that handles everything else

        raw_data

        % this structure maps nerves onto the neurons that 
        % are expected to be seen on them 
        nerve2neuron (1,1) struct


        putative_spikes

        installed_plugins

        version_name  char = ['crabsort ' crabsort.version()]

        % this is the list of channel names that you can choose from
        channel_names

        % this is passed to the dimensional reduction callback
        % in general, this is MxN elements long, where N is
        % the number of putative spikes, and M is the dimension
        % we are operating in (which depends on what options are
        % selected for spike shape, timing, etc.)
        data_to_reduce

        time

        timer_handle (1,1) timer

         % parallel workers
        futures parallel.FevalFuture

        auto_predict (1,1) logical = true;

        automate_action (1,1) crabsort.automateAction = crabsort.automateAction.none

        mask

        ExtremumValues = NaN(100,1);


    end

    properties (SetAccess = protected)

        % these channel names exist in the raw data
        builtin_channel_names cell

        
        metadata

        % data 
        n_channels
        
        
        raw_data_size

        % for reasons revolving around the crappiness of the ABF 
        % file format, dt will be stored after being rounded off to
        % the nearest microsecond
        dt  double
        channel_ylims

        

        

        % this keeps track of which stage each channel is in 
        % in the data analysis pipeline
        % 
        % 0 == raw (need to find spikes)
        % 1 == spikes found (need to reduce dimensions)
        % 2 == dimensions reduced (need to cluster)
        % 3 == done (spikes assigned to neurons)
        channel_stage double


        % ignores this section
        ignore_section




    end

    properties (Access = protected, Transient = true)


        CurrentlyTraining

        NumWorkers = 0;

    end % end protected props


    methods

        function self = crabsort(make_gui, get_plugins)

            if nargin == 0 
                make_gui = true;
                get_plugins = true;
            elseif nargin == 1
                get_plugins = true;
            end


            % figure out where to stash spikes
            try
                ssh = getpref('crabsort','store_spikes_here');
            catch
                error(['You have not configured where to store spikes. Use setpref(' char(39) 'crabsort' char(39) ',' char(39) 'store_spikes_here' char(39) ',' char(39) 'some_place' char(39) ')'])
            end


            % check for dependencies

            if verLessThan('matlab', '8.0.1')
                error('Need MATLAB 2014b or better to run')
            end

            % check the signal processing toolbox version
            if verLessThan('signal','6.22')
                error('Need Signal Processing toolbox version 6.22 or higher')
            end

            % check if Neural network exists
            v = ver;
            nn_toolbox = any(~cellfun(@isempty, cellfun(@(x) strfind(x, 'Neural Network'), {v.Name},'UniformOutput', false)));
            dl_toolbox = any(~cellfun(@isempty, cellfun(@(x) strfind(x, 'Deep Learning'), {v.Name},'UniformOutput', false)));

            assert(nn_toolbox | dl_toolbox, 'Neural network toolbox not installed!');

            pc_toolbox = any(~cellfun(@isempty, cellfun(@(x) strfind(x, 'Parallel Computing'), {v.Name},'UniformOutput', false)));
            assert(pc_toolbox, 'Parallel computing toolbox not installed!')

            % load preferences
            try
                self.pref = corelib.readPref(fileparts(fileparts(which(mfilename))));
            catch
            end


            % for backward compatibility, convert some things
            % into base props
            self.nerve2neuron = self.pref.nerve2neuron;
            self.channel_names = self.pref.channel_names;
            if ~any(strcmp(self.channel_names,'???'))
                self.channel_names = ['???' self.channel_names];
            end

            % figure out what plugins are installed, and link them
            if get_plugins
                self.installed_plugins = crabsort.plugins();
            end

            
            if make_gui 


                % destroy old timers
                t = timerfindall;
                for i = 1:length(t)
                    if isempty(t(i).TimerFcn)
                        stop(t(i));
                        delete(t(i));
                        continue
                    end

                    if any(strfind(func2str(t(i).TimerFcn),'NNtimer'))
                        stop(t(i));
                        delete(t(i));
                    end
                end

                self.makeGUI;



            end

            if ~nargout
                corelib.cprintf('red','[WARN] ')
                corelib.cprintf('text','crabsort called without assigning to a object. crabsort will create an object called "C" in the workspace\n')
                assignin('base','C',self);
            end

        end

        function self = set.channel_to_work_with(self,value)
            self.channel_to_work_with = value;

        
            self.updateControlsOnChannelChange;

            if isempty(value)
                return
            end

            % force a channel_stage update
            self.channel_stage = self.channel_stage;


        end

        function self = set.path_name(self,value)
            if isempty(value)
                self.path_name = value;
                return
            end
            assert(exist(value,'dir') == 7,'path_name has to be directory')
            if ~strcmp(value(end),filesep)
                value = [value filesep];
            end
            self.path_name = value;
        end



        function self = set.channel_stage(self,value)
            self.channel_stage = value;

            if isempty(self.channel_to_work_with)
                return
            else
                channel = self.channel_to_work_with;
            end

            if isempty(self.handles)
                return
            end

            this_channel_stage = self.channel_stage(channel);

            switch this_channel_stage
            case 0
                % new channel. show spike detection panel
                % if it is named. 
                if isempty(self.common.data_channel_names{channel})
                    % channel name unset
                    uxlib.disable(self.handles.spike_detection_panel)
                else
                    uxlib.enable(self.handles.spike_detection_panel)
                end
                
                % hide other panels
                uxlib.hide(self.handles.dim_red_panel)
                uxlib.hide(self.handles.cluster_panel)
                uxlib.hide(self.handles.manual_panel)
                uxlib.enable(self.handles.mask_panel)

            case 1
                % spikes detected.
                uxlib.enable(self.handles.spike_detection_panel)
                uxlib.enable(self.handles.dim_red_panel)
                uxlib.hide(self.handles.cluster_panel)
            case 2
                % dimensions reduced (need to cluster)
                uxlib.disable(self.handles.spike_detection_panel)
                uxlib.disable(self.handles.dim_red_panel)
                uxlib.enable(self.handles.cluster_panel)
                uxlib.show(self.handles.cluster_panel)
                uxlib.enable(self.handles.cluster_panel)
            case 3
                % all done
                uxlib.disable(self.handles.spike_detection_panel)
                uxlib.enable(self.handles.dim_red_panel)
                uxlib.enable(self.handles.cluster_panel)
                uxlib.enable(self.handles.manual_panel)
                uxlib.show(self.handles.manual_panel)
            otherwise
                % WTF? ignore this and hope for the best
            end

        end


        function self = set.putative_spikes(self,value)
            

            self.putative_spikes = logical(value);
            idx = self.channel_to_work_with;
            if isempty(value)
                try
                    set(self.handles.ax.found_spikes(idx),'XData',NaN,'YData',NaN);
                catch err
                    % for ei = 1:length(err)
                    %     err.stack(ei)
                    % end
                end
                return
            else

                if isempty(self.handles)
                    return
                end

                if ~isfield(self.handles,'ax')
                    return
                end

                if ~isfield(self.handles.ax,'found_spikes')
                    return
                end



                set(self.handles.ax.found_spikes(idx),'XData',self.time(self.putative_spikes(:,idx)),'YData',self.raw_data(self.putative_spikes(:,idx),idx));
                
                self.handles.method_control.Enable = 'on';

         

            end
        end % end set loc


        function self = set.auto_predict(self,value)
            self.auto_predict = value;
            d = dbstack;
            if any(strcmp({d.name},'NNupdateAutoPredict'))
                return
            end
            if isempty(self.handles)
                return
            end
            if value
                self.handles.auto_predict_handle.Checked = 'on';
            else
                self.handles.auto_predict_handle.Checked = 'off';
            end
        end


    end % end general methods


    methods (Static)

        NNtrainOnParallelWorker(NNdata,checkpoint_path)
        NNshowResult(info)
        layers = NNmake(input_size, n_classes)
        [passed,total] = run_all_tests()
        update()
        uninstall()

    end % static methods


end % end classdef
