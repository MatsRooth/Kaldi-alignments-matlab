

function syllcorpus(extract,extractNext,alifile,wavscp,model,phones,transcript,obase)
  %  Outputs extractions from the given transcript to files with prefix
  %  obase. Determines which words to extract via extract
  %
  % INPUT:
  % extract: function from cell array of string, representing phones of a
  %          word, to whether that word should be extracted  
  % extractNext : bool - whether the word following a word that satisifies
  %                      extract should also be extracted

  % Default arguments
  if nargin < 1
    extract = @bisyllable; % if relying on default, you should check that num_vowels 
                           % defined in bisyllable is what you want
  end 
  if nargin < 2
    extractNext = false;
  end
  if nargin < 7
    disp('Using default arguments.');
    alifile = '/Volumes/NONAME/speech/librispeech/s5/exp/tri4b/ali-e3-t.gz';
    wavscp = '/Volumes/NONAME/speech/librispeech/s5/data/train_clean_100/wav-e3.scp';
    model = '/Volumes/NONAME/speech/librispeech/s5/exp/tri4b/final.mdl';
    phones = '/Volumes/NONAME/speech/librispeech/s5/data/lang_nosp/phones.txt';
    transcript = '/Volumes/NONAME/speech/librispeech/s5/data/train_clean_100/text-e3';
    obase = '/local/matlab/Kaldi-alignments-matlab/data/tri1b';    
  end

  % Read wav file and alignment for all the utterance IDs.
  % Map from uid to wav launch pipes.
  Scp = load_kaldi_wavscp(wavscp);

  % Read transcript.
  Tra = load_kaldi_transcript(transcript);

  % For mapping back and forth between phones and their indices.
  phone_index = phone_indexer(phones);

  % Create and load the alignments in various formats.
  % Cell array of Uid, and cell array of alignment vectors.
  [Uid,Basic,Align_pdf,Align_phone,Align_phone_len] = load_ali(alifile,model);

  % Make flac available
  setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
  % Run display program.
  system('which flac');

  % Output streams.
  [otext,~] = fopen([obase,'-text'],'w');
  [oseg,~] = fopen([obase,'-seg'],'w');
  [oali,~] = fopen([obase,'-ali'],'w');
  [otable,~] = fopen([obase,'-table'],'w');
  [oscp,~] = fopen([obase,'-wav.scp'],'w');
    
  [~,num_utterances] = size(Uid);

  % Columns of numerical result.
  % 1 utterance index
  % 2 word offset
  % 3 frame offset 
  % 4 frame length
  % 5 number of bisyllables so far for the word, for new uid
  % 6 int sequence of phones

  % Columns of cell result.
  % 1 uid
  % 2 word filler
  % 3 string sequence of phones

  % Segment files look like this.
  % New id                Old id          Frame range
  % adg04_sr009_trn-start adg04_sr009_trn 1 6
  % adg04_sr049_trn-start adg04_sr049_trn 1 6

  temporaryAudioFile = '/tmp/display_ali_tmp.wav';
  
  for k = 1:num_utterances
    % get phone and audio data for k^th utterance
    uid = cell2mat(Uid(k));
    [F,~,Pb,Wb,tra] = parse_ali(uid,Align_pdf,Align_phone_len,Tra,phone_index,k);
    PX = Align_phone{k};
    system([Scp(uid),' cat > ',temporaryAudioFile]);
    [~,sample_rate] = audioread(temporaryAudioFile);
    [~,num_words] = size(Wb);
    
    % Number of extraction found so far in the utterance.
    count = 0;
    for word_index = 1:num_words
      % First and last frames indices for the word.
      fr1 = Wb(1,word_index);
      fr2 = Wb(2,word_index);
      % Without checking fr1 and fr2,
      % get error around here 375 1069-133709-0040
      % Subscript indices must either be real positive integers or logicals.
      % Error in syllcorpus (line 124)
      % p2 = F(2,fr2);
      if fr1 > 0 && fr2 > 0
        % The range of phone indices for the word is p1:p2.
        p1 = F(2,fr1);
        p2 = F(2,fr2);
        % The spelling of the word in localized phones, 
        % e.g.     'd_B'    'ax_I'    'z_E'
        spelling = phone_index.ind2phone(PX(Pb(1,p1:p2)));
        if extract(spelling)
          count = count + 1;
          word = cell2mat(tra(word_index));
          uid_count = sprintf('%s_%d',uid,count);
          if (extractNext && word_index < num_words)
            fr2 = Wb(2, word_index + 1);
            word = [word, ' ', cell2mat(tra(word_index + 1))]; 
          end          
          % For seg file.
          fprintf(oseg,'%s %s %d %d\n',uid_count,uid,fr1,fr2);
          % For text file
          fprintf(otext,'%s %s\n',uid_count,word);
          % For alignment file
          basic_ali = cell2mat(Basic(k));
          basic_word_ali = basic_ali(fr1:fr2);
          fprintf(oali,'%s%s\n',uid_count,sprintf(' %d', basic_word_ali));
          fprintf(otable,'%s\t%s',uid_count,word);
          fprintf(otable,'\t%s',cell2mat(trim_phones(spelling)));
          fprintf(otable,'\n');
          fprintf(oscp,'%s %s sox -t wav - -t wav - trim %ds %ds |\n',uid_count,Scp(uid), fr1 * 0.01 * sample_rate - 1,(fr2 - fr1) * 0.01 * sample_rate - 1);
          % Need also wavscp? Not for modeling. But see flac --skip and
          % --until.  Or sox in wavscp pipe.
          fprintf('%d %s\n',k,uid_count);
        end
      end
    end
  end
  fclose('all');
end

% Extraction Functions

function tv = bisyllable(spelling)
  % Is the argument a bisyllable?
  % INPUT:
  %   spelling : (hprizontal) cell array of strings - phones
  
  % target number of vowels
  num_vowels = 3; 
  c0 = 0;
  c1 = 0;
  c2 = 0;
  for x = spelling
    phone = trim_phone(x);
    if strfind(phone,'0')
        c0 = c0 + 1;
    end
    if strfind(phone,'1')
        c1 = c1 + 1;
    end
    if strfind(phone,'2')
        c2 = c2 + 1;
    end
  end
  tv = (c0 + c1 + c2 == num_vowels);
end
    
function p = trim_phone(pCell)
  % Removes the part of phone symbol p after (and including) '_'.
  % INPUT:
  %   pCell : cell array containing a phone (string)
  % OUTPUT:
  % p : trimmed phone (string)
  p = pCell{1};
  loc = strfind(p,'_');
  if loc
      p = p(1:(loc - 1));
  end
end

function p2 = trim_phones(ps1)
  % INPUT:
  %   ps1 : cell array of strings - phones
  % OUTPUT:
  %   p2 : cell array of strings - trimmed phones (with leading space)
  p2 = ps1(1:length(ps1));
  for k = 1:length(ps1);
    p2(k) = {[' ',trim_phone(ps1(k))]}; 
  end
end

