function [PH,SU,PHstart,PHend,SUstart,SUend,WRstart,tra] = parse_ali(uid,Align_pdf,Align_phone,Tra,P,n)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Return values.
% PH frame k is in the PH(k)'th phone of the utterance.
% SU frame k is in the PH(k)'th subphone of the utterance.
% WO frame k is in the WO(k)'th word of the utternance.
% PHstart The j'th phone in the uttererance starts at frame PHstart(j).
% PHend The j'th phone in the uttererance ends at frame PHend(j).
% SUstart The j'th subphone in the uttererance starts at frame PHstart(j).
% SUend The j'th subphone in the uttererance ends at frame PHend(j).
% WOstart The j'th phone in the uttererance starts at frame WOstart(j).
% WOend The j'th phone in the uttererance ends at frame WOend(j).

% Default argument. Need adjustment
if nargin < 3
    [Uid,~,Align_pdf,~,Align_phone] = load_ali();
    Tra = load_kaldi_transcript('/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/train/text');
    P = phone_indexer('/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/lang/phones.txt');
    n = 1;
    uid = cell2mat(Uid(n));
end

% Scp = load_kaldi_wavscp();

% Uid(n) is a cell containting a string, rather than a string.
% Somehow this converts it.
% uid = cell2mat(Uid(n));
% Vector of pdf indices of sub-phones.  Align(n) is a cell array, convert
% it to a matrix.
alipdf = cell2mat(Align_pdf(n));
aliphone = cell2mat(Align_phone(n));

tra = Tra(uid);

% cmd = [Scp(uid), ' cat > /tmp/align3_tmp.wav'];
% disp(cmd);
% system(cmd);
% wav = '/tmp/align3_tmp.wav';

% [w,fs] = wavread(wav);
% sound(w,fs);

% Number of frames in the utterance.
[~,N] = size(alipdf);

% Number of phones the utterance.
[~,M] = size(aliphone);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Initialize return values. 
%  Documentation is at the start.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Indexed by frames.
PH = zeros(1,N);
SU = zeros(1,N);

% Indexed by indices of phones in the utterance.
PHstart = zeros(1,M);
PHend = zeros(1,M);
SUstart = zeros(1,M);
SUend = zeros(1,M);

% For each phone token, what word starts there (as index), or 0 for none?
WRstart = zeros(1,M);

% Phone and subphone indices used in the frame iteration.  
pi = 1;
si = 1; 

% Phone index for aliphone, differs from pi for silences.
% pii = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Set values for frame 1, phone 1, and subphone 1.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The first frame is in phone 1 and subphone 1.
PH(1) = pi;
SU(1) = si;

% The first phone and subphone start at frame 1.
PHstart(pi) = 1;
SUstart(si) = 1;

% Current phone in index form.
pho = aliphone(1,pi);

% Remaining number of frames for current phone, including 
% the current one.
rem = aliphone(2,pi);

% word index
wi = 0;

% For each frame starting after frame 1.
for j = 2:N
    rem = rem - 1;
    % If there is a new subphone.
    if alipdf(j-1) ~= alipdf(j)
        SUend(si) = j - 1;
        si = si + 1;
        SUstart(si) = j;
        % If there is an new phone according to aliphone
        % if rem == 0
        % if rem == 0 || alipdf(j) ~= alipdf(j-1) + 1
        if rem == 0 
            PHend(pi) = j - 1;
            pi = pi + 1;
            PHstart(pi) = j;
            pho = aliphone(1,pi);
            rem = aliphone(2,pi);
            if P.isbeginning(pho)
                wi = wi + 1;
                WRstart(pi) = wi;
            end
        end 
    end
    % Record phone, subphone, and word indices for current frame.
    PH(j) = pi;
    SU(j) = si;
    WR(j) = wi;
end

% The last frame ends the last phone and the last subphone.
PHend(pi) = N;
SUend(si) = N;

% Reduce these vectors to initial segments, since they
% are indexed as subphones rather than frames.
SUstart = SUstart(1:si);
SUend = SUend(1:si);
% The same for phones.
PHstart = PHstart(1:pi);
PHend = PHend(1:pi);
 
end

