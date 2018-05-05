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

classdef crabsort < handle & matlab.mixin.CustomDisplay

    properties
       
        pref % stores the preferences

        % file handling 
        file_name
        path_name

        % debug
        verbosity = 0;

        channel_to_work_with

    end % end properties 

    properties (SetAccess = protected)

        % these channel names exist in the raw data
        builtin_channel_names

        R  % this holds the dimensionality reduced data

        % this is the list of channel names that you can choose from
        channel_names

        % this structure maps nerves onto the neurons that 
        % are expected to be seen on them 
        nerve2neuron


        % for use by automate()
        automatic = false; % when true, crabsort is running automatically 
        current_operation

        % UI
        handles % a structure that handles everything else

        metadata

        % data 
        n_channels
        raw_data
        time

        % for reasons revolving around the crappiness of the ABF 
        % file format, dt will be stored after being rounded off to
        % the nearest microsecond
        dt
        channel_ylims

        spikes
        putative_spikes

        installed_plugins

        % this keeps track of which stage each channel is in 
        % in the data analysis pipeline
        % 
        % 0 == raw (need to find spikes)
        % 1 == spikes found (need to reduce dimensions)
        % 2 == dimensions reduced (need to cluster)
        % 3 == done (spikes assigned to neurons)
        channel_stage

        version_name = 'crabsort';
        build_number = 'automatically-generated';


        % this is passed to the dimensional reduction callback
        % in general, this is MxN elements long, where N is
        % the number of putative spikes, and M is the dimension
        % we are operating in (which depends on what options are
        % selected for spike shape, timing, etc.)
        data_to_reduce

        % common data to all files in this folder
        common

        % this propoerty mirrors the checked state of 
        % the "watch me" menu item
        watch_me = false;

        % ignores this section
        ignore_section

    end

    properties (Access = protected)

        % auto-update
        req_update
        req_toolboxes = {'srinivas.gs_mtools','crabsort','puppeteer'};



    end % end protected props


    methods
        function self = crabsort(make_gui)

            if nargin == 0 
                make_gui = true;
            end

            % check for dependencies
            self.version_name = 'crabsort';

            if make_gui

                if verLessThan('matlab', '8.0.1')
                    error('Need MATLAB 2014b or better to run')
                end

                % check the signal processing toolbox version
                if verLessThan('signal','6.22')
                    error('Need Signal Processing toolbox version 6.22 or higher')
                end
            end

            % load preferences
            self.pref = readPref(fileparts(fileparts(which(mfilename))));

            % for backward compatibility, convert some things
            % into base props
            self.nerve2neuron = self.pref.nerve2neuron;
            self.channel_names = self.pref.channel_names;
            if ~any(strcmp(self.channel_names,'???'))
                self.channel_names = ['???' self.channel_names];
            end

            % figure out what plugins are installed, and link them
            self = self.plugins;

            % get the version name and number
            self.build_number = ['v' strtrim(fileread([fileparts(fileparts(which(mfilename))) filesep 'build_number']))];
            self.version_name = ['crabsort (' self.build_number ')'];
            
            if make_gui 
                self.makeGUI;
            end

            if ~nargout
                cprintf('red','[WARN] ')
                cprintf('text','crabsort called without assigning to a object. crabsort will create an object called "C" in the workspace\n')
                assignin('base','C',self);
            end

        end

        function self = set.channel_to_work_with(self,value)
            self.channel_to_work_with = value;

            if isempty(value)
                return
            end

            self.updateControlsOnChannelChange;

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
            end


            this_channel_stage = self.channel_stage(self.channel_to_work_with);

            if isempty(self.handles)
                return
            end

            switch this_channel_stage
            case 0
                if length(self.common.data_channel_names) < self.channel_to_work_with || strcmp(self.common.data_channel_names{self.channel_to_work_with},'???') || isempty(self.common.data_channel_names{self.channel_to_work_with})
                    % channel name unset
                    disable(self.handles.spike_detection_panel)
                else
                    enable(self.handles.spike_detection_panel)
                end
                
                disable(self.handles.dim_red_panel)
                disable(self.handles.cluster_panel)
                disable(self.handles.manual_panel)
            case 1
                enable(self.handles.spike_detection_panel)
                enable(self.handles.dim_red_panel)
                disable(self.handles.cluster_panel)
                disable(self.handles.manual_panel)
            case 2
                enable(self.handles.spike_detection_panel)
                enable(self.handles.dim_red_panel)
                enable(self.handles.cluster_panel)
                disable(self.handles.manual_panel)
            case 3
                disable(self.handles.spike_detection_panel)
                enable(self.handles.dim_red_panel)
                enable(self.handles.cluster_panel)
                enable(self.handles.manual_panel)
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
                catch
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


    end % end general methods

    methods (Static)
        [accuracy, nsteps] = parseTFOutput(output_string);
    end % end static methods

end % end classdef
