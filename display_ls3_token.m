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

% CAN data
% display_ls3_token('/local/res/phon/stress/datar/CAN-AE1.tok','/Volumes/gray/matlab/matlab-mat/lsCAN.mat','/Volumes/gray/matlab/matlab-wav/lsCAN',100)

audiodir = '/Volumes/gray/matlab/matlab-wav/lsCAN';

% This version was converted using convert_ali3 and prepare-ali.sh.
matfile = '/Volumes/gray/matlab/matlab-mat/lsCAN2.mat';

tokenfile = '/local/res/phon/stress/datar/CAN-AE1.tok';

framec = 100;

display_ali_with_token3(matfile,audiodir,tokenfile,framec)

end