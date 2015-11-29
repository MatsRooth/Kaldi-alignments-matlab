function display_libri_mono()
%  UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

alifile = '/Volumes/NONAME/speech/librispeech/s5/exp/mono_ali_5k/ali.all-t.gz';
wavscp = '/Volumes/NONAME/speech/librispeech/s5/data/train_5k/wav.scp';
model = '/Volumes/NONAME/speech/librispeech/s5/exp/mono_ali_5k/final.mdl';
phones = '/Volumes/NONAME/speech/librispeech/s5/data/lang_nosp/phones.txt';
% 5k training data
transcript = '/Volumes/NONAME/speech/librispeech/s5/data/train_5k/text';
 % Make flac available. The second is causing a warning.
setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
setenv('DYLD_LIBARARY_PATH', '/opt/local/lib:/usr/local/lib:/usr/lib');

% Run display program.
display_ali(alifile,wavscp,model,phones,transcript);

end

