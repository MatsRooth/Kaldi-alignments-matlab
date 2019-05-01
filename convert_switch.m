function datfile = convert_switch(name)
% Use convert_ali to convert an alignment directory and related data to a
% .mat file. This saves time when browsing data.  If audiodir is specified,
% in the switch, then audio is converted to wav and copied. This is useful 
% for sharing data, but takes space.

% NEED to track down issues with location of local kaldi-trunk. It's not in
% /projects.

if (nargin < 1)
    name = 'seoul_10k';
end

datfile = 0;
audiodir = 0;
audiobase = '/projects/speech/data/matlab-wav';
datdir = '/projects/speech/data/matlab-mat';
bpf = '/Volumes/F/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint';

% If audiodir is not specified, then audio is not converted and copied.
% The result stores the complete pathname of the audio --
% make sure canonical pathnames are in use.

switch name
    case 'bpn'
     % n stress disambiguation
     % This converts without re-writing audio.
     % With ali.1.gz this is 1/4 of the data, 1971 utterances.
     alifile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/Unigr_s5_NLex/exp/mono_aliWORD2/ali.1.gz';  
     wavscp = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/trainWORD2/wav.scp';
     model = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/Unigr_s5_NLex/exp/mono_aliWORD2/final.mdl';
     phones = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/trainWORD2/text';
     datbase = '/projects/speech/data/matlab-mat/bpn';
    case 'bpnf'
    % n stress disambiguation, final version
    % This converts without re-writing audio.
    % 
     % alifile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/exp/mono_ali1N/ali.1.gz';  
     alifile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/exp/mono_ali1N/ali.all.gz';
     wavscp = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/data/test1N/wav.scp';
     model = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/exp/mono_ali1N/final.mdl';
     phones = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/data/test1N/text';
     % bpnf1 is the first 1/4
     datbase = '/projects/speech/data/matlab-mat/bpnf';
   case 'bp0V'
    % Aligned from start without stress.
    % See data/train0V and exp/mono_ali0V
    % This converts without rewriting audio.
     % alifile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/exp/mono_ali0V/ali.1.gz';  
     alifile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/exp/mono_ali0V/ali.all.gz';
     wavscp = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/data/train0V/wav.scp';
     model = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/exp/mono_ali0V/final.mdl';
     phones = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Final/data/train0V/text';
     % bpnf1 is the first 1/4
     datbase = '/projects/speech/data/matlab-mat/bp0V';
   case 'bp3'
     % This converts without re-writing audio.
     alifile = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/exp/mono_aliWORD2/ali.all.gz'; 
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/data/trainWORD2/wav.scp';
     model = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/exp/mono_aliWORD2/final.mdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigram_s5_ALLSTEPS/data/trainWORD2/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/bp3';
   case 'bp0SZ'
     % This converts without re-writing audio.
     alifile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/exp/mono_ali0SZ/ali.all.gz'; 
     wavscp = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/data/train0SZ/wav.scp';
     model = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/exp/mono_ali0SZ/final.mdl';
     phones = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/data/train0SZ/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/bp0SZ';
   case 'bp1SZ'
     % This converts without re-writing audio.
     alifile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/exp/mono_ali1SZ/ali.all.gz'; 
     wavscp = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/data/train0SZ/wav.scp';
     model = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/exp/mono_ali1SZ/final.mdl';
     phones = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/s5_Interspeech/data/train1SZ/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/bp1SZ';
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
   case 'Unigr_s5_NLex1'
     alifile = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/exp/mono_aliWORD2/ali.1.gz'; %
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/trainWORD2/wav.scp'; %
     model = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/exp/mono_aliWORD2/final.mdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/trainWORD2/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/Unigr_s5_NLex1';
     audiodir = '/projects/speech/data/matlab-wav/Unigr_s5_NLex1'
   case 'Unigr_s5_NLex'
     alifile = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/exp/mono_aliWORD2/ali.all.gz'; %
     wavscp = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/trainWORD2/wav.scp'; %
     model = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/exp/mono_aliWORD2/final.mdl';
     phones = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/lang/phones.txt';
     transcript = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/Unigr_s5_NLex/data/trainWORD2/text';
     datbase = '/local/matlab/Kaldi-alignments-matlab/data/Unigr_s5_NLex';
     % Don't save audio.
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
   case 'ls3mono100'  % This dates from 2015, check where it came from.
    alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/exp/mono2_ali_clean_100k/ali.all.gz'; % 28539 utterances.
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/train_clean_100/wav.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/exp/mono2_ali_clean_100k/final.mdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/lang_nosp/phones.txt';
    transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/train_clean_100/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/ls3mono100';
    audiodir = 0; % Don't copy audio.  Create only ls3mono100.mat.
   case 'vm1a'
    alifile = '/projects/speech/sys/kaldi-master/egs/vm1_copy/exp/mono_ali/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-master/egs/vm1_copy/data/train/wav.scp';
    model = '/projects/speech/sys/kaldi-master/egs/vm1_copy/exp/mono_ali/final.mdl';
    phones = '/projects/speech/sys/kaldi-master/egs/vm1_copy/data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-master/egs/vm1_copy/data/train/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/vm1a';
   case 'spanish1a'
    alifile = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-jms852/exp/mono_ali/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-bjc267/train/wav_cut.scp';
    model = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-jms852/exp/mono_ali/final.mdl';
    phones = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-jms852/data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-jms852/data/train/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/spanish1a';
    audiodir = '/projects/speech/data/matlab-wav/spanish1a';
   case 'spanish1b'
    alifile = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-phoneticLex/exp/mono_ali/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-phoneticLex-mr249/data/train/wav2.scp';
    model = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-phoneticLex/exp/mono_ali/final.mdl';
    phones = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-phoneticLex/data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-master/egs/fisher_callhome_spanish/s5-phoneticLex/data/train/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/spanish1b';
    audiodir = '/projects/speech/data/matlab-wav/spanish1b';
   case 'seoul_10k'
    alifile = '/projects/speech/sys/kaldi-master/egs/seoul/s5/exp/mono_ali_10k/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-master/egs/seoul/s5/data/train_10k/pword-wav.scp';
    model = '/projects/speech/sys/kaldi-master/egs/seoul/s5/exp/mono_ali_10k/final.mdl';
    phones = '/projects/speech/sys/kaldi-master/egs/seoul/s5/data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-master/egs/seoul/s5/data/train_10k/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/seoul_10k';
    audiodir = 0;
   case 'korean1a'
    alifile = '/projects/speech/sys/kaldi-master/egs/korean/c1-hm375/exp/mono_ali/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-master/egs/korean/c1-hm375/data/train/wav-uid.scp';
    model = '/projects/speech/sys/kaldi-master/egs/korean/c1-hm375/exp/mono_ali/final.mdl';
    phones = '/projects/speech/sys/kaldi-master/egs/korean/c1-hm375/data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-master/egs/korean/c1-hm375/data/train/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/korean1a';
   case 'korean2'
    alifile = '/projects/speech/sys/kaldi-master/egs/korean/s5/exp/mono_ali1/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-master/egs/korean/c1-hm375/data/train/wav-uid.scp';
    model = '/projects/speech/sys/kaldi-master/egs/korean/s5/exp/mono_ali1/final.mdl';
    phones = '/projects/speech/sys/kaldi-master/egs/korean/s5/data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-master/egs/korean/s5/data/train70_1/text';
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/korean2';
   case 'etri10k'
    alifile = '/projects/speech/sys/kaldi-trunk/egs/etri/c1/exp/tri_ali2_10k/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/etri/c1/data/train_10k/wav.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/etri/c1/exp/tri_ali2_10k/final.mdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/etri/c1//data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-trunk/egs/etri/c1/data/train_10k/text'; 
    datbase = '/local/matlab/Kaldi-alignments-matlab/data/etri10k';
    % Rewrite audio.
    audiodir = '/local/tmp/etri10k';
   case 'bp_ne_func_nplus1' % Basic disambiguation with n+1 options.
    alifile = [bpf '/Unigram_s5_NE_FUNC/exp/mono_aliWORD2/ali.all.gz']; 
    wavscp = [bpf '/Unigram_s5_NE_FUNC/data/trainWORD2/wav.scp'];
    model = [bpf '/Unigram_s5_NE_FUNC/exp/mono_aliWORD2/final.mdl'];
    phones = [bpf '/Unigram_s5_NE_FUNC/data/lang/phones.txt'];
    transcript = [bpf '/Unigram_s5_NE_FUNC/data/trainWORD2/text'];
    datbase = '/projects/speech/data/matlab-mat/bp_ne_func_nplus1';
    % Rewrite audio.
    audiodir = '/projects/speech/data/matlab-wav/bp_ne_func_nplus1';
   case 'bp_ne_func_two_n' % Basic disambiguation with two to n options.
    alifile = [bpf '/Unigram_s5_NE_FUNC/exp/mono_aliWORD3/ali.all.gz']; 
    wavscp = [bpf '/Unigram_s5_NE_FUNC/data/trainWORD3/wav.scp'];
    model = [bpf '/Unigram_s5_NE_FUNC/exp/mono_aliWORD3/final.mdl'];
    phones = [bpf '/Unigram_s5_NE_FUNC/data/lang/phones.txt'];
    transcript = [bpf '/Unigram_s5_NE_FUNC/data/trainWORD3/text'];
    datbase = '/projects/speech/data/matlab-mat/bp_ne_func_two_n';
    % Rewrite audio.
    audiodir = '/projects/speech/data/matlab-wav/bp_ne_func_two_n';
   case 'bp_ne_func_stsh' % Stress shift
    alifile = [bpf '/Unigram_s5_NE_FUNC/exp/mono_testStShWORD2/ali.all.gz']; 
    wavscp = [bpf '/Unigram_s5_NE_FUNC/data/testStShWORD2/wav.scp'];
    model = [bpf '/Unigram_s5_NE_FUNC/exp/mono_testStShWORD2/final.mdl'];
    phones = [bpf '/Unigram_s5_NE_FUNC/data/lang/phones.txt'];
    transcript = [bpf '/Unigram_s5_NE_FUNC/data/testStShWORD2/text'];
    datbase = '/projects/speech/data/matlab-mat/bp_ne_func_stsh';
    audiodir = '/projects/speech/data/matlab-wav/bp_ne_func_stsh';
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



