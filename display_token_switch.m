function display_token_switch(name)
% May need addpath('/local/matlab/voicebox')
% Run display-token on material indicated by a short name.

if (nargin < 1)
    name = 'u221';
end

datfile = 0;
audiodir = 0;
audiobase = '/projects/speech/data/matlab-wav';
matbase = '/projects/speech/data/matlab-mat';

% Audiodir = 0 indicates that audio is played from the kaldi
% representation.

switch name
   case 'bp0V'
     datfile = [matbase '/' name '.mat'];
     tokenfile = [matbase '/' name '.tok'];
     audiodir = 0;
     framec = 150;
   case 'u221'
     datfile = [matbase '/' 'bp0V' '.mat'];
     tokenfile = '/local/res/bpw2/token/u221.tok';
     audiodir = 0;
     framec = 150;
   case 'U323'
     datfile = [matbase '/' 'bp0V' '.mat'];
     tokenfile = '/local/res/bpw2/decode/u323.tok';
     audiodir = 0;
     framec = 150;
   case 'bp3'
     datfile = '/projects/speech/data/matlab-mat/bp3.mat';
     audiodir = 0;
     framec = 150;
   % Alignment based on words without stress marks, trained that way
   % from the start.
   case 'bp0V'
     datfile = '/projects/speech/data/matlab-mat/bp0V.mat';
     audiodir = 0;
     framec = 150;
   case 'will-1'
     datfile = [matbase '/' name '.mat'];
     audiodir = 0;
     framec = 150;
   otherwise
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/tri4b-e2.mat';
    audiodir = '/Volumes/D/projects/speech/data/matlab-wav/rm_s5a1';
    disp(audiodir);
    framec = 150;
end

disp(datfile);

% The below is wrong.
% display_token(tokenfile,datfile,framec,audiodir)
%   datfile = '/projects/speech/data/matlab-mat/bp0V.mat';
%   outfile = '/projects/speech/data/matlab-mat/bp0V.tok'; 
% 

display_token(tokenfile,datfile,framec);

end



