function reconstructMaskFromIgnoreSection(self)

self.mask = zeros(self.raw_data_size);


if isempty(self.ignore_section)
	self.mask = self.mask + 1;
	return
end

if  isempty(self.ignore_section.ons)
	self.mask = self.mask + 1;
	return
end

for i = 1:size(self.ignore_section.ons,1)
	self.mask(self.ignore_section.ons(i):self.ignore_section.offs(i),:) = 1;
end