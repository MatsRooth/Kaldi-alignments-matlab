function display_ls3_token(tokenfile,matfile,audiodir,framec)
% Browse tokens in a display where the complete utterance is available.
% This is a draft of a program that works with current data structures.
% 
% May need addpath('/local/matlab/voicebox')
% But fxrapt was not working, it is edited out.
%

% framec number of frames displayed
% audiodir location of wav files, one per utterance id
% matfile mat file encoding data structures
% tokenfile tokens to display

% Default arguments.

if nargin < 4
    framec = 150;
end

% These default files are on MR's external disk Gray.

if nargin < 3
    audiodir = '/Volumes/Gray/matlab/matlab-wav/ls3all';
end

if nargin < 2
    matfile = '/Volumes/Gray/matlab/matlab-mat/ls3all.mat';
end
% CANae1_AE1.tok	CANae1_AH0.tok

if nargin < 1
    tokenfile = '/local/res/phon/stress/datar/CANae1_AH0.tok';
end

% Other realization
% display_ls3_token('/local/res/phon/stress/datar/CANae1_AE1.tok')

% Procedure for creating token file using token-index.awk.

%cat /projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100/text | egrep 'THAN I ' | awk -f ../../token-index.awk -v WORD=I > i.tok
    
 
display_ali_with_token3(matfile,audiodir,tokenfile,framec)

end