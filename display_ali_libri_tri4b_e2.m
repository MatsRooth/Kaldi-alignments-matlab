function display_ali_libri_tri4b_e2()
%  Display a subset of 100 from Librispeech 100k triphone alignments.

EGS = '/projects/speech/sys/kaldi-trunk/egs/';

% The data files have 100 utterances. 

alifile = [EGS,'librispeech/s5/exp/tri4b/ali-e2.gz'];
% The entire set is 28539 librispeech/s5/data/train_clean_100/wav.scp.
wavscp = [EGS,'librispeech/s5/data/train_clean_100/wav-e2.scp'];
model = [EGS,'librispeech/s5/exp/tri4b/final.mdl'];
phones = [EGS,'librispeech/s5/data/lang_nosp/phones.txt'];
% The entire set is 28539 librispeech/s5/data/train_clean_100/text.
transcript = [EGS,'librispeech/s5/data/train_clean_100/text-e2'];

% Make flac available
setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
% This seems not to be necessary:
% setenv('DYLD_LIBARARY_PATH', '/opt/local/lib:/usr/local/lib:/usr/lib');

%system('which flac')
%system('echo $SHELL')

% Run display program.
display_ali(alifile,wavscp,model,phones,transcript);

end

