function removeDoublets(s)

if s.verbosity > 5
    cprintf('green','\n[INFO] ')
    cprintf('text',[mfilename ' called'])
end

% try to remove doublets
if ~s.pref.remove_doublets
    return
end 


% remove B doublets and assign one of them to A
% get the refractory time 


B = s.B;
A = s.A;

B2A_cand = B(diff(B) < s.pref.doublet_distance);
B2A_alt = B(find(diff(B) < s.pref.doublet_distance)+1);
B2A = NaN*B2A_cand;

% for each candidate, find the one in the pair that is further away from adjacent A spikes
for i = 1:length(B2A_cand)
    if min(abs(B2A_cand(i)-A)) < min(abs(B2A_alt(i)-A))
        % candidate closer to A spike
        B2A(i) = B2A_cand(i);
    else
        % alternate closer to A spike
        B2A(i) = B2A_alt(i);
    end
end

if s.verbosity
    cprintf('green','\n[INFO]')
    cprintf('text', [' B2A doublet resolution.' oval(length(B2A)) ' spikes swapped'])

end
% swap 
A = sort(unique([A(:); B2A(:)]));
B = setdiff(B,B2A);

% remove A doublets and assign one of them to B
A2B_cand = A(diff(A) < s.pref.doublet_distance);
A2B_alt = A(find(diff(A) < s.pref.doublet_distance)+1);

% don't undo what we just did
temp = ismember(A2B_alt,unique([B2A_cand B2A_alt])) | ismember(A2B_cand,unique([B2A_cand B2A_alt]));
A2B_cand(temp) = [];
A2B_alt(temp) = [];

% for each candidate, find the one in the pair that is further away from adjacent B spikes
for i = 1:length(A2B_cand)
    if min(abs(A2B_cand(i)-B)) < min(abs(A2B_alt(i)-B))
        % candidate closer to B spike
    else
        % alternate closer to B spike
        A2B_cand(i) = A2B_alt(i);
    end
end

% swap 
B = sort(unique([B(:); A2B_cand(:)]));
A = setdiff(A,A2B_cand);

if s.verbosity
    cprintf('green','\n[INFO]')
    cprintf('text', [' B2A doublet resolution.' oval(length(A2B_cand)) ' spikes swapped'])
end

s.A = A;
s.B = B;
