% checks that the NNdata is OK

function check(self)

SZ = size(self.raw_data,2);
assert(size(self.file_idx,1) == SZ,'NNdata:check:Size mismatch')
assert(size(self.spiketimes,1) == SZ,'NNdata:check:Size mismatch')
assert(size(self.label_idx,1) == SZ,'NNdata:check:Size mismatch')