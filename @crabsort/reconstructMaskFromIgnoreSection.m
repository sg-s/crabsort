function reconstructMaskFromIgnoreSection(self)



if isempty(self.ignore_section)
	self.mask = self.raw_data*0 + 1;
	return
end

if  isempty(self.ignore_section.ons)
	self.mask = self.raw_data*0 + 1;
	return
end

self.mask = self.raw_data*0;

for i = 1:size(self.ignore_section.ons,1)
	self.mask(self.ignore_section.ons(i):self.ignore_section.offs(i),:) = 1;
end