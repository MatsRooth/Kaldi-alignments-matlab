function token_data_bpw2(datfile,latticefile,savefile)
% Add some info to the result of load_lattice_table.
% The result is stored as latdat in a mat file.
 
if nargin < 3
    framec = 100;
end
        
% The default argument is the BP one-of-n stress data.
if nargin < 1
    datfile = '/projects/speech/data/matlab-mat/bp0V.mat';
    latticefile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/bpw2/exp/u1/decode_word_1/tab4' % Lattice table, includes word decoding
    savefile = '/local/matlab/Kaldi-alignments-matlab/data-bpn/tab4';  % The system adds ".mat".
end


% An incremented version of this will be saved.
L = load_lattice_table(latticefile);
% Maximum index in L.  This will
tokmax = length(L.wid);


% We start with these in the struct. It already has the alignment stress.
%        uid: [20×1 string]
%       word: [20×1 string]
%      wordu: [20×1 string]
%        syl: [20×1 double]
%    cstress: [20×1 double]
%    astress: [20×1 double]
%    weight1: {1×20 cell}
%    weight2: {1×20 cell}
%      align: {1×20 cell}

% We want to add
%   voweldur in frame units (same length as syl)
%   phonedur

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
 

% Running index.
% j = 1;
% token_stream = fopen(tokenfile);

%itxt = fgetl(token_stream);
%while ischar(itxt)
%    itxt = strtrim(itxt);
%    part = strsplit(itxt,'\t');
%    prompt = part{1};
%    spkr = part{2};
%    % Need this for looking up stuff in dat.
%    uid = [prompt,'-',spkr];
%    offset = str2num(part{3});
%    Tu{j} = uid;
%    To{j} = offset;   
%    Pr{j} = prompt;
%    Spkr{j} = spkr;
%    Part{j} = part;
%    itxt = fgetl(token_stream);
%    j = j + 1;
%end
%fclose(token_stream);

% Given a token index j,
%   Tu{j} is the uid for the token as a string. Why not an index?
%   To{j} is the word offset
 
% Index in Tu and To of token being analyzed.
%ti = 1;
% Corresponding index in Uid.
%ui = dat.um(Tu{ti});
 
% Index in dat of the utterance being manipulated.  The index tok in L
% is a word index.
ui = 0;

% Maximum values for uid indices and token indices.
% [~,U] = size(Uid);
% [~,T] = size(Tu);

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

%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Core part - loop through the tokens in L
%
%%%%%%%%%%%%%%%%%%%%%%%%

% The iteration bound is tokmax, the maximum index in latdat.

% Initialize cell arrays to store the vowel, phone durations,
% and phone spelling of the word.
L.voweldur = cell(1,tokmax);
L.phonedur = cell(1,tokmax);
L.spell = cell(1,tokmax);

% Write in utf-8. When examining the result in an OSX term,
% set the character encoding to utf-8 in Preferences>Advanced.
% [ostream,oerr] = fopen(outfile,'w','native', 'UTF-8');
% disp('hi');
% Loop through tokens.
for tok = 1:tokmax
%for tok = 1:100
    wid = L.wid(tok);   % wid like f60br08b11k1-s006-7
    [uid,offset] = wid_to_uid_and_offset(wid);
 
    ui = dat.um(uid);   % Utterance index in dat of big utterance.
    utterance_data(ui); % Set a bunch of free variables
                        % for the big utterance.
    
    word = L.word(tok); % Do we need this?
    % First and last frames indices for the word token
    fr1 = Wb(1,offset);
    fr2 = Wb(2,offset);
    % The range of phone indices for the word is p1:p2.
    p1 = F(2,fr1);
    p2 = F(2,fr2);
    
    % Array of phone spellings, cell array such as {'e1','s','ch','i'}.
    ps = P.inds2shortphones(PX(Pb(1,p1:p2)));
    
    % Boolean indices of vowels, e.g. [1,0,0,1].
    vi = ~cellfun(@isempty,regexp(ps,'[aeiou]','match'));
    
    % Vowels, cell array such as {'e1','i'}.
    vs = ps(vi);
    
    % Vector of phone durations for the token. p1:p2 is the range of phone
    % indices in the word. Unit is frames. For example [17,9,8,13].
    pdur = (Pb(2,p1:p2) - Pb(1,p1:p2)) + 1;
    L.phonedur{tok} = pdur;
    
    % Durations of the vowels.
    vdur = pdur(vi);
    L.voweldur{tok} = vdur;
    
    % The spelling of the word in localized phones, 
    % e.g.     'd_B'    'ax_I'    'z_E'
    % Spelling of the word in short phones.
    % short_spelling = strjoin(P.inds2shortphones(PX(Pb(1,p1:p2))));
    short_spelling = string(ps);
    L.spell{tok} = vdur;
    % disp('.');
end
 
% Save L in an .mat file.
save(savefile,'L');

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

function [uid,offset] = wid_to_uid_and_offset(wid)
    part = strsplit(wid,'-');
    offset = str2num(char(part(length(part))));
    part3 = part(2:(length(part) - 1));
    part3 = part3';
    part3 = sprintf("-%s",part3{:});
    uid = sprintf("%s%s",part{1},part3);
    uid = uid{1,1};
end
