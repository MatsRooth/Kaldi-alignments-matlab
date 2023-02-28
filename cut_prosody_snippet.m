function cut_prosody_snippet(target,part,longtarget,omit,limit1,limit2)

if nargin < 1
  target = 'in+my';
  longtarget = 'in+my+experience';
  part = '2000';
  omit = 0;
  limit1 = 1.5;
  limit2 = 3.0;
end

if (part ~= 0)
    base = [longtarget '_' part];
else
    base = longtarget;
end

fiyou = '/local/res/fiyou';
datfile = [fiyou '/matlab/' base '.mat'];
audiodir = [fiyou '/data/' longtarget '/audio_' part];
outdir = [fiyou '/data/' longtarget '/snippet_' part];

% Make the out directory
system(['test -d ' outdir '|| mkdir ' outdir]);

targetwds = upper(strsplit(target,'+'));
%disp(targetwds);

longtargetwds = upper(strsplit(longtarget,'+'));
%disp(longtargetwds);

targetwd1  = targetwds{1};
targetwd2  = targetwds{2};

%Load sets dat to a structure.
load(datfile,'dat');

Scp = dat.scp;
P = dat.phone_indexer;
Uid = dat.uid;
%Wrd = dat.wrd;
Basic = dat.basic;
Align_pdf = dat.pdf;
Align_phone = dat.align_phone;
Align_phone_len = dat.phone_seq;
Tra = dat.tra;
 
% Index in Uid and Align of the utterance being displayed.
ui = 1;

% Maximum value for ui.
[~,U] = size(Uid);

% Initialize some variables that are set in nested functions.
uid = 0; uid2 = 0; F = 0; Sb = 0; Pb = 0; Wb = 0; w = 0; w2 = 0; fs = 0;

M = 0; S1 = 0; SN = 0; N = 100;
F = 0; F1 = 0; FN = 0; nsample = 0; nframe = 0; nword = 0;
PX = 0; ya = 0; tra = 0; wi = 1;
Fn = 0; PDF = 0; spect = 0;

% Pitch.
% Return values for fxrapt.
fx = 0; tt = 0; 
% Version of tt with frame indexing.
ttf = 0;
% ttf and fx restricted to the frames being displayed.
fx3 =0; tt3=0;
AX = 0;

utterance_data(ui);

%disp(tra);

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
    
        [w,fs] = audioread(wav); 
        w2 = w;
        [~,ch] = size(w);
        if (ch == 2)
            w = w(:,2);
        end
        M = fs / 100;
        [nsample,~] = size(w);
        [~,nframe] = size(F);
        [~,nword] = size(Wb);
        % pitch
        % [fx,tt]=fxrapt(w,fs);
    end

    function snippet(k)
        utterance_data(k);
        long_offset = find_target(longtargetwds);
        % If the long target is not found.  It happens for 26.9 in 
        % I+have+one+now.
        if (long_offset < 1)
           return; 
        end
        offset = find_target(targetwds,long_offset);
        %disp(offset)
        if (offset > 0)
            st = max(1,floor((Wb(1,offset) - 1) * M));
            mid = max(1,floor((Wb(2,offset) - 1) * M));
            en = max(1,floor((Wb(2,offset + 1) - 1) * M));
            
            st2 = max(1,floor((Wb(1,max(offset - 1,0)) - 1) * M));
            en2 = max(1,floor((Wb(2,min(offset + 2,nword)) - 1) * M));
            
            snippet_wav = w(st:en);
            snippet_wav2 = w(st2:en2);
            
            swav1 = w(st:mid);
            swav2 = w(mid:en);

            % soundsc(snippet_wav,fs);
        
            outfile = [outdir,'/',Uid{k},'.wav'];
            outfile2 = [outdir,'/',Uid{k},'.long.wav'];
        
            disp(outfile);
            disp(offset);
            len1 = length(snippet_wav) / fs;
            len2 = length(snippet_wav2) / fs;
            disp(len1);
            disp(len2);
            %pad1 = randn(fs - length(swav1),1) * 0.005;
            pad1 = zeros(fs - length(swav1),1);
            pad2 = zeros(fs - length(swav2),1);
            
            
            snippet_wav = [pad1;swav1;swav2;pad2];
            soundsc(snippet_wav,fs);
            

            
            % spect = v_spgrambw(snippet_wav,fs,'pJcw');
            
            disp(length(snippet_wav) / fs );
            
            if (len1 < limit1)
                audiowrite(outfile,snippet_wav,fs);
                audiowrite(outfile2,snippet_wav2,fs);
            end
        end
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

% The below gave an error for the item with tra
% {'IN'}    {'MY'}    {'EXPERIENCE'}    {'ALL'}    {'THE'}    {'OTHER'}    {'OPTIONS'}    {'HAVE'}    {'SOLID'}
%    {'SUPPORT'}    {'BUT'}    {'DO'}    {'HAVE'}    {'ROOM'}    {'TO'}    {'IMPROVE'}    {'IN'}    {'MY'}    {'EXPERIENCE'}
% apparently because longtarget is found twice. Try to fix this by setting
% the default k to 2 rather than 1.

    function res = find_target(tw,k)
        if nargin < 2
            % k = 1;
            k = 2;
        end
        if nargin < 1
            tw = targetwds;
        end
        res = 0;
        tlen = length(tw);
        %for i = 1:(length(tra) - tlen)
        for i = k:(length(tra) - tlen + 1)
            if all(strcmp(tw, tra(i:(i + tlen - 1))))
                %disp(strcmp(tw, tra(i:(i + tlen - 1))))
                res = i;
                break;
            end
        end  
    end

 

for k = 1:U
%for k = 1:8
    snippet(k);
    pause(0.5);
end

 
end

