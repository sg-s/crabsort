%                 _                    _   
%   ___ _ __ __ _| |__  ___  ___  _ __| |_ 
%  / __| '__/ _` | '_ \/ __|/ _ \| '__| __|
% | (__| | | (_| | |_) \__ \ (_) | |  | |_ 
%  \___|_|  \__,_|_.__/|___/\___/|_|   \__|
%
% checks all ABF files to make sure they 
% have the same number of channels, and 
% that all channels have the same name, etc. 

function checkABFFiles(self)

d = dbstack;
if self.verbosity > 3
	disp(['[' mfilename '] called by ' d(2).name])
end


% get all files 
machineF='ieee-le';
fid = 0;

try

	% get all ABF files in current folder
	all_files = dir([self.path_name '*.abf']);

	channel_names = readABFChannelNames(all_files(1).name);
	if iscell(channel_names)
		hash = GetMD5([channel_names{:}]);
	else
		hash = GetMD5(channel_names);
	end

	for i = 2:length(all_files)
		this_channel_names = readABFChannelNames(all_files(i).name);

		disp(['Checking: ' all_files(i).name])

		assert(length(this_channel_names) == length(channel_names),'At least one file in your folder has an ABF structure that is different from the rest. ');

		if iscell(this_channel_names)
			assert(strcmp(GetMD5([channel_names{:}]),hash),'At least one file in your folder has an ABF structure that is different from the rest. ')
		else
			assert(strcmp(GetMD5(this_channel_names),hash),'At least one file in your folder has an ABF structure that is different from the rest. ')
		end
	end
catch err
	errordlg(err.message,'Your ABF files are inconsistent')
	keyboard
	error(err.message)
end


function channel_names = readABFChannelNames(file_name)

	% figure out version

	% get channel names

	[fid, messg] = fopen(pathlib.join(self.path_name,file_name),'r+',machineF);
	if fid == -1
		error(messg);
	end

	[fFileSignature,n] = fread(fid,4,'uchar=>char');
	if n ~= 4
		fclose(fid);
		error('something went wrong reading value(s) for fFileSignature');
	end

	% rewind
	fseek(fid,0,'bof');
	% transpose
	fFileSignature = fFileSignature';

	% one of the first checks must be whether file signature is valid
	switch fFileSignature
	 	case 'ABF ' % ** note the blank
	 		disp('v1')
	    	channel_names = readChannelsInABFv1();
	  	case 'ABF2'
	  		disp('ABF2 file')
	  		channel_names = readChannelsInABFv2();
	  otherwise
	    error('unknown or incompatible file signature. Send this file to abf@srinivas.gs');
	end
	fclose(fid);

end % end readABFChannelNames


function channel_names = readChannelsInABFv1()

	if fseek(fid, 442,'bof') ~= 0
		fclose(fid);
		error('something went wrong locating the header');
	end

	sz = 160;
	channel_names = bytes2char(fread(fid,sz,'uchar'));



end % readChannelsInABFv1

function channel_names = readChannelsInABFv2()

	BLOCKSIZE=512;
	StringsSection = ReadSectionInfo(fid,220);
	fseek(fid,StringsSection.uBlockIndex*BLOCKSIZE,'bof');
	old_string = fread(fid,StringsSection.uBytes,'char');
	old_string = char(old_string)';
	channel_names = strsplit(old_string, ' ');

end % readChannelsInABFv2

function C = bytes2char(B)
   temp = reshape(B,10,16);
   C = char(temp');
end

function B = char2bytes(C)
 	B = uint8(C)';
 	B = double (B(:));
end

function SectionInfo = ReadSectionInfo(fid,offset)
	fseek(fid,offset,'bof');
	SectionInfo.uBlockIndex=fread(fid,1,'uint32');
	fseek(fid,offset+4,'bof');
	SectionInfo.uBytes=fread(fid,1,'uint32');
	fseek(fid,offset+8,'bof');
	SectionInfo.llNumEntries=fread(fid,1,'int64');
end



end