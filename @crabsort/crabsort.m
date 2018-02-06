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
        channel_names = sort({'???','dgn','gpn','lgn','lpn','lvn','mgn','mvn','pdn','temperature','pyn','PD','AB','LPG','LP','IC','LG','MG','GM','PY','VD','Int1','DG','AM'});

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


            self.nerve2neuron.lpn = 'LP';
            self.nerve2neuron.pdn = 'PD';
            self.nerve2neuron.pyn = {'PY', 'LPG'};
            self.nerve2neuron.lvn = {'LP','PD','PY'};
            self.nerve2neuron.lgn = {'LG','MG'};
            self.nerve2neuron.mvn = {'VD','IC','PY'};
            self.nerve2neuron.dgn = {'DG','MG','AGR'};

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

            % figure out what plugins are installed, and link them
            self = self.plugins;

            % get the version name and number
            self.build_number = ['v' strtrim(fileread([fileparts(fileparts(which(mfilename))) oss 'build_number']))];
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


        function self = set.channel_stage(self,value)
            self.channel_stage = value;

            if isempty(self.channel_to_work_with)
                return
            end


            this_channel_stage = self.channel_stage(self.channel_to_work_with);

            if isempty(self.handles)
                return
            end

            if ~isfield(self.handles,'spike_detection_panel')
                return
            end

        end


        function self = set.putative_spikes(self,value)
            

            self.putative_spikes = logical(value);
            idx = self.channel_to_work_with;
            if isempty(value)
                try
                    set(self.handles.found_spikes(idx),'XData',NaN,'YData',NaN);
                catch
                end
                return
            else

                if isempty(self.handles)
                    return
                end

                if ~isfield(self.handles,'found_spikes')
                    return
                end


                try
                    set(self.handles.found_spikes(idx),'XData',self.time(self.putative_spikes(:,idx)),'YData',self.raw_data(self.putative_spikes(:,idx),idx));
                    set(self.handles.found_spikes(idx),'Marker','o','Color',self.pref.putative_spike_colour,'LineStyle','none');
                    self.handles.method_control.Enable = 'on';
                catch
                end

            end
        end % end set loc


    end % end general methods

    methods (Static)
        [accuracy, nsteps] = parseTFOutput(output_string);
    end % end static methods

end % end classdef
