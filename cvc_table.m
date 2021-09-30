function cvc_table(datfile,token_file,word_seg_file,phone_seg_file,audiodir)
% May need addpath('/local/matlab/voicebox')

syll_count = 1;
seg_count = 3;

if nargin < 1
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3mono100.mat';
    audiodir = 0;
    token_file = '/local/matlab/Kaldi-alignments-matlab/data/syl_cvc.tok';
    word_seg_file = '/local/matlab/Kaldi-alignments-matlab/data/syl_cvc_word.seg';
    phone_seg_file = '/local/matlab/Kaldi-alignments-matlab/data/syl_cvc_phone.seg';
end

% syll_table('/local/matlab/Kaldi-alignments-matlab/data/ls3mono100.mat','/local/matlab/Kaldi-alignments-matlab/data/syl4.tok',4,0)

% Load sets dat to a structure. It has to be initialized first.
dat = 0;
load(datfile);

Scp = dat.scp;
P = dat.phone_indexer;
Uid = dat.uid;
% Wrd = dat.wrd;
Basic = dat.basic;
Align_pdf = dat.pdf;
Align_phone = dat.align_phone;
Align_phone_len = dat.phone_seq;
Tra = dat.tra;
 
% Index in Uid and Align of the utterance being displayed.
ui = 1;

% Maximum value for ui.
[~,U] = size(Uid);

% Initialize some variables that are set in nested functions.
uid = 0; uid2 = 0; F = 0; Sb = 0; Pb = 0; Wb = 0; w = 0; w2 = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; 
PX = 0; ya = 0; tra = 0; wi = 1;
Fn = 0; PDF = 0;

% Pitch.
% Return values for fxrapt.
fx = 0; tt = 0; 
% Version of tt with frame indexing.
ttf = 0;
% ttf and fx restricted to the frames being displayed.
fx3 =0; tt3=0;
AX = 0;

% utterance_data(ui);

% Set data for k'th utterance.
    function utterance_data(k)
        uid = cell2mat(Uid(k));
        [F,Sb,Pb,Wb,tra] = parse_ali(uid,Align_pdf,Align_phone_len,Tra,P,k);
        % Escape underline for display.
        uid2 = strrep(uid, '_', '\_');
        PX = Align_phone{k};
        PDF = Align_pdf{k};
        % Maximum frame index
        [~,Fn] = size(F);
    end

    % Range of samples being displayed, this is global.
    SR = [];
    
    function wav = find_audio(uid)
        % Load the audio, either by using Kaldi to generate a tmp wav file,
        % or by reading from audiodir
        if (audiodir ~= 0)
            wav = [audiodir '/' uid '.wav'];
        else
            % Cat the pipe Scp(uid) into a temporary file.
            cmd = [Scp(uid), ' cat > /tmp/display_ali_tmp.wav'];
            % This helps flac work.
            setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
            system(cmd);
            wav = '/tmp/display_ali_tmp.wav';
        end
    end

% Output streams.
[otext,etext] = fopen(token_file,'w');
[owseg,ewseg] = fopen(word_seg_file,'w');
[opseg,epseg] = fopen(phone_seg_file,'w');

%figure();
%display_alignment(1);
%add_buttons;      
[~,um] = size(Uid);

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
            % spelling = P.ind2phone(PX(Pb(1,p1:p2)));
            st = P.stress(PX(Pb(1,p1:p2)));
            st = st(st >= 0);
            % Stress as string. Somehow this works for generating '1 0 2'
            % without a leading space.
            sts = num2str(st,' %d');
            sp = strjoin(P.inds2shortphones(PX(Pb(1,p1:p2))),' ');
            if length(st) == syll_count && (seg_count == 0 || length(p1:p2) == seg_count )
                count = count + 1;
                word = cell2mat(tra(j));
                uid_count = sprintf('%s_%d',uid,count);
                % For seg file.
                %fprintf(oseg,'%s %s %d %d\n',uid_count,uid,fr1,fr2);
                % Print to table
                fprintf(otext,'%s\t%d\t%s\t%s\t%s\n',uid,j,word,sts,sp);
                % Print to word segment file
                % New uid, old uid, frame start, frame end
                % The frame counts are decremented because Kaldi uses
                % 0-indexing. But decrementing also the end gave the wrong
                % length when used with extract-rows.
                fprintf(owseg,'%s-%d\t%s\t%d\t%d\n',uid,j,uid,Wb(1,j) - 1,Wb(2,j));
                % Print to phone seg file.  The new uids are of the form
                % uid-<word offset>-<phone offset>
                mpidx = 1;
                for mp = p1:p2
                  fprintf(opseg,'%s-%d-%d\t%s\t%d\t%d\n',uid,j,mpidx,uid,Pb(1,mp) - 1,Pb(2,mp));
                  mpidx = mpidx + 1;
                end
                % For alignment file
                basic_ali = cell2mat(Basic(k));
                basic_word_ali = basic_ali(fr1:fr2);
                %fprintf(oali,'%s%s\n',uid_count,sprintf(' %d', basic_word_ali));
                %fprintf(otable,'%s\t%s',uid_count,word);
                %fprintf(otable,'\t%s',cell2mat(trim_phones(spelling)));
                %fprintf(otable,'\n');
                %fprintf(oscp,'%s %s sox -t wav - -t wav - trim %ds %ds |\n',uid_count,Scp(uid), fr1 * 0.01 * fs - 1,(fr2 - fr1) * 0.01 * fs - 1);
                % Need also wavscp? Not for modeling. But see flac --skip and
                % --until.  Or sox in wavscp pipe.
                fprintf('%s\t%d\n',uid,j);
            end
        end
    end
end

fclose('all');

end



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

 
       
 
