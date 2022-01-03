function display_ali_with_token(tokenfile,datfile,audiodir,framec)
% Browse tokens in a display where the complete utterance is available.
% 
% May need addpath('/local/matlab/voicebox')
if nargin < 4
    framec = 150;
end

if nargin < 3
    audiodir = '/Volumes/Gray/matlab/matlab-wav/lsCAN';
end

if nargin < 2
    datfile = '/Volumes/Gray/matlab/matlab-mat/can100nosp.mat';
end

if nargin < 1
    tokenfile='/local/res/some/parse/pps.tok';
end

% Set dat to a structure describing all the utterances.
load(datfile,'dat');

% Given a token index j,
%   Tok.Tu{j} is the uid for the token as a string.
%   Tok.To{j} is the word offset
Tok = read_token(tokenfile);

% Index in Tu and To of token being displayed.
ti = 1;
% Corresponding index in Uid.
ui = dat.um(Tok.Tu{ti});

% Maximum values for uid indices and token indices.
[~,U] = size(dat.uid);
[~,T] = size(Tok.Tu);


% Variables that are set in nested functions.
uid = 0; uid2 = 0; F = 0; Sb = 0; Pb = 0; Wb = 0; w = 0; w2 = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; 
PX = 0; ya = 0; tra = 0; wi = 1;
Fn = 0; PDF = 0; lft = 0;
sR = 0; x1 = 0; xn = 0;
positionVector1 = 0;
positionVector2 = 0;
wmax = 0; wrdi = 0;

% Pitch.
% Return values for fxrapt.
fx = 0; tt = 0; 
% Version of tt with frame indexing.
ttf = 0;
% ttf and fx restricted to the frames being displayed.
fx3 =0; tt3=0;
AX = 0;AX2 = 0;

% utterance_data(ui);  Don't call this anymore.
cur = utterance_data(dat,audiodir,ui);

