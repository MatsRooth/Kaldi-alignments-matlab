function display_tri1()
%  UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

alifile = '/local/Matlab/Kaldi-alignments-matlab/data/tri1-ali.gz';
wavscp = '/local/Matlab/Kaldi-alignments-matlab/data/tri1-wav.scp';
model = '/Volumes/NONAME/speech/librispeech/s5/exp/tri4b/final.mdl';
phones = '/Volumes/NONAME/speech/librispeech/s5/data/lang_nosp/phones.txt';
transcript = '/local/Matlab/Kaldi-alignments-matlab/data/tri1-text';
 
 % Make flac available
setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
setenv('DYLD_LIBARARY_PATH', '/opt/local/lib:/usr/local/lib:/usr/lib');

% Run display program.
display_ali(alifile,wavscp,model,phones,transcript);

end

