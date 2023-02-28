function convert_target(target,part)

if nargin < 1
  target = 'in+my+experience';
  part = '2000';
end

% /local/res/fiyou/kaldi/exp/tri3b_in+my+car/convert
fiyou = '/local/res/fiyou';
base = [target '_' part];
exp =       [fiyou '/kaldi/exp'];
convert =   [exp '/' 'tri3b_' base '/convert'];
basic_ali = [convert '/ali.all-t'];
pdf_ali =   [convert '/pdf_ali'];
phone_ali = [convert '/phone_ali'];
phone_seq = [convert '/phone_seq'];
train =     [fiyou '/kaldi/data/' base];
wavscp =    [train '/wav.scp'];
text =      [train '/text']; 
model =     0;
phones =    [convert '/' 'phones.txt'];
savebase =  [fiyou '/' 'matlab' '/' base];
audiodir =  0;

disp( basic_ali );
disp( text );
convert_ali3(basic_ali,pdf_ali,phone_ali,phone_seq,wavscp,model,phones,text,savebase,audiodir)

end

