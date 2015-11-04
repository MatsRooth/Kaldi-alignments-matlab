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


% Is the index a word-beginning as 'ay_B'?
be = {};

istream = fopen(phone_file);
% Index corresponding to line number.
j = 1;

% Iterate through the lines of alignments
line = fgetl(istream);

while ischar(line)
    A = strsplit(line);
    % Spelling of the phone.
    ph = A{1};
    % Index of the phone.
    k = str2num(A{2});
    % Map the spelling to the index.
    m(ph) = k;
    % Record the spelling for the index.
    s{k+1} = ph;
    line = fgetl(istream);
    % Is it a word-beginning
    [~,le] = size(char(ph));
    disp(ph); disp(le);
    ph2 = char(ph);
    if strcmp(ph2(le-1:le),'_B')
        be{k+1} = 1
    else
        be{k+1} = 0
    end 
end

be = cell2mat(be);

% Map index to spelling.
% The value is a cell, could it be a string?
f1 = @(j) s(j+1);

% Is it a word-beginning?
f2 = @(j) be(j+1);

%phone_index.str = s;
%phone_index.ind = m;
phone_index.ind2phone = f1; 
phone_index.phone2ind = m;
phone_index.isbeginning = f2;

end

