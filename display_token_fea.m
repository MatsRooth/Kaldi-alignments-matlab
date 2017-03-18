function display_token_fea(tokenfile,datfile,feafile,framec,audiodir)

% May need addpath('/local/matlab/kaldi-to-matlab')

% Default for demo.
if nargin < 1
    % This determines the token displayed by uid and word offset.
    tokenfile = '/local/res/stress/data/cvc_WILL_IH1.tok'; 
    % Munged alignment and audio data.
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3mono100a.mat'; %All the 100k data, or 1/8 of it for 100a.
    % Audio will be read using Kaldi.
    audiodir = 0; 
    % Cut delta features for just the word targets, with uids <uid>-k.
    % Cmvn has been applied.
    feafile = '/local/res/stress/data/cvc_word_delta_WILL_t.ark';
    % Number of frames to display.
    framec = 40;
end

    %cat /projects/speech/sys/kaldi-trunk/egs/librispeech3/s5/data/train_clean_100_V/text | awk -f ../token-index.awk -v WORD=WILLih1 > ls3-WILLih1a.tok
    % tokenfile = /local/matlab/Kaldi-alignments-matlab/data/ls3-WILLih1a.tok.tok';
    % 1836 tokens of SOME
    % tokenfile = '/local/res/stress/datar/SOMEah1.tok'; %ok

% display_token_fea('/local/matlab/Kaldi-alignments-matlab/data/ls3mono100.mat','/local/res/stress/data/cvc_word_delta_WILL.ark','/local/res/stress/data/cvc_WILL_t.tok')

% PDF ids we care about. These are zero-indexed.
% PDF0 = [94:96,100:102,22:24];
% The same 1-indexed.
% PDF1 = PDF0 + ones(1,9);
PDF1 = 1:13;

% Structure encoding the features for all tokens
Fea = readkalditfeatures(feafile);

% Map uid-k to matrix of features.
Fmap = feature_map(Fea);

% Set dat to a structure. It has to be initialized before running load.
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

% Given a token index j,
%   Tu{j} is the uid for the token as a string. 
%   To{j} is the word offset
[Tu,To] = token_data(tokenfile);

% Index in Tu and To of token being displayed.
ti = 1;
% Corresponding index in Uid.
ui = dat.um(Tu{ti});
 
% Maximum values for uid indices and token indices.
[~,U] = size(Uid);
[~,T] = size(Tu);

% Initialize some variables.

% Variables that are set in nested functions.
uid = 0; uid2 = 0; F = 0; Sb = 0; Pb = 0; Wb = 0; w = 0; w2 = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; 
PX = 0; ya = 0; tra = 0; wi = 1;
Fn = 0; PDF = 0; lft = 0;
sR = 0; x1 = 0; xn = 0;
positionVector1 = 0;
positionVector2 = 0;

% Variables related to the target word;
 wrdi = 0; wrdi_fs = 0; wrdi_fe = 0;
 Li1 = 0; Li2 = 0; Li3 = 0;
 L1 = 0; L2 = 0; L3 = 0;
 
% Pitch.
% Return values for fxrapt.
fx = 0; tt = 0; 
% Version of tt with frame indexing.
ttf = 0;
% ttf and fx restricted to the frames being displayed.
fx3 =0; tt3=0;
AX = 0;AX2 = 0;

utterance_data(ui);

