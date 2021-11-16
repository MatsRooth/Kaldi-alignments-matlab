function convert_CAN(part)
%  in the 360 or 500 data.

if nargin < 1
  part = 360;
end


if (part == 360)
 expbase =  '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/exp/tri3b_ali_clean_360_CAN';
 basic_ali = [expbase '/' 'ali.all.t'];
 pdf_ali = [expbase '/' 'pdf_ali'];
 phone_ali = [expbase '/' 'phone_ali'];
 phone_seq = [expbase '/' 'phone_seq'];
 wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/train_clean_360_CAN/wav.scp';
 model = 0;
 phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/lang_nosp/phones.txt';
 transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/train_clean_360_CAN/text';
 savefile = '/Volumes/gray/matlab/matlab-mat/can360';
 %audiodir = '/Volumes/gray/matlab/matlab-wav/ls360';
 
 audiodir = 0;
 
 convert_ali3(basic_ali,pdf_ali,phone_ali,phone_seq,wavscp,model,phones,transcript,savefile,audiodir)
end

if (part == 500)
 expbase =  '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/exp/tri3b_ali_clean_500_CAN';
 basic_ali = [expbase '/' 'ali.all.t'];
 pdf_ali = [expbase '/' 'pdf_ali'];
 phone_ali = [expbase '/' 'phone_ali'];
 phone_seq = [expbase '/' 'phone_seq'];
 wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/train_other_500_CAN/wav.scp';
 model = 0;
 phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/lang_nosp/phones.txt';
 transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/train_other_500_CAN/text';
 savefile = '/Volumes/gray/matlab/matlab-mat/can500';
 audiodir = '/Volumes/gray/matlab/matlab-wav/ls500';
 
 convert_ali3(basic_ali,pdf_ali,phone_ali,phone_seq,wavscp,model,phones,transcript,savefile,audiodir)
end

end