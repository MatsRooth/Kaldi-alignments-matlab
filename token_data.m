function token_data(datfile,tokenfile,outfile)
% Add some columns to a token file. The result looks like this.
%103-1240-0044-V	12	321	333	WILLih1	WAH0L
%103-1240-0050-V	35	924	935	WILLih1	WAH0L
%103-1240-0054-V	43	1273	1295	WILLih1	WIH1L
%103-1241-0031-V	27	687	711	WILLih1	WAH0L
%   uid, offset, frame start, frame end, word form
if nargin < 4
    audiodir = 0;
end

if nargin < 3
    framec = 100;
end

% Default for demo.
if nargin < 1
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3all.mat';
    tokenfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3-WILLih1a.tok';
    outfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3-WILLih1b.tok';
end
 
% Load sets dat to a structure. It has to be initialized first.
dat = 0;
load(datfile);

Scp = dat.scp;
P = dat.phone_indexer;
Uid = dat.uid;
% Wrd = dat.wrd;
Basic = dat.basic;
Align_pdf = dat.pdf;
Align_phone = dat.align_phone;
Align_phone_len = dat.phone_seq;
Tra = dat.tra;



% Cell array of uids for tokens.
Tu = {};
% Vector of word offsets for tokens.
To = [];

% Load the token data.
% Running index.
j = 1;
token_stream = fopen(tokenfile);

itxt = fgetl(token_stream);
while ischar(itxt)
    itxt = strtrim(itxt);
    part = strsplit(itxt);
    uid = part{1};
    offset = str2num(part{2});
    Tu{j} = uid;
    To{j} = offset;   
    itxt = fgetl(token_stream);
    j = j + 1;
end
fclose(token_stream);

% Given a token index j,
%   Tu{j} is the uid for the token as a string. Why not an index?
%   To{j} is the word offset
 
% Index in Tu and To of token being displayed.
ti = 1;
% Corresponding index in Uid.
ui = dat.um(Tu{ti});
 
% Index in Uid and Align of the utterance being displayed.
% ui = Tu

% Maximum values for uid indices and token indices.
[~,U] = size(Uid);
[~,T] = size(Tu);

% Initialize some variables.


% Variables that are set in nested functions.
uid = 0; uid2 = 0; F = 0; Sb = 0; Pb = 0; Wb = 0; w = 0; fs = 0;

M = 0;  
F = 0;    
PX = 0;   tra = 0;  
Fn = 0; PDF = 0;  
 
% Set data for utterance with uid index k.
    function utterance_data(k)
        uid = cell2mat(Uid(k));
        [F,Sb,Pb,Wb,tra] = parse_ali(uid,Align_pdf,Align_phone_len,Tra,P,k);
        % Escape underline for display.
        uid2 = strrep(uid, '_', '\_');
        PX = Align_phone{k};
        PDF = Align_pdf{k};
        % Maximum frame index
        [~,Fn] = size(F);
    end
 
    function p2 = trim_phone(p)
        % Remove the part of phone symbol p after '_'.
        p2 = p;
        loc = strfind(p,'_');
        if loc
           p2 = p2(1:(loc - 1)); 
        end 
    end

    function phones2 = trim_phones(phones1)
        phones2 = phones1(1:length(phones1));
        for k = 1:length(phones1);
          %p2(k) = {[' ',trim_phone(ps1(k))]}; 
          phones2(k) = {[' ',trim_phone(phones1(k))]}; 
        end
    end

[~,tokmax] = size(To);
[ostream,oerr] = fopen(outfile,'w');

% Loop through tokens.
for tok = 1:tokmax
    uid = Tu{tok};
    ui = dat.um(Tu{tok});
    utterance_data(ui);
    j = To{tok};
    word = tra{j};

    % First and last frames indices for the word token
    fr1 = Wb(1,j);
    fr2 = Wb(2,j);
    % The range of phone indices for the word is p1:p2.
    p1 = F(2,fr1);
    p2 = F(2,fr2);
    % The spelling of the word in localized phones, 
    % e.g.     'd_B'    'ax_I'    'z_E'
    % Spelling of the word in short phones.
    short_spelling = strjoin(P.inds2shortphones(PX(Pb(1,p1:p2))));
    %fprintf('%s\t%i\t%i\t%i\t%s\t%s\n',uid,j,fr1,fr2,word,cell2mat(trim_phones(spelling)));
    fprintf(ostream,'%s\t%i\t%i\t%i\t%s\t%s\n',uid,j,fr1,fr2,word,short_spelling);
end
 
fclose('all');
 
end

