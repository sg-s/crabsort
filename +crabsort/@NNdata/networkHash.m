function H = networkHash(self)

h1 = self.sdp.hash;
h2 = hashlib.md5hash([double(self.other_nerves_control) double(self.other_nerves)]);
H = hashlib.md5hash([h1 h2]);