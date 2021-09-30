function Scp = load_kaldi_wavscp(scpfile)
% Scp is a map from utterance IDs to launch pipes for sph files.
% Test: Scp2 = load_kaldi_wavscp()
 
% Default argument is in the train directory for rm/s5.
if nargin < 1
    scpfile = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/wav.scp';
end

% Initialize the map.
Scp = containers.Map('KeyType','char','ValueType','char');

istream = fopen(scpfile); 
j = 1;

% Iterate through the lines of wavscp.
line = fgetl(istream);
while ischar(line)
    %disp(line);
    [uid,scp] = parse_wavscp(line);
    Scp(uid) = scp;
    %disp(j);
    j = j + 1;
    line = fgetl(istream);
end
fclose(istream);

function [uid,scp] = parse_wavscp(line)
    % Split uid from pipe by whitespace.
    [A,~,C] = regexp(line,'[ \t]+','split');
    uid = cell2mat(A(1));
    [~,m] = size(line);
    scp = line(C(1):m);
end

end

