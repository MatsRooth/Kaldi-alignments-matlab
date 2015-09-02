function [Key,Align] = load_ali(alifile)
% Load an alignment file into a cell array of keys and a cell array
% of vectors of int. An alignment file like 
% /projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/ali.1a has 
% transition IDs.  It is converted to pdf IDs like this.
% ali-to-pdf exp/mono/final.mdl ark:exp/mono/ali.1a ark,t:-  > exp/mono/alipdf.1


% Default argument.  This pdf alignment file has 129 lines.
if nargin < 1
    alifile = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/alipdf.1';
end

istream = fopen(alifile);

% Initialize cell arrays and index for cell arrays.
Key = {};
Align = {};
j = 1;

% Iterate through the lines of alifile.
line = fgetl(istream);
while ischar(line)
    [key,a] = parse_alignment(line);
    Key{j} = key;
    Align{j} = a;
    %disp(size(a));
    j = j + 1;
    line = fgetl(istream);
end

% Parse a line into a key and a vector of int.
function [key,a] = parse_alignment(line)
    key = sscanf(line,'%s',1);
    [~,klen] =  size(key);
    [~,llen] = size(line);
    line = line((klen+1):llen);
    a = sscanf(line,'%d')';
end

% Illustrate Key and Align.
% Key{129}
% Align{129}(10:20)

end

