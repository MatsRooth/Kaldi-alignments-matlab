function convert_ali(alifile,wavscp,model,phones,transcript,savefile,audiodir)
%  Convert alignment data to a mat file.
%  If audiodir is given, write wav files there and store the audiodir
%  in dat.audiodir, and the wav file names in dat.wav.

%  Conversion stores information which allows display or markup using a
%  token index.

% May need addpath('/local/matlab/voicebox')

if nargin < 7
    audiodir = 0;
end

% Default argument  
if nargin < 6
    alifile = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/exp/tri4b/ali-e2.gz';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/train_clean_100/wav-e2.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/exp/tri4b/final.mdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/lang_nosp/phones.txt';
	transcript = '/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/train_clean_100/text-e2';
    savefile = '/local/matlab/Kaldi-alignments-matlab/data/tri4b-e2';
    audiodir = '/Volumes/B/speech/kaldi-wav/tri4b-e2';
end

% Read wav file and alignment for all the utterance IDs.
% Map from uid to wav launch pipes.
Scp = load_kaldi_wavscp(wavscp);

% Read transcript.
Tra = load_kaldi_transcript(transcript);

% For mapping back and forth between phones and their indices.
% Switch to true object orientation.
% P = phone_indexer(phones);
P = PhoneIndexer(phones);

% Create and load the alignments in various formats.
% Cell array of Uid, and cell array of alignment vectors.
%[Uid,Wrd,Basic,Pdf,Phone,Phone_seq]
[Uid,Basic,Align_pdf,Align_phone,Phone_seq] = load_ali2(alifile,model);
 
dat.scp = Scp;      % Map indexed by uid, e.g. dat.scp(dat.uid{10}). 
dat.tra = Tra;      % Map indexed by uid, e.g. dat.tra(dat.uid{10}).
dat.phone_indexer = P;
dat.uid = Uid;      % Cell array indexid by nat, e.g. dat.uid{10} is 10th uid.
dat.basic = Basic;  % Cell array indexed by nat, value is a cell vector with char contents.
                    % It should be a vector of nat.
dat.pdf = Align_pdf;
dat.align_phone = Align_phone;
dat.phone_seq = Phone_seq;

[~,N] = size(Uid);
% Number of utterances, indices are [1:N].
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

end

% Dependencies
% matlab.codetools.requiredFilesAndProducts('convert_ali.m')
    %'/local/matlab/Kaldi-alignments-matlab/convert_ali.m'
    %'/local/matlab/Kaldi-alignments-matlab/load_ali2.m'
    %'/local/matlab/Kaldi-alignments-matlab/load_kaldi_transcript.m'
    %'/local/matlab/Kaldi-alignments-matlab/load_kaldi_wavscp.m'
    %'/local/matlab/Kaldi-alignments-matlab/phone_indexer.m'