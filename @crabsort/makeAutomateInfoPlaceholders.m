function makeAutomateInfoPlaceholders(self)


for i = self.n_channels:-1:1

	self.common.automate_info(i).spike_prom = [];
	self.common.automate_info(i).spike_sign = [];
	self.common.automate_info(i).other_nerves = {};
	self.common.automate_info(i).other_nerves_control = [];
end

