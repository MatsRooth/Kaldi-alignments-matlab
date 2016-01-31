function display_ali_libri_mono()
%  Display Librispeech 100k mono alignments.

EGS = '/projects/speech/sys/kaldi-trunk/egs/';

alifile = [EGS, 'librispeech/s5/exp/mono/ali.all.gz'];
wavscp = [EGS, 'librispeech/s5/data/train_clean_100/wav.scp'];
model = [EGS,'librispeech/s5/exp/mono/final.mdl'];
phones = [EGS,'librispeech/s5/data/lang_nosp/phones.txt'];
transcript = [EGS,'librispeech/s5/data/train_clean_100/text'];

% Make flac available
setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
% setenv('DYLD_LIBARARY_PATH', '/opt/local/lib:/usr/local/lib:/usr/lib');
% Run display program.
system('which flac');
system('echo $SHELL')
display_ali(alifile,wavscp,model,phones,transcript);

end

