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

% Is the phone index a word-beginning such as as 'ay_B', singleton 'ay_S', word-end 'ay_E'?
% 1 beginning
% 2 singleton
% 3 end
% 0 other

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
    %line = fgetl(istream);
    % Is it a word-beginning
    [~,le] = size(char(ph));
    % disp(ph); disp(le);
    ph2 = char(ph);
    % beginning or singleton phone
    if strcmp(ph2(le-1:le),'_B')
        be{k+1} = 1;
    elseif strcmp(ph2(le-1:le),'_S')
            be{k+1} = 2;
    elseif strcmp(ph2(le-1:le),'_E')
             be{k+1} = 3;
    else be{k+1} = 0;
    end
    line = fgetl(istream);
end

be = cell2mat(be);

% Map index to spelling.
% The value is a cell, could it be a string?
f1 = @(j) s(j+1);

% Map index to type 0,1,2,3
f2 = @(j)  be(j+1) == 1 | be(j+1) == 2;

f3 = @(j)  be(j+1) == 2 | be(j+1) == 3;

%phone_index.str = s;
%phone_index.ind = m;
phone_index.ind2phone = f1; 
phone_index.phone2ind = m;
phone_index.isbeginning = f2;
phone_index.isend = f3;

end

