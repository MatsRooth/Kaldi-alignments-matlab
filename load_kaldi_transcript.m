function Tra = load_kaldi_transcript(trafile)
  % Tra maps an utterance file to a transcript in the form of ..
  % Sample line in the input:
  % 911-130578-0014 AND THEY DRANK AND WENT AWAY THEN VARIOUS KINDS OF BIRDS CAME 
  % ----- uid ----- ------- space-separated words of transcript ------
  % transcripts are (horizontal) cell arrays of strings

  % Default argument is in the train directory for rm/s5.
  if nargin < 1
      trafile = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/train/text';
  end

  % For a larger example, try
  %  Tra1 = load_kaldi_transcript('/Volumes/NONAME/speech/librispeech/s5/data/train_clean_100/text') 
  %  Tra1('103-1240-0009')
  %  Tra1('911-130578-0017')
  % Tra1 = 
  %  Map with properties:
  %        Count: 28539
  %      KeyType: char
  %    ValueType: any

  % Initialize the map.
  Tra = containers.Map();

  % UTF-8 added for BP
  istream = fopen(trafile,'r','n','UTF-8');
  % istream = fopen(trafile);

  % Iterate through the lines of inpu6.
  line = fgetl(istream);
  while ischar(line)
      [uid,tra] = parse_transcript_line(line);
      Tra(uid) = tra;
      line = fgetl(istream);
  end
  fclose(istream);

  function [uid,tra] = parse_transcript_line(line)
      space_index = strfind(line,' ');
      uid = line(1:space_index - 1);
      remainder = strtrim(line(space_index+1:end));
      tra = strsplit(remainder,' ');
  end

end
