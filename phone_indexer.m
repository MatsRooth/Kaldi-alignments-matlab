function phone_index = phone_indexer(phone_file)
% Construct back-and-forth map between phones and natural numbers

% Default argument is the resource management phone list.
if nargin < 1
    phone_file = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/lang/phones.txt';
end

% Initialize map from strings to indices
% Maps phone strings to indices.
m = containers.Map;
s = {};

istream = fopen(phone_file);
% Index corresponding to line number.
j = 1;

% Iterate through the lines of alignments
line = fgetl(istream);

while ischar(line)
    A = strsplit(line);
    ph = A{1};
    k = str2num(A{2});
    %disp(A); 
    m(ph) = k;
    s{k+1} = ph;
    line = fgetl(istream);
end
f1 = @(j) s(j+1);

%phone_index.str = s;
%phone_index.ind = m;
phone_index.ind2phone = f1; 
phone_index.phone2ind = m;

end

