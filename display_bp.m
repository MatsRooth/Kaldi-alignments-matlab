function display_bp()
%  UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

alifile = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/s5/exp/mono/ali.1.gz';
wavscp = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/s5/data/train/wav.scp';
model = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/s5/exp/mono/final.mdl';
phones = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/s5/data/lang/phones.txt';
transcript = '/projects/speech/sys/kaldi-trunk/egs/bp_ldcWestPoint/s5/data/train/text';


% Make flac available
%setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
% setenv('DYLD_LIBARARY_PATH', '/opt/local/lib:/usr/local/lib:/usr/lib');
% Run display program.
%system('which flac');
%system('echo $SHELL')
%display_ali(alifile,wavscp,model,phones,transcript);

display_ali(alifile,wavscp,model,phones,transcript);

end