% Set phone and audio data for k'th utterance.
    function utterance_data(k)
        uid = cell2mat(Uid(k));
        [F,Sb,Pb,Wb,tra] = parse_ali(uid,Align_pdf,Align_phone_len,Tra,P,k);
        % Escape underline for display.
        uid2 = strrep(uid, '_', '\_');
        PX = Align_phone{k};
        PDF = Align_pdf{k};
        % Maximum frame index
        [~,Fn] = size(F);
        % Load audio. Cat the pipe Scp(uid) into a temporary file.
        % cmd = [Scp(uid), ' cat > /tmp/display_ali_tmp.wav'];
        % This helps flac work.
        % setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
        % system(cmd);
        % wav = '/tmp/display_ali_tmp.wav';
        % Read the temporary wav file.
        % [w,fs] = audioread(wav);
        % Number of audio samples in a centisecond frame.
        wav = find_audio(uid);
        disp(wav);
        [w,fs] = audioread(wav); 
        
        % Deal with possibility of two channels.
        w2 = w;
        [~,ch] = size(w);
        if (ch == 2)
            w = w(:,2);
        end
        
        M = fs / 100;
        [nsample,~] = size(w);
        [~,nframe] = size(F);
        % pitch
        [fx,tt]=fxrapt(w,fs);
    end

    % Range of samples being displayed, this is global.
    SR = [];
    
    function wav = find_audio(uid)
        % Load the audio, either by using Kaldi to generate a tmp wav file,
        % or by reading from audiodir
        if (audiodir ~= 0)
            wav = [audiodir '/' uid '.wav'];
        else
            % Cat the pipe Scp(uid) into a temporary file.
            cmd = [Scp(uid), ' cat > /tmp/display_ali_tmp.wav'];
            % This helps flac work.
            setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
            system(cmd);
            wav = '/tmp/display_ali_tmp.wav';
        end
    end

    function display_alignment(f)
        subplot('Position',positionVector1);
        % Target word index
        wrdi = To{ti};
        % Frame start and end of the target word
        wrdi_fs = Wb(1,wrdi);
        wrdi_fe = Wb(2,wrdi);
        % f is the suggested start frame
        % Start frame
        % F1 = max([1,min([Fn - framec,f])]);
        F1 = wrdi_fs;
        % End frame
        % FN = min([F1 + framec, Fn]);
        FN = wrdi_fe + 3;
        % Display the frame interval to terminal.
        disp([F1,FN])
        % First and last samples to display.
        S1 = floor((F1 - 1) * M + 1); 
        SN = floor((FN - 1) * M - 1);
        % Range of samples to display.
        SR = S1:SN;
        
        % Vertical scale for waveform.
        sk = 1.2 * max(abs(w));
        % Plot the waveform.
        plot(SR/M,w(SR)/sk,'Color',[0.7,0.7,0.7]);
        % Play the sound.
        sound(w(SR),fs);
        
        ya = 1.0;
        disp([S1/M, SN/M, -ya, ya]);
        axis([S1/M, SN/M, -ya, ya]);
        AX = axis();
        
        % Draw gray frame bars. Some bars are recolored in the
        % subsequent steps.
        for k = F1:FN
            line([k,k],[-ya,ya],'LineWidth',2.0,'Color',[0.9,0.9,0.9]);
        end
        
        % Draw subphone bars.
        % SU(N) subphone that the Nth frame is in.
        % SUstart(PH(p)) start of pth phone
        % for p = (SU(F1) + 1):SU(FN)
        % For each subphone in the display range, except for the first.
        for p = (F(1,F1) + 1):F(1,FN)
           % k is a frame
           % k = SUstart(p);
           k = Sb(1,p);
           line([k,k],[-ya,ya],'LineWidth',2.0,'Color',[0.2,0.8,0.8]);
           pdfindex = int2str(PDF(k));
           text(k,ya *  (-0.7 + mod(p,2) * 0.08),pdfindex,'FontSize',12);
        end
        
        % Draw phone bars.
        % For each phone in the display range, except for the first.
        % for p = (PH(F1) + 1):PH(FN)
        for p = (F(2,F1) + 1):F(2,FN)
           % p is a phone as index
           % k is frame where phone p starts.
           k = Pb(1,p);
           pn = int2str(p);
           ps = P.ind2phone(PX(k));
           bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.2,0.2,0.85]);
           text(k,ya * 0.8,trim_phone(ps),'FontSize',18);
        end
        
       
        [~,wm] = size(Wb(1,:));
        % For each word index.
        for k = 1:wm
           % Frame index of start of word k.
           ks = Wb(1,k);
           % If the frame index of the word start is in the display range.
           if (F1 <= ks && ks <= FN)
              bar = line([ks,ks],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.85,0.2,0.2]);
              text(ks,-ya * 0.8,tra(k),'FontSize',18);
           end
        end

        skf = max(fx);
        
        tt1 = tt(:,1);
        tt2 = tt1 >= S1 & tt1 <= SN;
        tt3 = tt1(tt2) / M;
        fx3 = (2 * fx(tt2)/skf) - 1.0;
        
        hold;
        plot(tt3,fx3,'*');
        
        %fx - mean(fx(tt(:,3) == 1)) * ones(size(fx))) / mean(fx(tt(:,3) == 1))

        
        
         
        pp = patch([F1,FN,FN,F1],[0,0,ya,ya],'g');
        ps = patch([F1,FN,FN,F1],[0,0,-0.7 * ya,-0.7 * ya],'r' );
        pw = patch([F1,FN,FN,F1],[-0.7 * ya,-0.7 * ya,-ya,-ya],'g' );
        
        % Function handles for use in gui.
        hspp = @subphoneplay;
        hpp = @phoneplay;
        hwp = @wordplay;
        
        set(ps,'ButtonDownFcn',hspp,... 
            'PickableParts','all','FaceColor','r','FaceAlpha',0.02);

        set(pp,'ButtonDownFcn',hpp,... 
            'PickableParts','all','FaceColor','g','FaceAlpha',0.02);
        
        set(pw,'ButtonDownFcn',hwp,... 
            'PickableParts','all','FaceColor','b','FaceAlpha',0.02);
        
        title([int2str(ui),' ',uid2],'FontSize',18);
        
        % Plot the likes
        subplot('Position',positionVector2);

        % Likes for the target word
        Li1 = Fmap([uid,'-',int2str(wrdi)]);
        L1 = Li1(PDF1,:);
        % axis([F1,FN,1,15]);
        imagesc([zeros(13,1),L1,zeros(13,1)]);
        
        
    end

    function display_centered_alignment()
       wrdi = To{ti}; 
       lft = floor((Wb(1,wrdi) + Wb(2,wrdi))/2 - (framec / 2));
       disp(lft);
       display_alignment(lft);
    end


    function p2 = trim_phone(p)
        % Remove the part of phone symbol p after '_'.
        p2 = p;
        loc = strfind(p,'_');
        if loc
           p2 = p2(1:(loc - 1)); 
        end 
    end

    function subphoneplay(~,y)
        subphone = F(1,int16(floor(y.IntersectionPoint(1))));
        disp(sprintf('subphone %d, pdf %d, frame %d-%d',subphone,PDF(Sb(1,subphone)),Sb(1,subphone),Sb(2,subphone)));
        M = fs / 100;
        % Use floor to get an integer.
        st = max(1,floor((Sb(1,subphone) - 1) * M));
        en = min(floor(Sb(2,subphone) * M),SN);
        sound(w(st:en),fs);
    end

    function phoneplay(~,y)
        % phone = PH(int16(floor(y.IntersectionPoint(1))));
        phone = F(2,int16(floor(y.IntersectionPoint(1))));
        disp(sprintf('phone %d, frame %d-%d, pdf',phone,Pb(1,phone),Pb(2,phone)));
        disp(sprintf(' %d',PDF(Pb(1,phone):Pb(2,phone))));
        M = fs / 100;
        % Use floor to get an integer.
        st = max(1,floor((Pb(1,phone) - 1) * M));
        en = min(floor(Pb(2,phone) * M),SN);
        sound(w(st:en),fs);
    end

    function wordplay(x,y)
        word = F(3,int16(floor(y.IntersectionPoint(1))));
        btn = y.Button;
        %disp(x);
        disp(btn);
        % Value is 0 in a silence.
        if word > 0
            %disp(sprintf('word %d, frame %d-%d %s %s',word,Wb(1,word),Wb(2,word),uid,tra{word}));
            % Display the token that is clicked in token table format.
            fprintf('%s\t%d\t%d\t%d\t%s\n',uid, word,Wb(1,word),Wb(2,word),tra{word});
            % uid offset left-bd right-bd wordform
            M = fs / 100;
            st = max(1,floor((Wb(1,word) - 1) * M));
            if (btn==3)
                % Three words, two-finger tap as my mac is configures.
                % Need to fix this to take into account the right edge.
                en = min(floor(Wb(2,word + 2) * M),SN);
            else
                % One word 
                en = min(floor(Wb(2,word) * M),SN);
            end
            sound(w2(st:en),fs);
        end
    end   

    function play_current(~,~)
        % Play the sound snippet being displayed.
        % SR is the range of samples being displayed.
        sound(w(SR),fs);
    end

    function play_context(~,~)
        % Play a bit more than what is being displayed.
        st = max(1,SR(1) - (2 * fs));
        en = min(length(w),SR(length(SR)) + fs);
        sound(w(st:en),fs);
    end

    function play_all(~,~)
        % Play the entire utterance.
        sound(w,fs);
    end

    function next_utterance(~,~)
        ti = ti + 1;
        ui = dat.um(Tu{ti});
        %wi = 1;
        utterance_data(ui);
        clf;
        display_centered_alignment();
        add_buttons;
    end

    function previous_utterance(~,~)
        ui = max(1,ui - 1);
        utterance_data(ui);
        clf;
        display_alignment(1); 
        add_buttons;
    end

    function new_by_uid(H,~)
        unew = get(H,'string');
        disp(unew);
        inew = find(cellfun(@(x) strcmp(x,unew),Uid));
        disp(inew);
        disp('-----');
        if inew
            ui = inew;
            wi = 1;
            utterance_data(ui);
            clf;
            display_alignment(1); 
            add_buttons;
        end
    end

    function debug_from_gui(~,~)
        keyboard
    end
