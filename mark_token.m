function mark_token(datfile,tokenfile,markdir,framec,audiodir)
% The .mat file is created with con
% May need addpath('/local/matlab/voicebox')
if nargin < 5
    audiodir = 0;
end

if nargin < 4
    framec = 100;
end

% Utterances of will.
%  head -4 ls3-WILLih1b.tok 
%103-1240-0044-V	12	321	333	WILLih1	W AH0 L
%103-1240-0050-V	35	924	935	WILLih1	W AH0 L
%103-1240-0054-V	43	1273	1295	WILLih1	W IH1 L
%103-1241-0031-V	27	687	711	WILLih1	W AH0 L
% Note that the uids end with -V.
if nargin < 3
    datfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3all.mat';
    audiodir = 0;
    % Tokens of 'will'.
    tokenfile = '/local/matlab/Kaldi-alignments-matlab/data/ls3-WILLih1b.tok';
    markdir = '/local/matlab/Kaldi-alignments-matlab/data/ls3-WILLih1b';
    % Number of frames to display.
    framec = 200;
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

% Use for printing.
Tok = readtable(tokenfile,'Delimiter','\t','ReadVariableNames',false,'FileType','text');
%[row,col] = size(Tok);
% If it only has 6 columns, add a 7th for focus with entry 0 for unmarked.
%if col == 6
%    Tok.Var7 = Tok.Var2 * 0;
%end


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

% Vector of markups
% 0 unmarked
% 1 F
% 2 d
% 3 p
Ma = zeros(1,T);

% Initialize some variables.


% Variables that are set in nested functions.
uid = 0; uid2 = 0; F = 0; Sb = 0; Pb = 0; Wb = 0; w = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; 
PX = 0; ya = 0; tra = 0; wi = 1;
Fn = 0; PDF = 0; lft = 0;
sR = 0; x1 = 0; xn = 0;
rf = 0; rd = 0; rp = 0; ru = 0;
positionVector1 = 0;
positionVector2 = 0;

