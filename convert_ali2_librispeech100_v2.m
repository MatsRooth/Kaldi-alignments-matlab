function convert_ali2_librispeech100_v2()
%  Convert alignment data to a mat file.
 
    alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/exp/tri3b_ali_clean_100_V/ali.all.gz';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/train_clean_100_V/wav.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/exp/tri3b_ali_clean_100_V/final.alimdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/lang_nosp/phones.txt';
	transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/train_clean_100_V/text';
    savefile = '/projects/speech/data/matlab-mat/librispeech100_v2';
    audiodir = '/projects/speech/data/matlab-wav/librispeech100_v2';

  convert_ali2(alifile,wavscp,model,phones,transcript,savefile,audiodir);
  
% The process assumes that the paths to flac files in wavscp are correct on
% the local machine, e.g.
% /projects/speech/data/librispeech/LibriSpeech/train-clean-100/103/1240/103-1240-0009.flac.
% I have these files in /Volumes/Gray/projects, which is mounted on
% /projects on the mac.  All of this assumes /projects paths are the same
% on different machines.

% Kaldi programs are working.
% flac conversion?
end



