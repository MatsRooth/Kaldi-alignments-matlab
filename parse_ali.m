function [F,Sb,Pb,Wb,tra] = parse_ali(uid,Align_pdf,Align_phone,Tra,P,n)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Return values.
% F subphone/phone/word occupying each frame
%   column index: frames
%   row 1: index of token subphone that the frame is in
%   row 2: index of token phone that the frame is in
%   row 3: index of token word that the frame is in

% Sb where n is the number of token subphones, a
%  2xn matrix giving frame index of the first frame (first row)
%  and last frame (second row) for each token subphone.
% The subphone index is the column index, and first (1)/last (2) is the row
% index. 


% Pb where n is the number of token phones, a
%  2xn matrix giving frame index of the first frame (first row)
%  and last frame (second row) for each token phone.
% The phone index is the column index, and first (1)/last (2) is the row
% index.

% Wb where n is the number of words, a
%  2xn matrix giving frame index of the first frame (first row)
%  and last frame (second row) for each word.
% The word index is the column index, and first (1)/last (2) is the row
% index.

% Tra cell array of words in the utterance.

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

% Vector indexed by frames giving the pdf used for each frame.
alipdf = cell2mat(Align_pdf(n));

% Matrix index by token phone indices, giving the phone ID for each
% token phone in row 1, and the number of frames it occupies in row 2.
aliphone = cell2mat(Align_phone(n));

tra = Tra(uid);

% cmd = [Scp(uid), ' cat > /tmp/align3_tmp.wav'];
% disp(cmd);
% system(cmd);
% wav = '/tmp/align3_tmp.wav';

% [w,fs] = wavread(wav);
% sound(w,fs);

% Number of frames in the utterance.
%[~,N] = size(alipdf);
[~,Nf] = size(alipdf);

% Number of phones the utterance.
%[~,M] = size(aliphone);
[~,Np] = size(aliphone);

% Number of words the utterance.
[~,Nw] = size(tra);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Initialize return values. 
%  Documentation is at the start.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Indexed by frames.
% PH = zeros(1,N);
% SU = zeros(1,N);
% In row 1, the token supphone index occupying the frame.
% In row 2, the token phone index occupying the frame.
% In row 3, the token phone index occupying the frame.
F = zeros(3,Nf);

% Indexed by indices of phones in the utterance.
% PHstart = zeros(1,M);
% PHend = zeros(1,M);
% Phone indices.

% Start frame (row 1) and end frame (row 2) of the token phone.
% Entries are frame indices.
Pb = zeros(2,Np);

% Same for words.
Wb = zeros(2,Nw);

% Same for supphones. Nf is an upper bound on the number of suphones,
% trim the matrix later.
Sb = zeros(2,Nf);


% In row 2, the token phone index occupying the frame.


% SUstart = zeros(1,M);
% SUend = zeros(1,M);

% For each phone token, what word starts there (as index), or 0 for none?
% WRstart = zeros(1,M);

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
% PH(1) = pi;
% SU(1) = si;
F(1,1) = 1;
F(2,1) = 1;

% The first phone and subphone start at frame 1.
% PHstart(pi) = 1;
Pb(1,1) = 1;
% SUstart(si) = 1;
Sb(1,1) = 1;
% Current phone in index form.
pho = aliphone(1,pi);

% Remaining number of frames for current phone, including 
% the current one.
rem = aliphone(2,pi);

% word index
wi = 0;
% Like wi, but is 0 outside words.
wc = 0;
% Is the current frame in a word?
inword = 0;

% Does a word start already at frame 1?
if P.isbeginning(pho)
    wi = wi + 1;
    wc = wi;
    Wb(1,wi) = 1;
    inword = 1;
end
    

% For each frame starting after frame 1.
for j = 2:Nf
    rem = rem - 1;
    % If there is a new subphone. This can miss a non-final subphone when
    % pdfs are shared. The necessary information seems to not be available
    % in the output of the ali-to-xxxx programs.
    if alipdf(j-1) ~= alipdf(j) || rem == 0
        % SUend(si) = j - 1;
        % Mark end of previous token subphone.
        Sb(2,si) = j - 1;
        si = si + 1;
        % SUstart(si) = j;
        % Record start of new subphone.
        Sb(1,si) = j;
        % If there is an new phone according to aliphone
        % if rem == 0
        % if rem == 0 || alipdf(j) ~= alipdf(j-1) + 1
        if rem == 0 
            % PHend(pi) = j - 1;
            % Record end of previous phone.
            Pb(2,pi) = j - 1;
            % If phone filler is a word end, record the end of wi.
            % Without the check, this caused an error with wi = 0.
            if P.isend(pho) && wi > 0
                Wb(2,wi) = j - 1;
                wc = 0;
            end
            % increment token phone index
            pi = pi + 1;
            % Record start of new phone.
            % PHstart(pi) = j;
            Pb(1,pi) = j;
            % New phone filler and number of frames remaining.
            pho = aliphone(1,pi);
            rem = aliphone(2,pi);
            % If current phone filler is a word beginning.
            if P.isbeginning(pho)
                wi = wi + 1;
                wc = wi;
                % WRstart(pi) = wi;
                Wb(1,wi) = j;
            end
            % If current phone filler is a word end. For a singleton
            % it is both.
            %if P.isend(pho)
            %   Wb(2,wi) = j;
            %end
        end 
    end
    % Record token phone, token subphone, and token word indices for current frame.
    F(1,j) = si;
    F(2,j) = pi;
    F(3,j) = wc;
    % PH(j) = pi;
    % SU(j) = si;
    % WR(j) = wi;
end

% The last frame ends the last phone and the last subphone.
% PHend(pi) = N;
Pb(2,pi) = Nf;
Sb(2,si) = Nf;

% If the last word doesn't jave it's end marked, marked it as Nf.
if Wb(2,wi) == 0
    Wb(2,wi) = Nf;
end

% Reduce Sb and Pb to initial parts, since they
% are indexed as subphones or phones rather than frames.
Sb = Sb(:,1:si);

%SUstart = SUstart(1:si);
%SUend = SUend(1:si);
% The same for phones.
% PHstart = PHstart(1:pi);
% PHend = PHend(1:pi);
Pb = Pb(:,1:pi);
 
end

