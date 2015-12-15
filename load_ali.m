function [Key,Basic,Pdf,Phone,Phone_seq] = load_ali(alifile,model)
  % Load from a Kaldi algignment file in integer basic, pdf, and 
  % phone formats, using decoding information from model.
  %
  % OUTPUTS:
  % Key: cell array of key/unique-identifiers
  % Basic: cell array of transition-id vectors
  % Pdf: cell array of pdf-id vectors
  % Phone: cell array of phone-id vectors
  % Phone_seq: cell array of [phone-ids; lengths] matrices

  if nargin < 2
    alifile = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/ali.1.gz';
    model = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/final.mdl';
  end

  % Open input streams for alignments in various formats.
  % Basic alignment with transition IDs.
  basic_ali = '/tmp/align3_basic_ali.txt';
  cmd = ['gunzip -c ', alifile, ' > ', basic_ali];
  system(cmd);
  basic_stream = fopen(basic_ali);

  % Probability density ids.
  % For each frame, the id of the pdf used for it.
  pdf_ali = '/tmp/align3_pdf_ali.txt';
  cmd = ['gunzip -c ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-pdf ', model, ' ark,t:- ark,t:- >', pdf_ali];
  system(cmd);
  pdf_stream = fopen(pdf_ali);

  % Phones.
  % For each frame, the numerical phone it is in.
  phone_ali = '/tmp/align3_phone_ali.txt';
  cmd = ['gunzip -c ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-phones  --per-frame ', model, ' ark,t:- ark,t:- >', phone_ali];
  system(cmd);
  phone_stream = fopen(phone_ali);

  % Sequence of numerical phones transcribing the utterance with lengths..
  % ahh05_st0556_trn 1 11 ; 182 9 ; 16 6 ; 159 3 ; 90 11 ;
  phone_seq = '/tmp/align3_phone_seq.txt';
  % --write-lengths
  cmd = ['gunzip -c ', alifile, ' | /projects/speech/sys/kaldi-trunk/src/bin/ali-to-phones --write-lengths ', model, ' ark,t:- ark,t:- >', phone_seq];
  system(cmd);
  phone_seq_stream = fopen(phone_seq);

  % All files created above hsould have same number of lines
  [~, num_lines_string] = system(['cat ',basic_ali,' | wc -l ']);
  num_lines = str2double(num_lines_string);
  
  % Initialize cell arrays and index for cell arrays.
  Key = cell(1, num_lines); Basic = cell(1, num_lines);
  Pdf = cell(1, num_lines); Phone = cell(1, num_lines);
  Phone_seq = cell(1, num_lines);

  % Iterate through the lines of alignments
  for index = 1:num_lines
    line_basic = fgetl(basic_stream);
    line_pdf = fgetl(pdf_stream);
    line_phone = fgetl(phone_stream);   
    line_phone_seq = fgetl(phone_seq_stream);  
    [key,ab] = parse_alignment(line_basic);
    Key{index} = key;
    Basic{index} = ab;
    [~,ap] = parse_alignment(line_pdf);
    Pdf{index} = ap;
    [~,ah] = parse_alignment(line_phone);
    Phone{index} = ah;
    [~,as] = parse_alignment_with_length(line_phone_seq);
    Phone_seq{index} = as;
  end

  % Close the input streams.
  fclose(basic_stream);
  fclose(pdf_stream);
  fclose(phone_stream);
  fclose(phone_seq_stream);

  % Parse a line into a key and a vector of int.
  function [key,a] = parse_alignment(line)
    key = sscanf(line,'%s',1);
    [~,klen] =  size(key);
    line = line(klen+1:end);
    a = sscanf(line,'%d')';
  end

  % Parse a line into a key and a vector of int.
  % The input line looks like this.
  %   bns04_st1921_trn 1 12 ; 6 7 ; 143 3 ; 50 8 ; 60 3 ; 143 4 ; 146 13
  function [key,A] = parse_alignment_with_length(line)
    % Scan the key (up to the first space)
    key = sscanf(line,'%s',1);
    [~,klen] =  size(key);
    % Get rid of the key. 
    line = line(klen+1:end);
    % Now we have this:
    % 1 12 ; 6 7 ; 143 3 ; 50 8 ; 60 3 ; 143 4 ; 146 13
    A = sscanf(line,'%d %d %*[;]',[2,Inf]);
    % A has numerical phones in the first row, and
    % length in frames in the second row.
  end

end