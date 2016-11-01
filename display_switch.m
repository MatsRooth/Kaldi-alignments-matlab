function display_switch(name)
% May need addpath('/local/matlab/voicebox')

if (nargin < 1)
    name = 'korean1a';
end

datfile = 0;
audiodir = 0;
%audiobase = '/projects/speech/data/matlab-wav';
%datbase =  '/projects/speech/data/matlab-mat';
audiobase = 'matlab-wav';
datbase =  'matlab-mat';

framec = 150;
     
switch name
   % ok
   case 'shruti1'
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'bp1'
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'bp3' % ok
     datfile = [datbase '/' name '.mat'];
     framec = 150;
   case 'Unigr_s5_NLex1' % ok
     datfile = '/local/matlab/Kaldi-alignments-matlab/data/Unigr_s5_NLex1.mat';
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'Unigr_s5_NLex' % ok
     datfile = '/local/matlab/Kaldi-alignments-matlab/data/Unigr_s5_NLex.mat';
     % This plays as desired using the command copied from wav.scp.
     framec = 150;
   case 'bp2all' % ok
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'rm_s5a1' % ok. Voicing confusability test for initial consonants?
     datfile = [datbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/rm_s5a1';
     framec = 150;
   case 'rm_s5a3' % ok 
     datfile = [datbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/rm_s5a3';
     framec = 150;
   case 'ls3a' % ok
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150; 
   case 'ls3ademo' % 
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
   case 'lsdemo' % 
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150; 
   case 'ls3all' % ok. This uses kaldi to get audio.
     datfile = [datbase '/' name '.mat'];
     audiodir = 0;
     framec = 100; 
   case 'vm1a' % ok. This uses kaldi to get audio.
     datfile = [datbase '/' name '.mat'];
     audiodir = 0;
     framec = 100; 
   case 'korean1a'
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/korean1a.mat';
    audiodir = 0;
    framec = 150;
   case 'etri10k' % ok
     datfile = [datbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/etri10k';
     framec = 100;    
   otherwise
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/tri4b-e2.mat';
    audiodir = '/Volumes/D/projects/speech/data/matlab-wav/rm_s5a1';
    disp(audiodir);
    framec = 150;
end


if (audiodir == 0)
    display_ali3(datfile,framec);
else
    display_ali3(datfile,framec,audiodir);
end
 
end



