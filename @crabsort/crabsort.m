%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
%
% crabsort.m
% Allows you to view, manipulate and sort spikes from experiments conducted by Kontroller. specifically meant to sort spikes from Drosophila ORNs
% crabsort was written by Srinivas Gorur-Shandilya at 10:20 , 09 April 2014. Contact me at http://srinivas.gs/contact/
% part of the crabsort package
% https://github.com/sg-s/crabsort
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.

classdef crabsort < handle & matlab.mixin.CustomDisplay

    properties
        % meta
       
        pref % stores the preferences

        % file handling 
        file_name
        path_name

        % data handling
        output_channel_names

        R  % this holds the dimensionality reduced data

        % debug
        verbosity = 10;

        channel_names = {'???','dgn','lgn','lpn','lvn','mgn','pdn','temperature','pyn'};

        % this structure maps nerves onto the neurons that 
        % are expected to be seen on them 
        nerve2neuron

    end % end properties 

    properties (SetAccess = protected)

        % UI
        handles % a structure that handles everything else

        metadata

        % data 
        n_channels
        raw_data
        data_channel_names
        time
        dt
        channel_ylims

        spikes
        putative_spikes

        installed_plugins

        channel_to_work_with

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
            self.nerve2neuron.pyn = 'PY';
            self.nerve2neuron.lvn = {'LP','PD','PY'};

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

            if ~isempty(self.channel_ylims) && ~isempty(self.channel_ylims(value)) && self.channel_ylims(value) > 0
                % we have a custom y-lim for this axes --
                % use it
                yl = self.channel_ylims(value);
                self.handles.ax(value).YLim = [-yl yl];
            end

            if isfield(self.handles,'ax')
                for i = 1:length(self.handles.ax)
                    self.handles.ax(i).YColor = 'k';
                end


                self.handles.ax(value).YColor = 'r';
            end

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

            sdp = self.handles.spike_detection_panel.Children;
            dmp = self.handles.dim_red_panel.Children;
            cp = self.handles.cluster_panel.Children;

            for i = 1:length(sdp)
                sdp(i).Enable = 'on';
            end
            for i = 1:length(dmp)
                dmp(i).Enable = 'on';
            end
            for i = 1:length(cp)
                cp(i).Enable = 'on';
            end



            % switch this_channel_stage
            % case 0
            %     % enable spike detection, turn everything else off
            %     for i = 1:length(sdp)
            %         sdp(i).Enable = 'on';
            %     end
            %     for i = 1:length(dmp)
            %         dmp(i).Enable = 'off';
            %     end
            %     for i = 1:length(cp)
            %         cp(i).Enable = 'off';
            %     end

            % case 1
            %     % enable dim red, + spike detection, turn everyhting else off
            %     for i = 1:length(sdp)
            %         sdp(i).Enable = 'on';
            %     end
            %     for i = 1:length(dmp)
            %         dmp(i).Enable = 'on';
            %     end
            %     for i = 1:length(cp)
            %         cp(i).Enable = 'off';
            %     end
            % case 2

            %     disp('only enable clustering ')
            %     for i = 1:length(sdp)
            %         sdp(i).Enable = 'off';
            %     end
            %     for i = 1:length(dmp)
            %         dmp(i).Enable = 'off';
            %     end
            %     for i = 1:length(cp)
            %         cp(i).Enable = 'on';
            %     end
            % case 3

            %     disp('disable everything ')
            %     for i = 1:length(sdp)
            %         sdp(i).Enable = 'off';
            %     end
            %     for i = 1:length(dmp)
            %         dmp(i).Enable = 'off';
            %     end
            %     for i = 1:length(cp)
            %         cp(i).Enable = 'off';
            %     end
            % end
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

                    set(self.handles.found_spikes(idx),'Marker','o','Color',self.pref.putative_spike_colour,'LineStyle','none')

                    self.handles.method_control.Enable = 'on';
                catch
                end

            end
        end % end set loc


    end % end general methods

end % end classdef