% nonzeros(cellfun(@(x) strcmp(x,'ahh05_sr221_trn'),C))

    hnu = @next_utterance;
    hpu = @previous_utterance;
    hinc = @increment_frame;
    hdec = @decrement_frame;
    hcurr = @play_current;
    hall = @play_all;
    huid = @new_by_uid;
    hdebug = @debug_from_gui;
    
    function increment_frame(~,~)
        clf;
        display_alignment(F1 + 20); 
        add_buttons;
    end

    function decrement_frame(~,~)
        clf;
        display_alignment(F1 - 20); 
        add_buttons;
    end

    function add_buttons 
        bprev = uicontrol('Callback',hpu,'String','<T','Position', [10 10 25 25]);
        bnext = uicontrol('Callback',hnu,'String','T>','Position', [40 10 25 25]);
        bdec = uicontrol('Callback',hdec,'String','<F','Position', [90 10 25 25]);
        binc = uicontrol('Callback',hinc,'String','F>','Position', [120 10 25 25]);
        binc = uicontrol('Callback',hdebug,'String','debug','Position', [600 10 50 25]);
        bcurr = uicontrol('Callback',hcurr,'String','P','Position', [160 10 25 25]);
        ball = uicontrol('Callback',hall,'String','A','Position', [200 10 25 25]);
        euid = uicontrol('Callback',huid,'Style','edit','Position',[260 10 120 25]);
        %title([int2str(ui),' ',uid2],'FontSize',18);
    end

