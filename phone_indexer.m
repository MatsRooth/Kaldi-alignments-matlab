function phone_index = phone_indexer(phone_file)
  % Construct back-and-forth map between phones and natural numbers
  %
  % INPUTS:
  % phone_file : file of phones.txt file
  %
  % OUTPUTS:
  % phone_index : struct
  %   phone_index.ind2phone : function from index to ( cell array of phone
  %                           spelling
  %   phone_index.phone2ind : map from phone spelling to index
  %   phone_index.isbeginning : function from index to whether phone is
  %                             word-beginning
  %   phone_index.isend : function from index to whether phone is
  %                       word-ending


  % Default argument is the resource management phone list.
  if nargin < 1
      phone_file = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/lang/phones.txt';
  end

  % Initialize map from strings to indices
  % Maps phone strings to indices.
  spelling2index = containers.Map;
  % s{k + 1} = spelling of phone with index k
  index2spelling = {};

  % Is the phone index word-beginning 'ay_B', singleton 'ay_S', word-end 'ay_E'?
  % 1 beginning
  % 2 singleton
  % 3 end
  % 0 other
  phone_type = {};

  istream = fopen(phone_file);

  % Iterate through the lines of alignments
  line = fgetl(istream);

  while ischar(line)
      split_line = strsplit(line);
      phone_spelling = split_line{1};
      % Index of the phone.
      index = str2double(split_line{2});
      % Map the spelling to the index.
      spelling2index(phone_spelling) = index;
      % Record the spelling for the index. Add 1 because index can be 0
      index2spelling{index+1} = phone_spelling;
      % Is it a word-beginning
      % beginning or singleton phone
      if strcmp(phone_spelling(end-1:end),'_B')
        phone_type{index+1} = 1;
      elseif strcmp(phone_spelling(end-1:end),'_S')
        phone_type{index+1} = 2;
      elseif strcmp(phone_spelling(end-1:end),'_E')
        phone_type{index+1} = 3;
      else
        phone_type{index+1} = 0;
      end
      line = fgetl(istream);
  end

  phone_index = struct();
  % by mapping to a cell array instead of string, ind2phone becomes
  % "vectorizable"
  phone_index.ind2phone = @(k) index2spelling(k+1); 
  phone_index.phone2ind = spelling2index;
  phone_index.isbeginning = @(k)  phone_type{k+1} == 1 | phone_type{k+1} == 2;
  phone_index.isend = @(k) phone_type{k+1} == 2 | phone_type{k+1} == 3;

end
