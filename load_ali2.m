function [Uid,Basic,Pdf,Phone,Phone_seq] = load_ali2(alifile,model)
% Load from a Kaldi algignment file in integer basic, pdf, and 
% phone formats, using decoding information from model.

% This uses command line calls to kaldi to decode alignments using the
% model.

% Uid{10} = 103-1240-0012-T
% Wrd{10} = 8 offset of the target word.
% Basic{10} 1 x 1517 vector of transition IDs, the basic alignment.
% Pdf{10}   1 x 1517 vector of pdf IDs
% Phone{10} 1 x 1517 vector of phone IDs
% Phone_seq{10} 2 x 178 matrix of phone IDs, and in second row frame
% counts.

% Demo arguments.
if nargin < 2
    alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech2/s5/exp/tri3b_ali_train_trisyllable/ali.all-t.gz';
    model = '/projects/speech/sys/kaldi-trunk/egs/librispeech2/s5/exp/tri3b_ali_train_trisyllable/final.mdl';
end

% Read the tokne indez.
% 103-1240-0002-T	37	1125	1172	2	EVERYTHING-0	 EH2 V R IY0 TH IH1 NG
% Cell array of strings, mapping indices to uid.
Uid = {};
% Map from uid strings to indices
m = containers.Map;
% Cell array mapping indices to word offsets.
Wrd = {};

% Open input streams for alignments in various formats.
% Basic alignment with transition IDs.
basic_ali = '/tmp/align3_basic_ali.txt';
cmd = ['gzcat ', alifile, ' > ', basic_ali];
disp(cmd);
system(cmd);
basic_stream = fopen(basic_ali);

% Probability density ids.
% For each frame, the id of the pdf used for it.
pdf_ali = '/tmp/align3_pdf_ali.txt';
cmd = ['gzcat ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-pdf ', model, ' ark,t:- ark,t:- >', pdf_ali];
system(cmd);
pdf_stream = fopen(pdf_ali);

% Phones.
% For each frame, the numerical phone it is in.
phone_ali = '/tmp/align3_phone_ali.txt';
cmd = ['gzcat ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-phones  --per-frame ', model, ' ark,t:- ark,t:- >', phone_ali];
disp(cmd);
system(cmd);
phone_stream = fopen(phone_ali);

% Sequence of numerical phones transcribing the utterance with lengths..
% ahh05_st0556_trn 1 11 ; 182 9 ; 16 6 ; 159 3 ; 90 11 ;
 
phone_seq = '/tmp/align3_phone_seq.txt';
% --write-lengths
cmd = ['gzcat ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-phones --write-lengths ', model, ' ark,t:- ark,t:- >', phone_seq];
disp(cmd);
system(cmd);
phone_seq_stream = fopen(phone_seq);

% Initialize cell arrays and index for cell arrays.
% Key = {}; 
Basic = {}; Pdf = {}; Phone = {}; Phone_seq = {};

% Index corresponding to line number.
j = 0;

% Iterate through the lines of alignments
line_basic = fgetl(basic_stream);
while ischar(line_basic)
    line_pdf = fgetl(pdf_stream);
    line_phone = fgetl(phone_stream);   
    line_phone_seq = fgetl(phone_seq_stream);  
    [key,ab] = parse_alignment(line_basic);
    %disp(key);
    %Key{j} = key;
    %Basic{j} = ab;
    [keyp,ap] = parse_alignment(line_pdf);
    %Pdf{j} = ap;
    [keyh,ah] = parse_alignment(line_phone);
    %Phone{j} = ah;
    %[keys,as] = parse_alignment_with_length(line_phone_seq);
    [keys,as] = parse_alignment_with_length(line_phone_seq);
    %if the keys are the same
    if (strcmp(key,keyp) && strcmp(key,keyh) && strcmp(key,keys))
        j = j+1;
        Basic{j} = ab;
        Pdf{j} = ap;
        Phone{j} = ah;
        Phone_seq{j} = as;
        Uid{j} = key;
    end
    %Phone_seq{j} = as;
    %disp(size(a));
    %disp(j);
    line_basic = fgetl(basic_stream);
end

% Close the input streams.
fclose(basic_stream);
fclose(pdf_stream);
fclose(phone_stream);
fclose(phone_seq_stream);

%if (nargin == 4)
% Stuff to be saved.
%[Uid,Wrd,Basic,Pdf,Phone,Phone_seq]
%    disp(save);  
%    dat.uid = Uid;
%    dat.wrd = Wrd;
%    dat.basic = Basic;
%    dat.pdf = Pdf;
%    dat.phone = Phone;
%    dat.phone_seq = Phone_seq;
%    save(savefile,'dat');
%end

% Parse a line into a key and a vector of int.
function [key,a] = parse_alignment(line)
    key = sscanf(line,'%s',1);
    [~,klen] =  size(key);
    [~,llen] = size(line);
    line = line((klen+1):llen);
    a = sscanf(line,'%d')';
end

% Parse a line into a key and a vector of int.
% The input line looks like this.
%   bns04_st1921_trn 1 12 ; 6 7 ; 143 3 ; 50 8 ; 60 3 ; 143 4 ; 146 13
function [key,A] = parse_alignment_with_length(line)
    % Scan the key
    key = sscanf(line,'%s',1);
    [~,klen] =  size(key);
    [~,llen] = size(line);
    % Get rid of the key. 
    line = line((klen+1):llen);
    % Now we have this:
    % 1 12 ; 6 7 ; 143 3 ; 50 8 ; 60 3 ; 143 4 ; 146 13
    A = sscanf(line,'%d %d %*[;]',[2,Inf]);
    % A has numerical phones in the first row, and
    % length in frames in the second row.
end
% Illustrate Key and Align.
% Key{129}
% Align{129}(10:20)


end

