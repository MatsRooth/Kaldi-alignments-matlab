function display_ali(alifile,wavscp,model,phones)
%  UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Default argument  
if nargin < 4
    alifile = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/train/wav.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/final.mdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/lang/phones.txt';
end

% Read wav file and alignment for all the utterance IDs.
% Map from uid to wav launch pipes.
Scp = load_kaldi_wavscp(wavscp);

% For mapping back and forth between phones and their indices.
P = phone_indexer(phones);

% Create and load the alignments in various formats.
% Cell array of Uid, and cell array of alignment vectors.
[Uid,Basic,Pdf,Phone,Phone_seq] = load_ali(alifile,model)

% Index in Uid and Align of the utterance being displayed.
ui = 1;

% Maximum value for ui.
[~,U] = size(Uid);

% Initialize some variables that are set in nested functions.
uid = 0; uid2 = 0; PH = 0; SU = 0; PHstart = 0; PHend = 0; SUstart = 0; SUend = 0; w = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; 
PX = 0; ya = 0;

utterance_data(ui);
 
% Set phone and audio data for k'th utterance.
    function utterance_data(k)
        [uid,PH,SU,PHstart,PHend,SUstart,SUend] = parse_ali(Uid,Pdf,k);
        % Escape underline for display.
        uid2 = strrep(uid, '_', '\_');
        PX = Phone{k};
        % Maximum frame index
        [~,F] = size(PH);
        % Load audio. Cat the pipe Scp(uid) into a temporary file.
        cmd = [Scp(uid), ' cat > /tmp/display_ali_tmp.wav'];
        disp(cmd);
        system('echo $SHELL');
        system('which flac');
        system(cmd);
        %system('flac -c -d -s /projects/speech/data/librispeech/LibriSpeech/train-clean-100/103/1240/103-1240-0015.flac | cat > /tmp/display_ali_tmp.wav');
        wav = '/tmp/display_ali_tmp.wav';
        % Read the temporary wav file.
        [w,fs] = audioread(wav);
        % Number of audio samples in a centisecond frame.
        M = fs / 100;
        [nsample,~] = size(w);
        [~,nframe] = size(PH);
    end

    % Range of samples being displayed, this is global.
    SR = [];
    
    function display_alignment(f)
        % f is the suggested start frame
        FN = min([f + 100, F]);
        % Start frame
        F1 = max(FN - 100,1);
        % sound(w,fs);

        % First and last samples to display.
        S1 = F1 * M; SN = FN * M;
        % Range of samples to display.
        SR = S1:SN;
        plot(SR/M,w(SR),'Color',[0.7,0.7,0.7]);
        sound(w(SR),fs);
        ya = 1.2 * max(abs(w));
        axis([S1/M, SN/M, -ya, ya]);
        
        
        % Draw subphone bars.
        % SU(N) subphone that the Nth frame is in.
        % SUstart(PH(p)) start of pth phone
        for p = (SU(F1) + 1):SU(FN)
           % k is a frame
           k = SUstart(p);
           bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.2,0.8,0.8]);
        end
        
        % Draw phone bars.
        for p = (PH(F1) + 1):PH(FN)
           % k is a frame
           k = PHstart(p);
           bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.2,0.2,0.85]);
           % 
           pn = int2str(p);
           ps = P.ind2phone(PX(k));
           %text(k,0.09,pn);
           text(k,ya * 0.8,trim_phone(ps),'FontSize',18);
        end
        

        hold;
        pp = patch([F1,FN,FN,F1],[0,0,0.5,0.5],'g');
        ps = patch([F1,FN,FN,F1],[0,0,-0.5,-0.5],'r' );
        
        % Function handles for use in gui.
        hspp = @subphoneplay;
        hpp = @phoneplay;
        
        set(ps,'ButtonDownFcn',hspp,... 
            'PickableParts','all','FaceColor','r','FaceAlpha',0.02);

        set(pp,'ButtonDownFcn',hpp,... 
            'PickableParts','all','FaceColor','r','FaceAlpha',0.02);
    end

    function p2 = trim_phone(p)
        % Remove the part of phone symbol p after '_'.
        p = p{1};
        p2 = p;
        loc = strfind(p,'_');
        if loc
           p2 = p2(1:(loc - 1)); 
        end 
    end

    function subphoneplay(~,y)
        subphone = SU(int16(floor(y.IntersectionPoint(1))));
        disp(sprintf('subphone %d',subphone));
        M = fs / 100;
        st = (SUstart(subphone) - 1) * M;
        en = SUend(subphone) * M;
        sound(w(st:en),fs);
    end

    function phoneplay(~,y)
        phone = PH(int16(floor(y.IntersectionPoint(1))));
        disp(sprintf('phone %d',phone));
        M = fs / 100;
        st = (PHstart(phone) - 1) * M;
        en = PHend(phone) * M;
        sound(w(st:en),fs);
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
        ui = ui + 1;
        utterance_data(ui);
        clf;
        display_alignment(1); 
        add_buttons;
    end

    function previous_utterance(~,~)
        ui = max(1,ui - 1);
        utterance_data(ui);
        clf;
        display_alignment(1); 
        add_buttons;
    end

    hnu = @next_utterance;
    hpu = @previous_utterance;
    hinc = @increment_frame;
    hdec = @decrement_frame;
    hcurr = @play_current;
    hall = @play_all;
    
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

    function add_buttons 
        bprev = uicontrol('Callback',hpu,'String','<U','Position', [10 10 25 25]);
        bnext = uicontrol('Callback',hnu,'String','U>','Position', [40 10 25 25]);
        bdec = uicontrol('Callback',hdec,'String','<F','Position', [90 10 25 25]);
        binc = uicontrol('Callback',hinc,'String','F>','Position', [120 10 25 25]);
        bcurr = uicontrol('Callback',hcurr,'String','P','Position', [160 10 25 25]);
        ball = uicontrol('Callback',hall,'String','A','Position', [200 10 25 25]);
        title(uid2,'FontSize',18);
    end

figure();
display_alignment(1);
add_buttons;      
title(uid2);



% ui  index in Uid and Align of the current token
% uid utterance ID of current token

end

