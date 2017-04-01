function token_data_bpn(datfile,tokenfile,outfile,framec)
% Add some columns to a token file. The input currently looks like this,
% from Simone's Perl code.  Additional columns will be added.
% f13br16b22k1	s001	1	este	e1 s ch i
% f13br16b22k1	s001	2	indiv??duo	in dj i v i1 d uw
% f13br16b22k1	s001	3	assiste	a1 s i s ch i

if nargin < 3
    framec = 100;
end
        
% BP one-of-n stress data.
if nargin < 1
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/bpn.mat';
    tokenfile = '/local/matlab/Kaldi-alignments-matlab/data/rawTokenAliTable.txt'; % 40007 word tokens
    outfile = '/local/matlab/Kaldi-alignments-matlab/data/bpn.tok';
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
% Cell array of prompt ids.
Pr = {};
% Cell array of speaker ids.
Spkr = {};
% All of the fields
Part = {};

% Load the token data.
% Running index.
j = 1;
token_stream = fopen(tokenfile);

itxt = fgetl(token_stream);
while ischar(itxt)
    itxt = strtrim(itxt);
    part = strsplit(itxt,'\t');
    prompt = part{1};
    spkr = part{2};
    % Need this for looking up stuff in dat.
    uid = [prompt,'-',spkr];
    offset = str2num(part{3});
    Tu{j} = uid;
    To{j} = offset;   
    Pr{j} = prompt;
    Spkr{j} = spkr;
    Part{j} = part;
    itxt = fgetl(token_stream);
    j = j + 1;
end
fclose(token_stream);

% Given a token index j,
%   Tu{j} is the uid for the token as a string. Why not an index?
%   To{j} is the word offset
 
% Index in Tu and To of token being analyzed.
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
disp('hi');
% Loop through tokens.
for tok = 1:tokmax
    uid = Tu{tok};  % uid like f60br08b11k1-s006
    j = To{tok};   % offset of target word
    if (isempty(j)) % Sometimes the offset field is missing.
        continue;  
    end
    ui = dat.um(uid);   % utterance index in dat
    utterance_data(ui); % load utterance data
    
    word = tra{j};

    % First and last frames indices for the word token
    fr1 = Wb(1,j);
    fr2 = Wb(2,j);
    % The range of phone indices for the word is p1:p2.
    p1 = F(2,fr1);
    p2 = F(2,fr2);
    
    % Array of phone spellings.
    ps = P.inds2shortphones(PX(Pb(1,p1:p2)));
    
    % Boolean indices of vowels
    vi = ~cellfun(@isempty,regexp(ps,'[aeiou]','match'));
    
    % Vowels
    vs = ps(vi);
    
    % The spelling of the word in localized phones, 
    % e.g.     'd_B'    'ax_I'    'z_E'
    % Spelling of the word in short phones.
    % short_spelling = strjoin(P.inds2shortphones(PX(Pb(1,p1:p2))));
    short_spelling = strjoin(ps);
    %fprintf('%s\t%i\t%i\t%i\t%s\t%s\n',uid,j,fr1,fr2,word,cell2mat(trim_phones(spelling)));
    fprintf(ostream,'%s\t%i\t%i\t%i\t%s\t%s\n',uid,j,fr1,fr2,word,short_spelling);
end
 
fclose('all');
 
end

function n = stress_to_numerical(x)
    switch x
        case 'ult'
            n = 1;
        case 'penult'
            n = 2;
        case 'antepenult'
            n = 3;
        otherwise
            n = 0;
    end
end

