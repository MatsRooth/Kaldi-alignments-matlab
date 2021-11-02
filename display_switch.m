function display_switch(name)
% May need addpath('/local/matlab/voicebox')

if (nargin < 1)
    name = 'librispeech100_v2';
end
    
datfile = 0;
audiodir = 0;
audiobase = '/projects/speech/data/matlab-wav';
%datbase =  '/projects/speech/data/matlab-mat';
%audiobase = 'matlab-wav';
datbase =  '/projects/speech/data/matlab-mat';

framec = 150;
     
switch name
   case 'bp1'
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
   case 'lj2'
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'bp0V'
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   % above are ok
   case 'shruti1'
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'bp1'
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'bp_ne_func_stsh'
     datfile = [datbase '/' name '.mat'];
     audiodir = 0;
     framec = 150;
   case 'bpn'
     datfile = '/projects/speech/data/matlab-mat/bpn.mat';
     audiodir = 0;
     framec = 150;
   case 'bpnf'
     datfile = '/projects/speech/data/matlab-mat/bpnf';
     audiodir = 0;
     framec = 90;
   case 'bp0V'
     datfile = '/projects/speech/data/matlab-mat/bp0V';
     audiodir = 0;
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
     librispeech100_v2
   case 'librispeech100_v2' % ok
     datfile = [datbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 100;      
   case 'vm1a' % ok. This uses kaldi to get audio.
     datfile = [datbase '/' name '.mat'];
     audiodir = 0;
     framec = 100; 
   case 'korean1a'
    datfile = '/projects/speech/korean1a.mat';
    audiodir = 0;
    framec = 150;
   case 'korean2'
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/korean2.mat';
    audiodir = 0;
    framec = 150;
   case 'korean1b'
    datfile = '/projects/speech/data/matlab-mat/korean1b.mat';
    audiodir = '/projects/speech/data/matlab-wav/korean1b';
    framec = 150;
   case 'spanish1a'
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/spanish1a.mat';
    audiodir = '/projects/speech/data/matlab-wav/spanish1a';
    framec = 150;
   case 'spanish1b'
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/spanish1b.mat';
    audiodir = '/projects/speech/data/matlab-wav/spanish1b';
    framec = 150;
   case 'etri10k' % ok
     datfile = [datbase '/' name '.mat'];
     audiodir = '/Volumes/D/projects/speech/data/matlab-wav/etri10k';
     framec = 100;  
   case 'bp_ne_func_nplus1' % ok
     datfile = '/projects/speech/data/matlab-mat/bp_ne_func_nplus1.mat';
     audiodir = '/projects/speech/data/matlab-wav/bp_ne_func_nplus1';
     framec = 150;
   case 'bp_ne_func_two_n' % ok
     datfile = '/projects/speech/data/matlab-mat/bp_ne_func_two_n.mat';
     audiodir = '/projects/speech/data/matlab-wav/bp_ne_func_two_n';
     framec = 150; 
   case 'bp_ne_func_stsh' % 
     datfile = '/projects/speech/data/matlab-mat/bp_ne_func_stsh.mat';
     audiodir = '/projects/speech/data/matlab-wav/bp_ne_func_stsh';
     framec = 150; 
   case 'ls3mono100'
     datfile = '/home/mr249/local/matlab/Kaldi-alignments-matlab/matlab-mat/lsdemo.mat';
     audiodir = 0;
     framec = 120;
   otherwise
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/tri4b-e2.mat';
    audiodir = '/Volumes/D/projects/speech/data/matlab-wav/rm_s5a1';
    disp(audiodir);
    framec = 150;
end

disp(datfile);
disp(audiodir);

if (audiodir == 0)
    display_ali3(datfile,framec);
else
    display_ali3(datfile,framec,audiodir);
end
 
end

% Dependencies
% [fList,pList] = matlab.codetools.requiredFilesAndProducts('display_switch.m');
% disp(fList)
%    {'/System/Volumes/Data/local/matlab/Kaldi-alignments-matlab/display_ali3.m'         }
%    {'/System/Volumes/Data/local/matlab/Kaldi-alignments-matlab/display_switch.m'       }
%    {'/System/Volumes/Data/local/matlab/Kaldi-alignments-matlab/load_ali.m'             }
%    {'/System/Volumes/Data/local/matlab/Kaldi-alignments-matlab/load_kaldi_transcript.m'}
%    {'/System/Volumes/Data/local/matlab/Kaldi-alignments-matlab/parse_ali.m'            }
%    {'/System/Volumes/Data/local/matlab/Kaldi-alignments-matlab/phone_indexer.m'        }


