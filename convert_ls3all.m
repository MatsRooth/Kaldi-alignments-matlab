function convert_ls3all()

% Convert all the librispeech 100 data, writing wav files to an audio
% directory.

% The conversion worked 

% These paths are as on kay, ane are locally on Gray (Samsung SSD).

alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/alig.all.gz';
wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/wav.scp';
model = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/exp/tri3b_ali_clean_100_V/final.alimdl';
phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/lang_nosp/phones.txt';
transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/text';

% Base of the mat file.,
savefile = '/Volumes/gray/matlab/matlab-mat/ls3all';
% Directory for wav files. The size is 11G.
audiodir = '/Volumes/gray/matlab/matlab-wav/ls3all';
  
% Run conversion program. Dpn't use convert_ali, it broke because of Matlab
% changes.
convert_ali2(alifile,wavscp,model,phones,transcript,savefile,audiodir);
end


