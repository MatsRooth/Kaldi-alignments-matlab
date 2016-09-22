function datfile = convert_switch(name)
% Use convert_ali to convert an alignment directory and related data to a
% .mat file. This saves time when browsing data.  If audiodir is specified,
% in the switch, then audio is converted to wav and copied. This is useful 
% for sharing data, but takes space.

% The result is used with

if (nargin < 1)
    name = 'ls3ademo';
end

datfile = 0;
audiodir = 0;
audiobase = '/projects/speech/data/matlab-wav';
datdir = '/projects/speech/data/matlab-mat';

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
   % OK
   case 'shruti1'
     alifile = '/projects/speech/sys/kaldi-trunk/egs/shruti/s5_ini/exp/mono_ali2/ali.1.gz';
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/shruti/s5_ini/data/train70_2/wav.scp';
     model = '/projects/speech/sys/kaldi-trunk/egs/shruti/s5_ini/exp/mono_ali2/final.mdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/shruti/s5_ini/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/shruti/s5_ini/data/train70_2/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/shruti1';
     audiodir = '/projects/speech/data/matlab-wav/shruti1';
   % This one doesnt copy audio.
   case 'bp1'
     alifile = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_UNAMBIG/exp/mono_ali2/ali.1.gz';
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_UNAMBIG/data/train2/wav.scp';
     model = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_UNAMBIG/exp/mono_ali2/final.mdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_UNAMBIG/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_UNAMBIG/data/train2/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/bp1';
   case 'ls3a'
     alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/alig.1.gz';
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/wav.scp';
     model = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/final.alimdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/lang_nosp/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/text';
     audiodir = [audiobase '/' name];
     datbase = [datdir '/' name]; 
   case 'ls3ademo'
     alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/alig.1a.gz';
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/wav.scp';
     model = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/final.alimdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/lang_nosp/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/text';
     audiodir = [audiobase '/' name];
     datbase = [datdir '/' name]; 
   % Something wrong about the phones as they are displayed.
   case 'lsdemox'
     alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/exp/tri3b_ali_clean_100/alig.1.gz';
     model =   '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/exp/tri3b_ali_clean_100/final.mdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/lang_nosp/phones.txt';
     wavscp =     '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/train_clean_100/wav.scp';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/train_clean_100/text';
     audiodir = [audiobase '/' name];
     datbase = [datdir '/' name];
   case 'ls3all'
    alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/alig.all.gz';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/wav.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/final.alimdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/lang_nosp/phones.txt';
    transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/ls3all';
   case 'etri10k'
    alifile = '/projects/speech/sys/kaldi-trunk/egs/etri/c1/exp/tri_ali2_10k/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/etri/c1/data/train_10k/wav.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/etri/c1/exp/tri_ali2_10k/final.mdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/etri/c1//data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-trunk/egs/etri/c1/data/train_10k/text'; 
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/etri10k';
    % Rewrite audio.
    audiodir = '/projects/speech/data/matlab-wav/etri10k';
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
    convert_ali(alifile,wavscp,model,phones,transcript,datbase,audiodir);
end
end



