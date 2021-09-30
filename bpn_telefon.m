function bpn_telefon(x)
     
datfile = '/local/matlab/Kaldi-alignments-matlab/data-bpn/bpn.mat';
tokenfile1 = '/local/matlab/Kaldi-alignments-matlab/data-bpn/word/telefone2.wrd.tok'; 
tokenfile2 = '/local/matlab/Kaldi-alignments-matlab/data-bpn/word/telefonema2.wrd.tok';

if nargin < 1
    x = 2;
end



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

xlab = 0;
ylab = 0;
leg1 = 0;
leg2 = 0;

% Cell array of uids for tokens.
Tu = {};
% Vector of word offsets for tokens.
To = [];

% All of the fields
Part = {};

% Load the token data from a token file.

function load_token(tokenfile)
    % Running index.
    j = 1;
    token_stream = fopen(tokenfile);

    itxt = fgetl(token_stream);
    while ischar(itxt)
        itxt = strtrim(itxt);
        part = strsplit(itxt,'\t');
        uid = part{1};
        offset = str2num(part{2});
        Tu{j} = uid;
        To{j} = offset;   
        Part{j} = part;
        itxt = fgetl(token_stream);
        j = j + 1;
    end
    fclose(token_stream);
end

 
 
% Index in Tu and To of token being analyzed.
% ti = 1;
% Corresponding index in Uid.
% ui = dat.um(Tu{ti});
 
% Index in Uid and Align of the utterance being displayed.
% ui = Tu

% Maximum values for uid indices and token indices.
%[~,U] = size(Uid);
%[~,T] = size(Tu);

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


load_token(tokenfile1);
D1 = dur(x);
disp(D1');
P1 = 0.4 * rand(tokmax,1) - 0.2;
Q1 = 0.4 * rand(tokmax,1) - 0.2;

load_token(tokenfile2);
D2 = dur(x);
P2 = 0.4 * rand(tokmax,1) - 0.2;
Q2 = 0.4 * rand(tokmax,1) - 0.2;

figure();
% scatter(D1(:,1),D1(:,2),'*');
scatter(D1(:,1) + P1,D1(:,2) + Q1,'*');
hold;
% scatter(D2(:,1) + 0.2 * ones(tokmax,1),D2(:,2),'o','red');
scatter(D2(:,1) + P2,D2(:,2) + Q2,'o','red');
xlabel(xlab);
ylabel(ylab);
legend(leg1,leg2)

function D = dur(x)
    % Loop through tokens.
    [~,tokmax] = size(To);
    D = zeros(tokmax,2);
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
    
        % Range of subphone indices for the word is s1:s2.
        s1 = F(1,fr1);
        s2 = F(1,fr2);
    
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
    
        % Same for subphone durations
        sdur = (Sb(2,s1:s2) - Sb(1,s1:s2)) + 1;
    
        % Durations of the vowels.
        vdur = pdur(vi);
    
        % Duration of 'tele' minus the first subphone
        if (x == 1)
            D(tok,1) = sum([sdur(2:3),pdur(2:4)]);
            D(tok,2) = sum(pdur(5:6));
    
            xlab = 'Length in centiseconds of /tele/, with first subphone excluded';
            ylab = 'Length in centiseconds of /fo/';
            leg1 = 'telefone';
            leg2 = 'telefonema';
        else
            D(tok,1) = pdur(5);
            D(tok,2) = pdur(6);
    
            xlab = 'Length in centiseconds of [f]';
            ylab = 'Length in centiseconds of [o]';
            leg1 = 'telefone';
            leg2 = 'telefonema';
        end

        % The spelling of the word in localized phones, 
        % e.g.     'd_B'    'ax_I'    'z_E'
        % Spelling of the word in short phones.
        % short_spelling = strjoin(P.inds2shortphones(PX(Pb(1,p1:p2))));
        short_spelling = strjoin(ps);
     
        % disp(sprintf('%s\t%i\t%i\t%i\t%i\t%i\t%i\t%s\t%s\t%s\t%s\t%s\n',uid,j,length(vs),c_stress,r_stress,fr1,fr2,strtrim(sprintf(' %i',vdur)),strtrim(sprintf(' %i',pdur)),strtrim(sprintf(' %i',sdur)),word,short_spelling));
        % disp('hi mom');
    end
end
 

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


