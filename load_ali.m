function [Key,Basic,Pdf,Phone,Phone_seq] = load_ali(alifile,model)
% Load from a Kaldia algignment file in integer basic, pdf, and 
% phone formats, using decoding information from model.


% Default argument.  This pdf alignment file has 129 lines.
if nargin < 1
    alifile = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/ali.1.gz';
    model = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/final.mdl';
end

% Open input streams for alignments in various formats.
% Basic alignment with transition IDs.
basic_ali = '/tmp/align3_basic_ali.txt';
cmd = ['gzcat ', alifile, ' > ', basic_ali];
system(cmd);
basic_stream = fopen(basic_ali);

% Probability density ids.
pdf_ali = '/tmp/align3_pdf_ali.txt';
cmd = ['gzcat ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-pdf ', model, ' ark,t:- ark,t:- >', pdf_ali];
system(cmd);
pdf_stream = fopen(pdf_ali);

% Phones.
phone_ali = '/tmp/align3_phone_ali.txt';
cmd = ['gzcat ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-phones  --per-frame ', model, ' ark,t:- ark,t:- >', phone_ali];
system(cmd);
phone_stream = fopen(phone_ali);

phone_seq = '/tmp/align3_phone_seq.txt';
cmd = ['gzcat ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-phones ', model, ' ark,t:- ark,t:- >', phone_seq];
system(cmd);
phone_seq_stream = fopen(phone_seq);

% Initialize cell arrays and index for cell arrays.
Key = {}; Basic = {}; Pdf = {}; Phone = {}; Phone_seq = {};
% Index corresponding to line number.
j = 1;

% Iterate through the lines of alignments
line_basic = fgetl(basic_stream);
while ischar(line_basic)
    line_pdf = fgetl(pdf_stream);
    line_phone = fgetl(phone_stream);   
    line_phone_seq = fgetl(phone_seq_stream);  
    [key,ab] = parse_alignment(line_basic);
    Key{j} = key;
    Basic{j} = ab;
    [keyp,ap] = parse_alignment(line_pdf);
    Pdf{j} = ap;
    [keyh,ah] = parse_alignment(line_phone);
    Phone{j} = ah;
    [keys,as] = parse_alignment(line_phone_seq);
    Phone_seq{j} = as;
    %disp(size(a));
    j = j + 1;
    line_basic = fgetl(basic_stream);
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

