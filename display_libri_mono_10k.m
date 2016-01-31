function display_libri_mono_10k()
%  Librispeech mono 10k alignments.

% This is giving an error, presumably related to Ethan's updates to
% load_ali.
% Error using cell
% NaN and Inf not allowed.

% Error in load_ali (line 51)
%  Key = cell(1, num_lines); Basic = cell(1, num_lines);

EGS = '/projects/speech/sys/kaldi-trunk/egs/';

alifile = [EGS,'librispeech/s5/exp/mono_ali_10k/ali.all-t.gz'];
wavscp = [EGS,'librispeech/s5/data/train_10k/wav.scp'];
model = [EGS,'librispeech/s5/exp/mono_ali_10k/final.mdl'];
phones = [EGS,'librispeech/s5/data/lang_nosp/phones.txt'];
transcript = [EGS,'librispeech/s5/data/train_10k/text'];
 % Make flac available. The second is causing a warning.
setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');

% Run display program.
display_ali(alifile,wavscp,model,phones,transcript);

end

