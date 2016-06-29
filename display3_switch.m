function display3_switch(name)
% May need addpath('/local/matlab/voicebox')

if (nargin < 1)
    name = 'bp3';
end

datfile = 0;
audiodir = 0;
audiobase = '/projects/speech/data/matlab-wav';
matbase = '/local/matlab/Kaldi-alignments-matlab/data';

switch name
   case 'shruti1'
     datfile = [matbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'bp1'
     datfile = [matbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
   case 'bp3'
     datfile = [matbase '/' name '.mat'];
     framec = 150;
   case 'bp2all'
     datfile = [matbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'rm_s5a1'
     datfile = [matbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/rm_s5a1';
     framec = 150;
   case 'rm_s5a3'
     datfile = [matbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/rm_s5a3';
     framec = 150;
   case 'ls3a'
     datfile = [matbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/ls3a';
     framec = 100;  
   case 'ls3all'
     datfile = [matbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/ls3all';
     framec = 100; 
   case 'etri10k'
     datfile = [matbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/etri10k';
     framec = 100;  
   otherwise
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/tri4b-e2.mat';
    audiodir = '/Volumes/D/projects/speech/data/matlab-wav/rm_s5a1';
    disp(audiodir);
    framec = 150;
end

display_ali3(datfile,framec);
disp(1);
end



