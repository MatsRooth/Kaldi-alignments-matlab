function [uid,PH,SU,PHstart,PHend,SUstart,SUend] = parse_ali1(Uid,Align,n)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Default argument  
if nargin < 3
    [Uid,Align] = load_ali();
    n = 1;
end

% Scp = load_kaldi_wavscp();

% Uid(n) is a cell containting a string, rather than a string.
% Somehow this converts it.
uid = cell2mat(Uid(n));
% Vector of pdf indices of sub-phones.  Align(n) is a cell array, convert
% it to a matrix.
alipdf = cell2mat(Align(n));

% cmd = [Scp(uid), ' cat > /tmp/align3_tmp.wav'];
% disp(cmd);
% system(cmd);
% wav = '/tmp/align3_tmp.wav';

% [w,fs] = wavread(wav);
% sound(w,fs);

% Number of frames.
[~,N] = size(alipdf);

% Return values.
% Phone index for each frame -- which phone is the frame in?
PH = zeros(1,N);
% Subphone index for each frame -- which subphone is the frame in?
SU = zeros(1,N);

% For each phone, the frame index of the start of that phone.
% This is later cut to the number of phones.
PHstart = zeros(1,N);
% For each phone, the frame index of the end of that phone.
PHend = zeros(1,N);
% Similarly for subphones.
SUstart = zeros(1,N);
SUend = zeros(1,N);

% Phone and subphone indices used in the frame iteration.  
pi = 1;
si = 1; 

% The first frame is in phone 1 and subphone 1.
PH(1) = pi;
SU(1) = si;

% The first phone starts in frame 1.
PHstart(pi) = 1;
% The first subphone starts in frame 1.
SUstart(si) = 1;

% For each frame starting after frame 1.
for j = 2:N
    % If there is a new subphone.
    if alipdf(j-1) ~= alipdf(j)
        SUend(si) = j - 1;
        si = si + 1;
        SUstart(si) = j;
        % If there is an new phone (condition is placeholder)
        if alipdf(j) ~= alipdf(j-1) + 1
            PHend(pi) = j - 1;
            pi = pi + 1;
            PHstart(pi) = j;
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

