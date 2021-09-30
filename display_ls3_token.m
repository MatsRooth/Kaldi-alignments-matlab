function display_ls3_token(tokenfile,framec)
% Browse tokens in a display where the complete utterance is available.
% This is a draft of a program that works with current data structures.
% 
% May need addpath('/local/matlab/voicebox')
% But fxrapt was not working, it is edited out.
%

% e.g tokenfile = '/local/res/phon/stress/datar/CANae1_AH0.tok';

datfile = '/Volumes/Gray/matlab/matlab-mat/ls3all.mat';
audiodir = '/Volumes/Gray/matlab/matlab-wav/ls3all';

if nargin < 2
    framec = 150;
end

% CANae1_AE1.tok	CANae1_AH0.tok


if nargin < 1
    tokenfile = '/projects/speech/data/phon/stress/datar/HASae1-0.tok'
end
 
% CANae1_AH0.tok'

%cat /projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100/text | egrep 'THAN I ' | awk -f ../../token-index.awk -v WORD=I > i.tok
    
 
display_ali_with_token3(datfile,audiodir,tokenfile,framec)

end