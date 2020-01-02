%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% saves data in a .crabsort file 

function saveData(self)


% early escape
if isempty(self.time) 
    return
end

% saveData saves data to two different locations:
% local data that pertains to this file in a .crabsort file
% and common data that pertains to all files in this folder
% to a file called crabsort.common in that folder 

filelib.mkdir(pathlib.join(getpref('crabsort','store_spikes_here'),pathlib.lowestFolder(self.path_name)))

file_name = pathlib.join(getpref('crabsort','store_spikes_here'),pathlib.lowestFolder(self.path_name),[self.file_name '.crabsort']);
common_name = pathlib.join(getpref('crabsort','store_spikes_here'),pathlib.lowestFolder(self.path_name),'crabsort.common');


% generate ignore_section from the mask
global_mask = 1-max(self.mask,[],2);
if min(global_mask) == 1
	% we're ignoring the whole file
	self.ignore_section.ons = 1;
	self.ignore_section.offs = length(global_mask);
else
	offs = find(diff(global_mask)<0);
	ons = find(diff(global_mask)>0);
	if ~isempty(ons) && ~isempty(offs)
		if offs(1) < ons(1)
			ons = [1; ons];
		end
	end
	if length(offs) < length(ons)
		offs = [offs; self.raw_data_size(1)];
	end
	self.ignore_section.ons = ons;
	self.ignore_section.offs = offs;
end



crabsort_obj = self;
save(file_name,'crabsort_obj','-v7.3')




% now save the common items
common = self.common;
save(common_name,'common','-v7.3')

