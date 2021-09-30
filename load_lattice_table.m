function latdat = load_lattice_table(tabfile)
% Result is a struct
%        wid: [20×1 string]
%       word: [20×1 string]
%      wordu: [20×1 string]
%        syl: [20×1 double]
%    cstress: [20×1 double]
%    astress: [20×1 double]
%    weight1: {1×20 cell}
%    weight2: {1×20 cell}
%      align: {1×20 cell}

if nargin < 1
    tabfile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/bpw2/exp/u1/decode_word_1/tab4-sample';
end

% Cell array of strings, mapping indices to uid.
Uid = {};
% Map from uid strings to indices
m = containers.Map;
% Cell array mapping indices to word offsets.
Wrd = {};

% Running index.
j = 1;
token_stream = fopen(tabfile);

line = fgetl(token_stream);
while ischar(line)
    line = strtrim(line);
    part = strsplit(line,'\t');
    uid = part{1};
    offset = str2num(part{2});
    Uid{j} = uid;
    Wrd{j} = offset;   
    m(uid) = j;
    line = fgetl(token_stream);
    j = j + 1;
end

% For reading
T = readtable(tabfile, 'Delimiter','\t', 'ReadVariableNames',false);

% These are string arrays (not char vectors).
Uid = string(T{:,1});
Word = string(T{:,2});
WordU = string(T{:,3});

% These are vectors of numbers.
Syl = T{:,4};
% Citation stress
CStress = T{:,5}; 
% Alignment stress
AStress = T{:,6};

[n,~] = size(T);

% Weight1 and Weight2 are cell vectors containing vectors of double.
T7 = T{:,7};
Weight1 = cell(1,n);
for i = 1:n
    Weight1{i} = str2double(split(T7{i})');
end

T8 = T{:,8};
Weight2 = cell(1,n);
for i = 1:n
    Weight2{i} = str2double(split(T8{i})');
end

% Alignments
Align = cell(1,n);
T9 = T{:,9};
for i = 1:n
    % The data structure here can be improved, right not we don't care.
    Align{i} = cellfun(@(x) str2double(split(x,'_')), split(T9{1}),'UniformOutput',false);
end

% This is a word id rather than uid.
latdat.wid = Uid;
latdat.word = Word;
latdat.wordu = WordU;
latdat.syl = Syl;
latdat.cstress = CStress;
latdat.astress = AStress;
latdat.weight1 = Weight1;
latdat.weight2 = Weight2;
latdat.align = Align;
k = 1;

end

