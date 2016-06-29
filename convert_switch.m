function datfile = convert_switch(name)
% Use convert_ali to convert an alignment directory and related data to a
% .mat file. This saves time when browsing data.  If audiodir is specified,
% in the switch, then audio is converted to wav and copied. This is useful 
% for sharing data, but takes space.

% The result is used with

if (nargin < 1)
    name = 'bp3';
end

datfile = 0;
audiodir = 0;
audiobase = '/projects/speech/data/matlab-wav';
matbase = '/local/matlab/Kaldi-alignments-matlab/data';

% If audiodir is not specified, then audio is not converted and copied.
% The result stores the complete pathname of the audio 

switch name
   case 'bp3'
     % This converts without re-writing audio.
     alifile = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/exp/mono_aliWORD2/ali.all.gz'; 
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/data/trainWORD2/wav.scp';
     model = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/exp/mono_aliWORD2/final.mdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/data/trainWORD2/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/bp3';
   case 'shruti1'
     datfile = [matbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
     framec = 150;
   case 'bp1'
     datfile = [matbase '/' name '.mat'];
     audiodir = [audiobase '/' name];
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
     alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/alig.1.gz';
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/wav.scp';
     model = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/final.alimdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/lang_nosp/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/ls3a';
     % audiodir = '/Volumes/D/projects/speech/data/matlab-wav/ls3a';
   case 'ls3all'
    alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/alig.all.gz';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/wav.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/final.alimdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/lang_nosp/phones.txt';
    transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/ls3all';
    % audiodir = '/Volumes/D/projects/speech/data/matlab-wav/ls3all';
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

% Run conversion program.
if (audiodir == 0)
    convert_ali(alifile,wavscp,model,phones,transcript,datbase);
else
    convert_ali(alifile,wavscp,model,phones,transcript,datbase,audidir);
end
end



