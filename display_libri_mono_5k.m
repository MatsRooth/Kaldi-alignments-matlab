function display_libri_mono_5k()
%  Librispeech mono 5k alignments.

% This is giving
% Error in load_ali (line 51)
% Error using cell
% NaN and Inf not allowed.
%
%

EGS = '/projects/speech/sys/kaldi-trunk/egs/';

alifile = [EGS,'librispeech/s5/exp/mono_ali_5k/ali.all-t.gz'];
wavscp = [EGS,'librispeech/s5/data/train_5k/wav.scp'];
model = [EGS,'librispeech/s5/exp/mono_ali_5k/final.mdl'];
phones = [EGS,'librispeech/s5/data/lang_nosp/phones.txt'];
% 5k training data
transcript = [EGS,'librispeech/s5/data/train_5k/text'];

% Make flac available. The second is causing a warning.
setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
setenv('DYLD_LIBARARY_PATH', '/opt/local/lib:/usr/local/lib:/usr/lib');

% Run display program.
display_ali(alifile,wavscp,model,phones,transcript);

end