figure();
%positionVector1 = [0.05, 0.3, 0.9, 0.6];
positionVector1 = [0.05, 0.5, 0.9, 0.3];
subplot('Position',positionVector1)
% positionVector2 = [0.05, 0.1, 0.9, 0.15];
positionVector2 = [0.05, 0.1, 0.9, 0.3];
subplot(2,1,1);
display_centered_alignment();
add_buttons;      



    function segment(unit,segfile)
     % print out a segment table for the current utterance
     % for unit=1 subphone, unit=2 phone, unit=3 ..
       segstream = fopen(segfile,'w');
       switch unit
           case 1
              [~,m] = size(Sb);
              for i = 1:m
                fprintf(segstream,'%s-%d\t%s\t%d\t%d\n',uid,i,uid,Sb(1,i) - 1,Sb(2,i) - 1);
              end
           case 2 
              [~,m] = size(Pb);
              for i = 1:m
                fprintf(segstream,'%s-%d\t%s\t%d\t%d\n',uid,i,uid,Pb(1,i) - 1,Pb(2,i) - 1);
              end
           case 3
              [~,m] = size(Wb); 
              for i = 1:m
                fprintf(segstream,'%s-%d\t%s\t%d\t%d\n',uid,i,uid,Wb(1,i) - 1,Wb(2,i) - 1);
              end
       end
       fclose(segstream);
    end
 
end

function Fmap = feature_map(Fea)
    Fmap = containers.Map();
    [~,ulmax] = size(Fea.utt);
    for i = 1:ulmax
        uid_phone = cell2mat(Fea.utt(i));
        Fmap(uid_phone) = cell2mat(Fea.feature(i));
    end
end


function [Tu,To] = token_data(tokenfile)
    % Cell array of uids for tokens.
    Tu = {};
    % Vector of word offsets for tokens.
    To = [];
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
end