% Set the global variables formerly set by utterance_data.
% Transition away from these.
uid = cur.uid; %        uid: '103-1240-0004-V'
F = cur.F;     %          F: [3×1250 double]
Sb = cur.Sb; %         Sb: [2×464 double]
Pb = cur.Pb;  %         Pb: [2×156 double]
Wb = cur.Wb;  %       Wb: [2×42 double]
tra = cur.tra; %        tra: {1×42 cell}
uid2 = cur.uid2;  %       uid2: '103-1240-0004-V'
PX = cur.PX;  %         PX: [1×1250 double]
PDF = cur.PDF; %        PDF: [1×1250 double]
Fn = cur.Fn; %         Fn: 1250
wav = cur.wav; %        wav: '/Volumes/Gray/matlab/matlab-wav/lsCAN/103-1240-0004-V.wav'
w = cur.w; %          w: [200240×1 double]
fs = cur.fs; %         fs: 16000
M = cur.M;   %        M: 160
nsample = cur.nsample; %    nsample: 200240
nframe = cur.nframe; %    nframe: 1250
fx = cur.fx; %         fx: [970×1 double]
tt = cur.tt; %       tt: [970×3 double]


    function display_alignment(f)
        % f is the suggested start frame
        % cur is implicit
        subplot('Position',positionVector1);
      
        % Start and end frame
        cur.F1 = max([1,min([cur.Fn - framec,f])]);
        cur.FN = min([cur.F1 + framec, cur.Fn]);
        
        % First and last samples to display.
        cur.S1 = floor((cur.F1 - 1) * cur.M + 1);
        cur.SN = floor((cur.FN - 1) * cur.M - 1);
        
        % Range of samples to display.
        cur.SR = cur.S1:cur.SN;
        
        % Plot waveform with scale, play audio
        sk = 1.2 * max(abs(cur.w));
        plot(cur.SR/cur.M,cur.w(cur.SR)/sk,'Color',[0.7,0.7,0.7]);
        sound(cur.w(cur.SR),cur.fs);
        
        % Adjust the axis
        ya = 1.0;
        % disp([cur.S1/cur.M, cur.SN/cur.M, -ya, ya]);
        axis([cur.S1/cur.M, cur.SN/cur.M, -ya, ya]);
        AX = axis();
        
        
        % Draw subphone bars.
        % For each subphone in the display range, except for the first.
        for p = (cur.F(1,cur.F1) + 1):cur.F(1,cur.FN)
            % k is a frame
            % k = SUstart(p);
            k = cur.Sb(1,p);
            % line([k,k],[-ya,ya],'LineWidth',2.0,'Color',[0.2,0.8,0.8]);
            line([k,k],[-ya * 0.7, 0],'LineWidth',2.0,'Color',[0.2,0.8,0.8]);
            pdfindex = int2str(cur.PDF(k));
            text(k,ya *  (-0.7 + mod(p,2) * 0.08),pdfindex,'FontSize',12);
        end
        
        % Draw phone bars.
        % For each phone in the display range, except for the first.
        for p = (cur.F(2,cur.F1) + 1):cur.F(2,cur.FN)
            % p is a phone as index
            % k is frame where phone p starts.
            k = cur.Pb(1,p);
            pn = int2str(p);
            ps = dat.phone_indexer.ind2shortphone(cur.PX(k));
            bar = line([k,k],[-ya * 0.7,ya] * 0.99,'LineWidth',2.0,'Color',[0.3,0.3,0.75]);
            text(k,ya * 0.8,ps,'FontSize',18);
        end
        
        
        [~,wm] = size(Wb(1,:));
        % For each word index.
        for k = 1:wm
            % Frame index of start of word k.
            ks = cur.Wb(1,k);
            % If the frame index of the word start is in the display range.
            if (cur.F1 <= ks && ks <= cur.FN)
                bar = line([ks,ks],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.85,0.2,0.2]);
                text(ks,-ya * 0.8,cur.tra(k),'FontSize',18);
            end
        end
        
        % Pitch
        
        skf = max(cur.fx);
        
        tt1 = cur.tt(:,1);
        tt2 = tt1 >= cur.S1 & tt1 <= cur.SN;
        tt3 = tt1(tt2) / M;
        fx3 = (2 * cur.fx(tt2)/skf) - 1.0;
        
        hold;
        plot(tt3,fx3,'*');
        
        %fx - mean(fx(tt(:,3) == 1)) * ones(size(fx))) / mean(fx(tt(:,3) == 1))
        
        
        
        
        pp = patch([cur.F1,cur.FN,cur.FN,cur.F1],[0,0,ya,ya],'g');
        ps = patch([cur.F1,cur.FN,cur.FN,cur.F1],[0,0,-0.7 * ya,-0.7 * ya],'r' );
        pw = patch([cur.F1,cur.FN,cur.FN,cur.F1],[-0.7 * ya,-0.7 * ya,-ya,-ya],'g' );
        
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
        
        title([int2str(ti),' ',int2str(ui),' ',uid2],'FontSize',18);
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
        
        r = rms2(w(cur.SR),windowlength,overlap,1);
        [~,ssr] = size(cur.SR);
        x1 = cur.SR(1)/M;
        xn = cur.SR(ssr)/M;
        [~,sR] = size(r);
        XR = (((1:sR)/sR) * (xn - x1)) + (ones(1,sR) * x1);
        
        plot(XR,r);
        AX2 = axis();
        AX2(1) = AX(1);
        AX2(2) = AX(2);
        axis(AX2);
        
        
    end

    function display_centered_alignment()
       wrdi = Tok.To(ti); 
       [~,wmax] = size(cur.Wb);
       wrdi = min(wrdi,wmax);
       lft = floor((cur.Wb(1,wrdi) + cur.Wb(2,wrdi))/2 - 50);
       disp(lft);
       display_alignment(lft);
    end


    function subphoneplay(~,y)
        subphone = cur.F(1,int16(floor(y.IntersectionPoint(1))));
        disp(sprintf('subphone %d, pdf %d, frame %d-%d',subphone,cur.PDF(cur.Sb(1,subphone)),cur.Sb(1,subphone),cur.Sb(2,subphone)));
        M = cur.fs / 100;
        % Use floor to get an integer.
        st = max(1,floor((cur.Sb(1,subphone) - 1) * M));
        en = min(floor(cur.Sb(2,subphone) * M),cur.SN);
        sound(cur.w2(st:en),cur.fs);
    end

    function phoneplay(~,y)
        phone = cur.F(2,int16(floor(y.IntersectionPoint(1))));
        disp(sprintf('phone %d, frame %d-%d, pdf',phone,cur.Pb(1,phone),cur.Pb(2,phone)));
        disp(sprintf(' %d',cur.PDF(cur.Pb(1,phone):cur.Pb(2,phone))));
        M = cur.fs / 100;
        % Use floor to get an integer.
        st = max(1,floor((cur.Pb(1,phone) - 1) * M));
        en = min(floor(cur.Pb(2,phone) * M),cur.SN);
        sound(cur.w2(st:en),cur.fs);
    end

    function wordplay(x,y)
        word = cur.F(3,int16(floor(y.IntersectionPoint(1))));
        btn = y.Button;
        %disp(x);
        disp(btn);
        % Value is 0 in a silence.
        if word > 0
            %disp(sprintf('word %d, frame %d-%d %s %s',word,Wb(1,word),Wb(2,word),uid,tra{word}));
            % Display the token that is clicked in token table format.
            fprintf('%s\t%d\t%d\t%d\t%s\n',uid, word,cur.Wb(1,word),cur.Wb(2,word),cur.tra{word});
            % uid offset left-bd right-bd wordform
            M = cur.fs / 100;
            st = max(1,floor((cur.Wb(1,word) - 1) * M));
            if (btn==3)
                % Three words, two-finger tap as my mac is configures.
                % Need to fix this to take into account the right edge.
                en = min(floor(cur.Wb(2,word + 2) * M),cur.SN);
            else
                % One word 
                en = min(floor(cur.Wb(2,word) * M),cur.SN);
            end
            sound(cur.w2(st:en),cur.fs);
        end
    end   


    function play_current(~,~)
        % phone = PH(int16(floor(y.IntersectionPoint(1))));
        % disp(sprintf('phone %d',phone));
        %M = fs / 100;
        %st = (PHstart(phone) - 1) * M;
        %en = PHend(phone) * M;
        sound(cur.w(cur.SR),cur.fs);
    end

    function play_all(~,~)
        sound(cur.w,cur.fs);
    end


    function next_utterance(~,~)
        % Keep ti from exceeding the maximum token index.
        ti = min(ti + 1,T);
        % Look up the utterance index.
        ui = dat.um(Tok.Tu{ti});
        % Reset the current data
        cur = utterance_data(dat,audiodir,ui);
        clf;
        display_centered_alignment();
        add_buttons;
    end

    function previous_utterance(~,~)
        ti = max(ti - 1,1);
        ui = dat.um(Tok.Tu{ti});
        utterance_data(dat,audiodir,ui);
        clf;
        display_centered_alignment(); 
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
            utterance_data(dat,audiodir,ui);
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
        display_alignment(cur.F1 + 50); 
        add_buttons;
    end

    function decrement_frame(~,~)
        clf;
        display_alignment(cur.F1 - 50); 
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
positionVector1 = [0.05, 0.3, 0.9, 0.6];
subplot('Position',positionVector1)
positionVector2 = [0.05, 0.1, 0.9, 0.15];
      
subplot(2,1,1);
display_centered_alignment();
add_buttons; 
end

