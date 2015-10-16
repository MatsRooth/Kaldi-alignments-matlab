function [uid,PH,SU,PHstart,PHend,SUstart,SUend] = parse_ali(Uid,Align_pdf,Align_phone,n)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Return values.
% PH frame k is in the PH(k)'th phone of the utterance.
% SU Frame k is in the PH(k)'th subphone of the utterance.
% PHstart The j'th phone in the uttererance starts at frame PHstart(j).
% PHend The j'th phone in the uttererance ends at frame PHend(j).
% SUstart The j'th subphone in the uttererance starts at frame PHstart(j).
% SUend The j'th subphone in the uttererance ends at frame PHend(j).

% Default argument. Need adjustment
if nargin < 3
    [Uid,Align_pdf] = load_ali2();
    n = 1;
end

% Scp = load_kaldi_wavscp();

% Uid(n) is a cell containting a string, rather than a string.
% Somehow this converts it.
uid = cell2mat(Uid(n));
% Vector of pdf indices of sub-phones.  Align(n) is a cell array, convert
% it to a matrix.
alipdf = cell2mat(Align_pdf(n));
aliphone = cell2mat(Align_phone(n));

% cmd = [Scp(uid), ' cat > /tmp/align3_tmp.wav'];
% disp(cmd);
% system(cmd);
% wav = '/tmp/align3_tmp.wav';

% [w,fs] = wavread(wav);
% sound(w,fs);

% Number of frames in the utterance.
[~,N] = size(alipdf);

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
PHstart = zeros(1,N);
PHend = zeros(1,N);
SUstart = zeros(1,N);
SUend = zeros(1,N);

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

% Remaining number of frames for current phone, including 
% the current one.
rem = aliphone(2,pi);



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
            rem = aliphone(2,pi);
        end 
    end
    % Record phone and subphone indices for current frame.
    PH(j) = pi;
    SU(j) = si;
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

