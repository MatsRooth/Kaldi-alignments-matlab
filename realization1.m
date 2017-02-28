function realization1(datfile,outfile)
%                     -       +
% Make a table of realizations for special words in the LS3 project, with these fields.
% 103-1240-0000-V   uid
% 14                word offset
% 712               left frame index
% 727               right frame indes
% THEah1            word form
% DH IY0            phone spelling
% R                 left phone contex
% AE1               right phone context
% 1676 383 383 945 945 1003 1003 1288 1288 1288 1288 1433 1433 1433 1433 1433	
%                   pdf ids
% 5596 5604 5603 5632 5631 9592 9591 9636 9635 9635 9635 9706 9705 9705 9705 9705
%                   transition ids

% See /local/res/ls3 for analysis of the result.

if nargin < 4
    audiodir = 0;
end

if nargin < 3
    framec = 100;
end

% Default for demo, yielding 38849 tokens.
if nargin < 1
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3a.mat';
    outfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3a-realization.tok';
end

% Run it on whole train100, yielding 409303 tokens.
% realization1('/projects/speech/data/matlab-mat/ls3all.mat','/local/matlab/Kaldi-alignments-matlab/data/ls3all-realization.tok')

% cat /local/matlab/Kaldi-alignments-matlab/data/ls3all-realization.tok | awk 'BEGIN {FS="\t"}$5=="WASaa1"{print $6}'  | sort | uniq -c | sort -nr | head

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

% Maximum index for Uid.
[~,U] = size(Uid);
 
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
        % Transition ids
        BASIC = Basic{k};
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
 
[ostream,oerr] = fopen(outfile,'w');

% Loop through the utterances.
for u = 1:U
    uid = Uid{u};
    utterance_data(u);
    disp(u); disp(uid); 
    % disp(tra);
    [~,Wm] = size(tra);
    for w = 1:Wm
        wd = tra{w};
        % Select special words such as WASaa1.
        if regexp(wd,'.*[a-z][0-2]')
            % First and last frames indices for the word token
            fr1 = Wb(1,w);
            fr2 = Wb(2,w);
            p1 = F(2,fr1);
            p2 = F(2,fr2);
            short_spelling = strjoin(P.inds2shortphones(PX(Pb(1,p1:p2))));
            
            if (p1 > 1)
                phone_left = strjoin(P.inds2shortphones(PX(Pb(1,[p1 - 1]))));
            else
                phone_left = 'SIL';
            end
            
            [~,pmax] = size(Pb);
            
            if (p2 < pmax)
                phone_right = strjoin(P.inds2shortphones(PX(Pb(1,[p2 + 1]))));
            else
                phone_right = 'SIL';
            end
            
            % Pdf IDs as a string.
            pdfstr = [sprintf('%d',PDF(fr1)),sprintf(' %d', PDF((fr1+1):fr2))];
            % Transition IDs as a string.
            basicstr = [sprintf('%d',BASIC(fr1)),sprintf(' %d', BASIC((fr1+1):fr2))];
            
            fprintf(ostream,'%s\t%d\t%d\t%d\t%s\t%s\t%s\t%s\t%s\t%s\n',uid,w,fr1,fr2,wd,short_spelling,phone_left,phone_right,pdfstr,basicstr);
            % uid, offset, base, realization, 5gram
            %103-1241-0032-V	5	AE1	      UH0	 DOuw1 HOPEow1 THATae1 SOMEah1 DAYey1
        end
        
    end

end
 
fclose('all');
 
end

