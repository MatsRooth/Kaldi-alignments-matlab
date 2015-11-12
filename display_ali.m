function display_ali2(alifile,wavscp,model,phones,transcript)
%  UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Default argument  
if nargin < 5 
    alifile = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/ali.1.gz';
    wavscp = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/train/wav.scp';
    model = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/exp/mono/final.mdl';
    phones = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/lang/phones.txt';
    transcript = '/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/train/text';
end

% Read wav file and alignment for all the utterance IDs.
% Map from uid to wav launch pipes.
Scp = load_kaldi_wavscp(wavscp);

% Read transcript.
Tra = load_kaldi_transcript(transcript);

% For mapping back and forth between phones and their indices.
P = phone_indexer(phones);

% Create and load the alignments in various formats.
% Cell array of Uid, and cell array of alignment vectors.
[Uid,Basic,Align_pdf,Align_phone,Align_phone_len] = load_ali(alifile,model);

% Index in Uid and Align of the utterance being displayed.
ui = 1;

% Maximum value for ui.
[~,U] = size(Uid);

% Initialize some variables that are set in nested functions.
uid = 0; uid2 = 0; F = 0; Sb = 0; Pb = 0; Wb = 0; w = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; 
PX = 0; ya = 0; tra = 0; wi = 1;
Fn = 0; PDF = 0;

utterance_data(ui);
 

% [PH,SU,PHstart,PHend,SUstart,SUend,WRstart,tra] = parse_ali2(uid,Align_pdf,Align_phone,Tra,P,n)

% Set phone and audio data for k'th utterance.
% Values are for utterance k.
    function utterance_data(k)
        uid = cell2mat(Uid(k));
        %[PH,SU,PHstart,PHend,SUstart,SUend,WRstart,tra] = parse_ali(uid,Align_pdf,Align_phone_len,Tra,P,k);
        [F,Sb,Pb,Wb,tra] = parse_ali2(uid,Align_pdf,Align_phone_len,Tra,P,k)
        % tra = Tra(uid);
        % Escape underline for display.
        uid2 = strrep(uid, '_', '\_');
        PX = Align_phone{k};
        PDF = Align_pdf{k}
        % Maximum frame index
        [~,Fn] = size(F);
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
        [~,nframe] = size(F);
    end

    % Range of samples being displayed, this is global.
    SR = [];
    
    function display_alignment(f)
        % f is the suggested start frame
        FN = min([f + 100, Fn]);
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
        % for p = (SU(F1) + 1):SU(FN)
        % For each subphone in the display range, except for the first.
        for p = (F(1,F1) + 1):F(1,FN)
           % k is a frame
           % k = SUstart(p);
           k = Sb(1,p);
           bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.2,0.8,0.8]);
           pdfindex = int2str(PDF(k));
           text(k,ya *  (-0.6 + mod(p,2) * 0.08),pdfindex,'FontSize',12);
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
           %if P.isbeginning(PX(k))
           %if WRstart(p) > 0
           %     bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.85,0.2,0.2]);
           %     text(k,-ya * 0.8,tra(WRstart(p)),'FontSize',18);
           %     wi = wi + 1;
           %else
           %     bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.2,0.2,0.85]);
           % end
           bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.2,0.2,0.85]);
           %text(k,0.09,pn);
           text(k,ya * 0.8,trim_phone(ps),'FontSize',18);
        end
        
        % For each word in the display range, except for the first.
        % for p = (PH(F1) + 1):PH(FN)
        for p = (F(3,F1) + 1):F(3,FN)
           % p is a word index
           % k is frame where phone p starts.
           k = Wb(1,p);
           %pn = int2str(p);
           %ps = P.ind2phone(PX(k));
           %if P.isbeginning(PX(k))
           %if WRstart(p) > 0
           %     bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.85,0.2,0.2]);
           %     text(k,-ya * 0.8,tra(WRstart(p)),'FontSize',18);
           %     wi = wi + 1;
           %else
           %     bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.2,0.2,0.85]);
           % end
           % bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.85,0.2,0.85]);
           bar = line([k,k],[-ya,ya] * 0.99,'LineWidth',2.0,'Color',[0.85,0.2,0.2]);
           text(k,-ya * 0.8,tra(p),'FontSize',18);
           %text(k,0.09,pn);
           % text(k,ya * 0.8,trim_phone(ps),'FontSize',18);
        end

        hold;
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
        subphone = F(1,int16(floor(y.IntersectionPoint(1))));
        disp(sprintf('subphone %d, pdf %d, frame %d-%d',subphone,PDF(Sb(1,subphone)),Sb(1,subphone),Sb(2,subphone)));
        M = fs / 100;
        st = (Sb(1,subphone) - 1) * M;
        en = Sb(2,subphone) * M;
        sound(w(st:en),fs);
    end

    function phoneplay(~,y)
        % phone = PH(int16(floor(y.IntersectionPoint(1))));
        phone = F(2,int16(floor(y.IntersectionPoint(1))));
        disp(sprintf('phone %d, frame %d-%d',phone,Pb(1,phone),Pb(2,phone)));
        M = fs / 100;
        st = (Pb(1,phone) - 1) * M;
        en = Pb(2,phone) * M;
        sound(w(st:en),fs);
    end

    function wordplay(~,y)
        word = F(3,int16(floor(y.IntersectionPoint(1))));
        % Value is 0 in a silence.
        if word > 0
            disp(sprintf('word %d, frame %d-%d',word,Wb(1,word),Wb(2,word)));
            M = fs / 100;
            st = (Wb(1,word) - 1) * M;
            en = Wb(2,word) * M;
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
        ui = ui + 1;
        wi = 1;
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
% nonzeros(cellfun(@(x) strcmp(x,'ahh05_sr221_trn'),C))

    hnu = @next_utterance;
    hpu = @previous_utterance;
    hinc = @increment_frame;
    hdec = @decrement_frame;
    hcurr = @play_current;
    hall = @play_all;
    huid = @new_by_uid;
    
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

    %function pe = word_last_phone(pi)
    %    % Default is last phone in the utterance.
    %    pe = length(WRstart);
    %    for pk = (pi+1):length(WRstart):
    %        if WRstart[pk] > 0
    %            pe = pk;
    %           break;
    %       end
    %end

    function add_buttons 
        bprev = uicontrol('Callback',hpu,'String','<U','Position', [10 10 25 25]);
        bnext = uicontrol('Callback',hnu,'String','U>','Position', [40 10 25 25]);
        bdec = uicontrol('Callback',hdec,'String','<F','Position', [90 10 25 25]);
        binc = uicontrol('Callback',hinc,'String','F>','Position', [120 10 25 25]);
        bcurr = uicontrol('Callback',hcurr,'String','P','Position', [160 10 25 25]);
        ball = uicontrol('Callback',hall,'String','A','Position', [200 10 25 25]);
        euid = uicontrol('Callback',huid,'Style','edit','Position',[260 10 120 25]);
        title([int2str(ui),' ',uid2],'FontSize',18);
    end

figure();
display_alignment(1);
add_buttons;      

%title([ui,' ',uid2],'FontSize',18);


% ui  index in Uid and Align of the current token
% uid utterance ID of current token

end

