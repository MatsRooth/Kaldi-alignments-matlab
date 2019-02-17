function token_data_bpn(datfile,tokenfile,outfile,framec)
% Add some columns to a BP stress token file, as follows.
%m67br08b11k1-s001	5	2	1	1	322	377	3 23	9 3 10 23 11	demais2	dj i m aj1 s
%m67br08b11k1-s001	
%5  word offset	
%2	number of vowels
%1	lexical stress
%1	recognized stress
%322  frame start
%377  frame end
%3 23 list of vowel lengths, in frames
%9 3 10 23 11 list of phone lengths, in frames
%demais2	word form
%dj i m aj1 s  recognized phone spelling

if nargin < 3
    framec = 100;
end
        
% The default argument is the BP one-of-n stress data.
if nargin < 1
    datfile = '/local/matlab/Kaldi-alignments-matlab/data-bpn/bpn.mat';
    tokenfile = '/local/matlab/Kaldi-alignments-matlab/data-bpn/rawTokenAliTable.txt'; % 40007 word tokens, Simone's decoding, but with some bugs.
    outfile = '/local/matlab/Kaldi-alignments-matlab/data-bpn/bpn.tok';
end

% 0V
% Need to check that this does not illegitimately take info from
% /local/matlab/Kaldi-alignments-matlab/data-bpn/rawTokenAliTable.txt'.
% token_data_bpn('/projects/speech/data/matlab-mat/bp0V.mat','/local/matlab/Kaldi-alignments-matlab/data-bpn/rawTokenAliTable.txt','/local/matlab/Kaldi-alignments-matlab/data-bpn/bp0V.tok')
% This yields 37040, too few.

% To inspect the result, run display_token, clicking on words and phones to
% check properties.
%  display_token('/local/matlab/Kaldi-alignments-matlab/data/bpn.tok','/local/matlab/Kaldi-alignments-matlab/data/bpn.mat')

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
% Write in utf-8. When examining the result in an OSX term,
% set the character encoding to utf-8 in Preferences>Advanced.
[ostream,oerr] = fopen(outfile,'w','native', 'UTF-8');
disp('hi');
% Loop through tokens.
for tok = 1:tokmax  
%for tok = 1:100
    uid = Tu{tok};  % uid like f60br08b11k1-s006
    j = To{tok};   % offset of target word
    if (isempty(j)) % Sometimes the offset field is missing.
        continue;  % This is causing missing tokens.
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
    
    % Array of phone spellings, cell array such as {'e1','s','ch','i'}.
    ps = P.inds2shortphones(PX(Pb(1,p1:p2)));
    
    % Boolean indices of vowels, e.g. [1,0,0,1].
    vi = ~cellfun(@isempty,regexp(ps,'[aeiou]','match'));
    
    % Vowels, cell array such as {'e1','i'}.
    vs = ps(vi);
    
    % Lexical citation stress, 2 (penultimate) for eschi
    c_stress = stress_to_numerical(Part{tok}{8});
    
    % Realized stress pattern as a 1xn logical array, e.g. [1,0]. 
    r_stress_pattern = ~cellfun(@isempty,regexp(vs,'[1]','match'));
    
    % Realized stress in numerical form.
    r_stress = min(find(fliplr(r_stress_pattern)));
    
    % Realized stress class counting from the end, e.g. 2 means
    % penultimate.
    
    % Vector of phone durations for the token. p1:p2 is the range of phone
    % indices in the word. Unit is frames. For example [17,9,8,13].
    pdur = (Pb(2,p1:p2) - Pb(1,p1:p2)) + 1;
    
    
    % Durations of the vowels.
    vdur = pdur(vi);
    
    % The spelling of the word in localized phones, 
    % e.g.     'd_B'    'ax_I'    'z_E'
    % Spelling of the word in short phones.
    % short_spelling = strjoin(P.inds2shortphones(PX(Pb(1,p1:p2))));
    short_spelling = strjoin(ps);
     
    % Example of fields:
    %   m08br16b22k1-s001 uid
    %   1 word offset
    %   2 vowel cound
    %   69 frame start
    %   119 frame end 
    % fprintf(ostream
    fprintf(ostream,'%s\t%i\t%i\t%i\t%i\t%i\t%i\t%s\t%s\t%s\t%s\n',uid,j,length(vs),c_stress,r_stress,fr1,fr2,strtrim(sprintf(' %i',vdur)),strtrim(sprintf(' %i',pdur)),word,short_spelling);
    % disp('hi mom');
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


