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
        sampling_rate

        % current voltage trace
        R  % this holds the dimensionality reduced data


        V_snippets % matrix of snippets around spike peaks
        loc  % holds current spike times


        use_this_fragment
        A_amplitude
        B_amplitude


        this_trial
        this_paradigm

        % plugins
        

        % some control variables
        filter_trace = true;

        % UI
        handles % a structure that handles everything else

        % debug
        verbosity = 10;

        % auto-update
        req_update
        req_toolboxes

        channel_names = {'???','lpn','lvn','pdn','mgn','temperature','pyn'};

    end % end properties 

    properties (SetAccess = protected)

        metadata

        version_name = 'crabsort';
        build_number = 'automatically-generated';

        n_channels
        raw_data

        data_channel_names

        time

        spikes

        installed_plugins

        channel_to_work_with
    end

    methods (Access = protected)
        function displayScalarObject(s)
            disp('crabsort')
            s.build_number
        end % end displayScalarObject
    end % end protected methods


    methods
        function s = crabsort()

            % check for dependencies
            % toolboxes = {'srinivas.gs_mtools','crabsort','bhtsne'};
            % build_numbers = checkDeps(toolboxes);
            % s.version_name = strcat('crabsort for Kontroller (Build-',oval(build_numbers(2)),')'); 

            if verLessThan('matlab', '8.0.1')
                error('Need MATLAB 2014b or better to run')
            end

            % check the signal processing toolbox version
            if verLessThan('signal','6.22')
                error('Need Signal Processing toolbox version 6.22 or higher')
            end

            % add src folder to path
            % addpath([fileparts(fileparts(which(mfilename))) oss 'src'])


            % load preferences
            s.pref = readPref(fileparts(fileparts(which(mfilename))));

            % figure out what plugins are installed, and link them
            s = plugins(s);

            % get the version name and number
            s.build_number = ['v' strtrim(fileread([fileparts(fileparts(which(mfilename))) oss 'build_number']))];
            s.version_name = ['crabsort (' s.build_number ')'];

            % make gui
            s.makeGUI;

            % configure somethings for auto-update
            s.req_toolboxes = {'srinivas.gs_mtools','bhtsne','crabsort'};
            [~,s.req_update] = checkDeps(s.req_toolboxes);

            if ~nargout
                cprintf('red','[WARN] ')
                cprintf('text','crabsort called without assigning to a object. crabsort will create an object called "s" in the workspace\n')
                assignin('base','s',s);
            end

        end

        function self = set.channel_to_work_with(self,value)
            self.channel_to_work_with = value;

            for i = 1:length(self.handles.ax)
                self.handles.ax(i).YColor = 'k';
            end

            self.handles.ax(value).YColor = 'r';

        end

        function self = set.raw_data(self,value)
            self.raw_data = value;
            if isfield(self.handles,'data') && ~isempty(self.handles.data)
                for i = 1:size(self.raw_data,2)
                    self.handles.data(i).YData = self.raw_data(:,i);
                end
            end
        end


        function self = set.loc(self,value)
            

            self.loc = value;
            idx = self.channel_to_work_with;
            if isempty(value)
                set(self.handles.found_spikes(idx),'XData',NaN,'YData',NaN);
                % set(self.handles.ax(idx)_A_spikes,'XData',NaN,'YData',NaN);
                % set(self.handles.ax(idx)_B_spikes,'XData',NaN,'YData',NaN);
                return
            else
                
                set(self.handles.found_spikes(idx),'XData',self.time(self.loc),'YData',self.raw_data(self.loc,idx));
                set(self.handles.found_spikes(idx),'Marker','o','Color',self.pref.putative_spike_colour,'LineStyle','none')

                % % also update the YLim intelligently
                % if s.filter_trace
                %     set(s.handles.ax1,'YLim',[-1.1*max(abs(s.filtered_voltage(s.loc))) 1.1*max(abs(s.filtered_voltage(s.loc)))])
                % else
                % end
            end
        end % end set loc

        function s = set.filter_trace(s,value)
            s.filter_trace = value;
            s.plotResp;
        end % end set filter_trace


        function delete(s)
            if s.verbosity > 5
                cprintf('green','[INFO] ')
                cprintf('text','crabsort shutting down \n')
            end

            % save everything
            s.saveData;

            % try to shut down the GUI
            try
                delete(s.handles.main_fig)
            catch
            end

            % % trigger an auto-update if needed
            % for i = 1:length(s.req_toolboxes)
            %     if s.req_update(i) 
            %         install('-f',['sg-s/' s.req_toolboxes{i}])
            %     end
            % end

            delete(s)
        end

    end % end general methods

end % end classdef
