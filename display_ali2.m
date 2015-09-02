function display_ali2(alifile,wavscp)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Default argument  
if nargin < 2
    alifile = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/alipdf.1';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/train/wav.scp';
end

% Read wav file and alignment for all the utterance IDs.
% Map from uid to wav launch pipes.
Scp = load_kaldi_wavscp();
% Cell array of Uid, and cell array of alignment vectors.
[Uid,Align] = load_ali();

% Index in Uid and Align of the utterance being displayed.
ui = 1;

% Maximum value for ui.
[~,U] = size(Uid);

% Initialize some variables that are set in nested functions.
uid = 0; ,PH = 0; SU = 0; PHstart = 0; ,PHend = 0; SUstart = 0; SUend = 0; w = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; 

utterance_data(ui);
 
% Set phone and audio data for k'th utterance.
    function utterance_data(k)
        [uid,PH,SU,PHstart,PHend,SUstart,SUend] = parse_ali1(Uid,Align,k);
        % Maximum frame index
        [~,F] = size(PH);
        % Load audio. Cat the pipe Scp(uid) into a temporary file.
        cmd = [Scp(uid), ' cat > /tmp/align3_tmp.wav'];
        system(cmd);
        wav = '/tmp/align3_tmp.wav';
        % Read the temporary wav file.
        [w,fs] = wavread(wav);
        % Number of audio samples in a centisecond frame.
        M = fs / 100;
        [nsample,~] = size(w);
        [~,nframe] = size(PH);
    end



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
        plot(SR/M,w(SR));
        sound(w(SR),fs);
        axis([S1/M, SN/M, -0.1, 0.1]);
        
        
        % Draw subphone bars.
        % SU(N) subphone that the Nth frame is in.
        % SUstart(PH(p)) start of pth phone
        for p = (SU(F1) + 1):SU(FN)
           k = SUstart(p);
           bar = line([k,k],[-0.1,0.1],'LineWidth',2.0,'Color',[0.9,0.9,0.9]);
        end
        
        % Draw phone bars.
        for p = (PH(F1) + 1):PH(FN)
           k = PHstart(p);
           bar = line([k,k],[-0.1,0.1],'LineWidth',2.0,'Color','g');
        end
        

        hold;
        pp = patch([F1,FN,FN,F1],[0,0,0.5,0.5],'g');
        ps = patch([F1,FN,FN,F1],[0,0,-0.5,-0.5],'r');
        
        % Function handles for use in gui.
        hspp = @subphoneplay;
        hpp = @phoneplay;
        
        set(ps,'ButtonDownFcn',hspp,... 
            'PickableParts','all','FaceColor','r','FaceAlpha',0.05);

        set(pp,'ButtonDownFcn',hpp,... 
            'PickableParts','all','FaceColor','g','FaceAlpha',0.1);
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
    end

figure();
display_alignment(1);
add_buttons;

end

