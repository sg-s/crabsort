function H = networkHash(self)

h1 = self.sdp.hash;
h2 = GetMD5([double(self.other_nerves_control) double(self.other_nerves)]);
H = GetMD5([h1 h2]);