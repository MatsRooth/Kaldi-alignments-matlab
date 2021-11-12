function convert_ali3(basic_ali,pdf_ali,phone_ali,phone_seq,wavscp,model,phones,transcript,savefile,audiodir)
%  Convert alignment data to a mat file.
%  If audiodir is given, write wav files there and store the audiodir
%  in dat.audiodir, and the wav file names in dat.wav.

% This version assumes alignments have been converted with prepare_ali.sh,
% and so does not run kaldi locally.  See load_ali3 for loading.

%  Conversion stores information which allows display or markup using a
%  token index.


% Default arguments 
if nargin < 1
  expbase =  '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/exp/tri3b_ali_clean_100_CAN';
  basic_ali = [expbase '/' 'ali.all.t'];
  pdf_ali = [expbase '/' 'pdf_ali'];
  phone_ali = [expbase '/' 'phone_ali'];
  phone_seq = [expbase '/' 'phone_seq'];
  wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/train_clean_100_V/wav.scp';
  model = 0;
  phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/lang_nosp/phones.txt';
  transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5_word/data/train_clean_100_CAN/text';
  savefile = '/Volumes/gray/matlab/matlab-mat/lsCAN2';
  audiodir = 0;
end
 

% Read wav file and alignment for all the utterance IDs.
% Map from uid to wav launch pipes.
% This is not used if audio is not written (audiodir=0).
Scp = load_kaldi_wavscp(wavscp);

% Read transcript.
Tra = load_kaldi_transcript(transcript);

% For mapping back and forth between phones and their indices.
P = PhoneIndexer(phones);

% Load the alignments in various formats.
% Cell array of Uid, and cell array of alignment vectors.
[Uid,Basic,Align_pdf,Align_phone,Phone_seq] = load_ali3(basic_ali,pdf_ali,phone_ali,phone_seq);
 
dat.scp = Scp;      % Map indexed by uid, e.g. dat.scp(dat.uid{10}). 
dat.tra = Tra;      % Map indexed by uid, e.g. dat.tra(dat.uid{10}).
dat.phone_indexer = P;
dat.uid = Uid;      % Cell array indexid by nat, e.g. dat.uid{10} is 10th uid.
dat.basic = Basic;  % Cell array indexed by nat, value is a cell vector with char contents.
                    % It should be a vector of nat.
dat.pdf = Align_pdf;
dat.align_phone = Align_phone;
dat.phone_seq = Phone_seq;

% Number of utterances, indices are [1:N].
[~,N] = size(Uid)
dat.N = N;

% Map from uid to index, used when indexing by token.
dat.um = containers.Map;

for j = [1:N]
   uid = Uid{j};
   dat.um(uid) = j;
end

if (audiodir ~= 0)
    dat.audiodir = audiodir;
    Wav = {};
    convert_audio(N);
    dat.wav = Wav;
end

disp(savefile);

save(savefile,'dat');

    function convert_audio(n)
        for j = 1:n
            uid = Uid{j};
            scp = Scp(Uid{j});
            wav = [audiodir '/' uid '.wav'];
            Wav{j} = [uid '.wav']; 
            cmd = [Scp(uid), ' cat > ' wav];
            %disp(j);
            %disp(cmd);
            %disp(scp);
            %disp(wav)
            % This somehow fixes flacLIB problem.
            setenv('DYLD_LIBRARY_PATH','');
            setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
            system(cmd);
        end
    end

    function convert_korean_audio(n)
        for j = 1:n
            % ko_4012_100291-100365
            uid = Uid{j};
            A = strsplit(uid,'_');
            wavid = [A(1),'_',A(2)];
            % Name of wav file to write
            wav = [audiodir '/' uid '.wav'];
            Wav{j} = [uid '.wav']; 
            cmd = [Scp(wavid), ' cat > ' wav];
            disp(j);
            disp(cmd);
            disp(scp);
            disp(wav)
            % This somehow fixes flacLIB problem.
            setenv('DYLD_LIBRARY_PATH','');
            setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
            system(cmd);
        end
    end

end

% Dependencies
% matlab.codetools.requiredFilesAndProducts('convert_ali.m')
    %'/local/matlab/Kaldi-alignments-matlab/convert_ali.m'
    %'/local/matlab/Kaldi-alignments-matlab/load_ali2.m'
    %'/local/matlab/Kaldi-alignments-matlab/load_kaldi_transcript.m'
    %'/local/matlab/Kaldi-alignments-matlab/load_kaldi_wavscp.m'
    %'/local/matlab/Kaldi-alignments-matlab/phone_indexer.m'