% Data block
bl = 1;

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
        % f is the suggested start frame
        % Start frame
        F1 = max([1,min([Fn - framec,f])]);
        % End frame
        FN = min([F1 + framec, Fn]);
        % sound(w,fs);
        disp([F1,FN])
        % First and last samples to display.
        %S1 = floor(F1  * M); 
        %SN = floor(FN * M);
        S1 = floor((F1 - 1) * M + 1); 
        SN = floor((FN - 1) * M - 1);
        % Range of samples to display.
        SR = S1:SN;
        
        sk = 1.2 * max(abs(w));
        
        plot(SR/M,w(SR)/sk,'Color',[0.7,0.7,0.7]);

        sound(w(SR),fs);
        
        ya = 1.0;
        disp([S1/M, SN/M, -ya, ya]);
        axis([S1/M, SN/M, -ya, ya]);
        AX = axis();
               

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
        
        title([int2str(ui),' ',uid2,' ',int2str(block(ti)), ' ',int2str(ti)],'FontSize',18);
        subplot('Position',positionVector2);
        %v = v_ppmvu(w(SR),fs,'e'); 
        %plot(v);
        %figure;
        %plot(tt3,fx3,'g*');
        % rms amplitude
        % rms2(signal, windowlength, overlap, zeropad)
        windowlength = 200;
        overlap = 100;
        d2 = windowlength - overlap;

        r = rms2(w(SR),windowlength,overlap,1);
        [~,ssr] = size(SR);
        x1 = SR(1)/M;
        xn = SR(ssr)/M;
        [~,sR] = size(r);
        XR = (((1:sR)/sR) * (xn - x1)) + (ones(1,sR) * x1);
        
        plot(XR,r);        
        AX2 = axis();
        AX2(1) = AX(1);
        AX2(2) = AX(2);
        axis(AX2);
        
        
    end

    function display_centered_alignment()
       wrdi = To{ti}; 
       lft = floor((Wb(1,wrdi) + Wb(2,wrdi))/2 - 50);
       disp(lft);
       display_alignment(lft);
    end

    function p2 = trim_phone(p)
        % Remove the part of phone symbol p after '_'.
        % p = p{1};
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

    function wordplay(~,y)
        word = F(3,int16(floor(y.IntersectionPoint(1))));
        % Value is 0 in a silence.
        if word > 0
            disp(sprintf('word %d, frame %d-%d\n%s %s',word,Wb(1,word),Wb(2,word),uid,tra{word}));
            M = fs / 100;
            st = max(1,floor((Wb(1,word) - 1) * M));
            en = min(floor(Wb(2,word) * M),SN);
            sound(w(st:en),fs);
        end
    end

    function play_current(~,~)
        % phone = PH(int16(floor(y.IntersectionPoint(1))));
        % disp(sprintf('phone %d',phone));
        %M = fs / 100;
        %st = (PHstart(phone) - 1) * M;
        %en = PHend(phone) * M;
        sound(w(SR),fs);
    end

    function play_all(~,~)
        sound(w,fs);
    end

    function next_utterance(~,~)
        save_focus;
        ti = min([ti + 1,T]);
        ui = dat.um(Tu{ti});
        utterance_data(ui);
        clf;
        display_centered_alignment();
        add_buttons;
        set_radio;
    end

    function save_block(k)
       % Save the block that token k is in.
       b = block(k);
       t1 = 50 * (k - 1) + 1;
       tn = min([50 * b,R]);
       for j = t1:tn
           
           
       end
    end

    function previous_utterance(~,~)
        save_focus;
        ti = max([ti - 1,1]);
        ui = dat.um(Tu{ti});
        utterance_data(ui);
        clf;
        display_centered_alignment();
        add_buttons;
        set_radio;
    end

    function new_by_uid(H,~)
        tnew = get(H,'string');
        disp(tnew);
        ti = max([1,min([tnew,T])]);
        display_centered_alignment(); 
    end

    function debug_from_gui(~,~)
        keyboard
    end

    function save_markup(~,~)
        ofile = [markdir,'/',int2str(gen),'.tok'];
        ostream = fopen(ofile,'w');
        for k = 1:T
            %fprintf(ostream,'%s\t%i\t%i\t%i\t%s\t%s\n',uid,j,fr1,fr2,word,cell2mat(trim_phones(spelling)));
            fprintf(ostream,'%s\t%i\t%i\t%i\t%s\t%s\t%i\n',cell2mat(Tok{k,1}),Tok{k,2},Tok{k,3},Tok{k,4},cell2mat(Tok{k,5}),cell2mat(Tok{k,6}),Ma(k));
        end
        fclose(ostream);
        disp(ofile);
        gen = gen + 1;
    end

    hnu = @next_utterance;
    hpu = @previous_utterance;
    hinc = @increment_frame;
    hdec = @decrement_frame;
    hcurr = @play_current;
    hall = @play_all;
    huid = @new_by_uid;
    hdebug = @debug_from_gui;
    hsave = @save_markup;
    
    function increment_frame(~,~)
        clf;
        display_alignment(F1 + 50); 
        add_buttons;
    end

    function decrement_frame(~,~)
        clf;
        display_alignment(F1 - 50); 
        add_buttons;
    end

    function set_block()
       bl =  floor((ti - 1) / 50 + 1);
    end

    % The set commands emulate a buttongroup, which I could not get 
    % to work.
    function radio_F(~,~)
        %disp('radio F');
        set(rd,'Value',0);
        set(rp,'Value',0);
        set(ru,'Value',0);
    end
    function radio_d(~,~)
        %disp('radio d');
        set(rf,'Value',0);
        set(rp,'Value',0);
        set(ru,'Value',0);
    end
    function radio_p(~,~)
        %disp('radio p');
        set(rf,'Value',0);
        set(rd,'Value',0);
        set(ru,'Value',0);
    end
    function radio_u(~,~)
        %disp('radio u');
        set(rf,'Value',0);
        set(rd,'Value',0);
        set(rp,'Value',0);
    end


    function add_buttons 
        %subplot('Position',positionVector3);
        rf = uicontrol('Style','radio','Callback',@radio_F,'String','F','Position',[440 20 60 20]);
        rd = uicontrol('Style','radio','Callback',@radio_d,'String','d','Position',[480 20 60 20]);
        rp = uicontrol('Style','radio','Callback',@radio_p,'String','p','Position',[520 20 60 20]);
        ru = uicontrol('Style','radio','Callback',@radio_u,'String','--','Position',[560 20 60 20],'Value',1);
        bprev = uicontrol('Callback',hpu,'String','<T','Position', [10 10 25 25]);
        bnext = uicontrol('Callback',hnu,'String','T>','Position', [40 10 25 25]);
        bdec = uicontrol('Callback',hdec,'String','<F','Position', [90 10 25 25]);
        binc = uicontrol('Callback',hinc,'String','F>','Position', [120 10 25 25]);
        bdebug = uicontrol('Callback',hdebug,'String','debug','Position', [900 10 50 25]);
        bsave = uicontrol('Callback',hsave,'String','save','Position', [800 10 50 25]);
        bcurr = uicontrol('Callback',hcurr,'String','P','Position', [160 10 25 25]);
        ball = uicontrol('Callback',hall,'String','A','Position', [200 10 25 25]);
        euid = uicontrol('Callback',huid,'Style','edit','Position',[260 10 120 25]);
    end

    function b = block(k)
        b = floor((k - 1) / 50 + 1);
    end

    function save_focus
        if rf.Value == 1
            Ma(ti) = 1;
        elseif rd.Value == 1
            Ma(ti) = 2;
        elseif rp.Value == 1
            Ma(ti) = 3;
        elseif ru.Value == 1
            Ma(ti) = 0;
        end
    end

    function set_radio
        if Ma(ti) == 0
          set(ru,'Value',1);
          set(rf,'Value',0);
          set(rd,'Value',0);
          set(rp,'Value',0);
        elseif Ma(ti) == 1
          set(ru,'Value',0);
          set(rf,'Value',1);
          set(rd,'Value',0);
          set(rp,'Value',0);
        elseif Ma(ti) == 2
          set(ru,'Value',0);
          set(rf,'Value',0);
          set(rd,'Value',1);
          set(rp,'Value',0);
        elseif Ma(ti) == 3
          set(ru,'Value',0);
          set(rf,'Value',0);
          set(rd,'Value',0);
          set(rp,'Value',1);
        end
    end

    gen = 1;


fig = figure();
positionVector1 = [0.05, 0.3, 0.9, 0.6];
positionVector2 = [0.05, 0.1, 0.9, 0.15];
positionVector3 = [0.4, 0.2, 0.9, 0.15];
display_centered_alignment();

add_buttons;      

 
end

