function reconstructMaskFromIgnoreSection(self)

% remember, mask = 1 --> show
% mask = 0 --> don't show

self.mask = ones(self.raw_data_size);

if isempty(self.ignore_section)
	return
end

if  isempty(self.ignore_section.ons)
	return
end

if  isempty(self.ignore_section.offs)
	return
end

for i = 1:size(self.ignore_section.ons,1)
	self.mask(self.ignore_section.ons(i):self.ignore_section.offs(i),:) = 0;
end

