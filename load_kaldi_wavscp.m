function Scp = load_kaldi_wavscp(scpfile)
% Scp is a map from utterance IDs to launch pipes for sph files.
 
% Default argument is in the train directory for rm/s5.
if nargin < 1
    scpfile = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/train/wav.scp';
end

% Initialize the map.
Scp = containers.Map();

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
    k = findstr(' ',line);
    [~,m] = size(line);
    uid = line(1:(k - 1));
    scp = line((k+1):m);
end

end

