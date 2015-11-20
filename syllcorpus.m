function syllcorpus(alifile,wavscp,model,phones,transcript,obase,nvowel)
%  UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Default argument  
if nargin < 7
    disp('Using default arguments.')
    alifile = '/Volumes/NONAME/speech/librispeech/s5/exp/tri4b/ali-e3-t.gz';
    wavscp = '/Volumes/NONAME/speech/librispeech/s5/data/train_clean_100/wav-e3.scp';
    model = '/Volumes/NONAME/speech/librispeech/s5/exp/tri4b/final.mdl';
    phones = '/Volumes/NONAME/speech/librispeech/s5/data/lang_nosp/phones.txt';
    transcript = '/Volumes/NONAME/speech/librispeech/s5/data/train_clean_100/text-e3';
    obase = '/local/matlab/Kaldi-alignments-matlab/data/bi1';
    nvowel = 3;
end

% Read wav file and alignment for all the utterance IDs.
% Map from uid to wav launch pipes.
Scp = load_kaldi_wavscp(wavscp);

% Read transcript.
Tra = load_kaldi_transcript(transcript);

% For mapping back and forth between phones and their indices.
P = phone_indexer(phones);

% Create and load the alignments in various formats.
% Cell array of Uid, and cell array of alignment vectors.
[Uid,Basic,Align_pdf,Align_phone,Align_phone_len] = load_ali(alifile,model);

% Index in Uid and Align of the utterance being displayed.
ui = 1;

% Maximum value for ui.
[~,U] = size(Uid);

% Initialize some variables that are set in nested functions.
uid = 0; uid2 = 0; F = 0; Sb = 0; Pb = 0; Wb = 0; w = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; 
PX = 0; ya = 0; tra = 0; wi = 1;
Fn = 0;

utterance_data(ui);
 

% [PH,SU,PHstart,PHend,SUstart,SUend,WRstart,tra] = parse_ali2(uid,Align_pdf,Align_phone,Tra,P,n)

% Set phone and audio data for k'th utterance.
% Values are for utterance k.
    function utterance_data(k)
        uid = cell2mat(Uid(k));
        [F,Sb,Pb,Wb,tra] = parse_ali2(uid,Align_pdf,Align_phone_len,Tra,P,k);
        % Escape underline for display.
        uid2 = strrep(uid, '_', '\_');
        PX = Align_phone{k};
        % Maximum frame index
        [~,Fn] = size(F);
        % Load audio. Cat the pipe Scp(uid) into a temporary file.
        cmd = [Scp(uid), ' cat > /tmp/display_ali_tmp.wav'];
        %disp(cmd);
        %system('echo $SHELL');
        %system('which flac');
        system(cmd);
        %system('flac -c -d -s /projects/speech/data/librispeech/LibriSpeech/train-clean-100/103/1240/103-1240-0015.flac | cat > /tmp/display_ali_tmp.wav');
        wav = '/tmp/display_ali_tmp.wav';
        % Read the temporary wav file.
        [w,fs] = audioread(wav);
        % Number of audio samples in a centisecond frame.
        M = fs / 100;
        [nsample,~] = size(w);
        [~,nframe] = size(F);
    end

    % Range of samples being displayed, this is global.
    SR = [];
    
% Output streams.
[otext,etext] = fopen([obase,'-text'],'w');
[oseg,eseg] = fopen([obase,'-seg'],'w');
[oali,eali] = fopen([obase,'-ali'],'w');
[otable,etable] = fopen([obase,'-table'],'w');
%figure();
%display_alignment(1);
%add_buttons;      
[~,um] = size(Uid);

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

% For each utterance.
for k = 1:um
    u = Uid(k);
    % fprintf('%d %s\n',k,cell2mat(u));
    utterance_data(k);
    [~,wm] = size(Wb);
    % Number of bisyllables found so far in the utterance.
    count = 0;
    % For each word in the utterance.
    for j = 1:wm
        % First and last frames indices for the word.
        fr1 = Wb(1,j);
        fr2 = Wb(2,j);
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
            spelling = P.ind2phone(PX(Pb(1,p1:p2)));
            if bisyllable(spelling,nvowel)
                count = count + 1;
                word = cell2mat(tra(j));
                uid_count = sprintf('%s_%d',uid,count);
                % For seg file.
                fprintf(oseg,'%s %s %d %d\n',uid,uid_count,fr1,fr2);
                % For text file
                fprintf(otext,'%s %s\n',uid_count,word);
                % For alignment file
                basic_ali = cell2mat(Basic(k));
                basic_word_ali = basic_ali(fr1:fr2);
                fprintf(oali,'%s%s\n',uid_count,sprintf(' %d', uid, basic_word_ali));
                fprintf(otable,'%s\t%s',uid_count,word);
                fprintf(otable,'\t%s',cell2mat(trim_phones(spelling)));
                fprintf(otable,'\n');
                % Need also wavscp? Not for modeling. But see flac --skip and
                % --until.  Or sox in wavscp pipe.
                fprintf('%d %s\n',k,uid_count);
            end
        end
    end
end
fclose('all');
end

function tv = bisyllable(spelling,n)
   % Is the argument a bisyllable?
   c0 = 0;
   c1 = 0;
   c2 = 0;
   for x = spelling
       x = trim_phone(x);
       if strfind(x,'0')
           c0 = c0 + 1;
       end
       if strfind(x,'1')
           c1 = c1 + 1;
       end
       if strfind(x,'2')
           c2 = c2 + 1;
       end
   end
   if c0 + c1 + c2 == n
       tv = 1;
   else
       tv = 0;
   end
end
    
function p2 = trim_phone(p)
    % Remove the part of phone symbol p after '_'.
    p = p{1};
    p2 = p;
    loc = strfind(p,'_');
    if loc
        p2 = p2(1:(loc - 1));
    end
end

function p2 = trim_phones(ps1)
  p2 = ps1(1:length(ps1));
  for k = 1:length(ps1);
    p2(k) = {[' ',trim_phone(ps1(k))]}; 
  end
end


