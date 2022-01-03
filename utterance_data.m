function cur = utterance_data(dat, audiodir, k)
   % Default arguments for demo. 
    if nargin < 2
        load('/Volumes/Gray/matlab/matlab-mat/can100nosp.mat','dat');
        audiodir = '/Volumes/Gray/matlab/matlab-wav/lsCAN';
        k = 5;
    end
    
    cur.uid = cell2mat(dat.uid(k));
    [cur.F,cur.Sb,cur.Pb,cur.Wb,cur.tra] = parse_ali(cur.uid,dat.pdf,dat.phone_seq,dat.tra,dat.phone_indexer,k);
        % Escape underline for display.
        cur.uid2 = strrep(cur.uid, '_', '\_');
        cur.PX = dat.align_phone{k};
        cur.PDF = dat.pdf{k};
        % Maximum frame index
        [~,cur.Fn] = size(cur.F);
        % Load audio. Cat the pipe dat.scp(uid) into a temporary file.
        % cmd = [dat.scp(uid), ' cat > /tmp/display_ali_tmp.wav'];
        % This helps flac work.
        % setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
        % system(cmd);
        % wav = '/tmp/display_ali_tmp.wav';
        % Read the temporary wav file.
        % [w,fs] = audioread(wav);
        % Number of audio samples in a centisecond frame.
        cur.wav = find_audio(cur.uid);
        disp(cur.wav);
        [cur.w,cur.fs] = audioread(cur.wav); 
        
        % Deal with possibility of two channels.
        cur.w2 = cur.w;
        [~,ch] = size(cur.w);
        if (ch == 2)
            cur.w = cur.w(:,2);
        end
        
        cur.M = cur.fs / 100;
        [cur.nsample,~] = size(cur.w);
        [~,cur.nframe] = size(cur.F);
        % pitch
        [cur.fx,cur.tt]=v_fxrapt(cur.w,cur.fs);
   

    function wav = find_audio(uid)
        % Load the audio, either by using Kaldi to generate a tmp wav file,
        % or by reading from audiodir
        if (audiodir ~= 0)
            wav = [audiodir '/' uid '.wav'];
        else
            % Cat the pipe dat.scp(uid) into a temporary file.
            cmd = [dat.scp(uid), ' cat > /tmp/display_ali_tmp.wav'];
            % This helps flac work.
            setenv('PATH', '/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin');
            system(cmd);
            wav = '/tmp/display_ali_tmp.wav';
        end
    end


% Demo output
%        uid: '103-1240-0004-V'
%          F: [3×1250 double]
%         Sb: [2×464 double]
%         Pb: [2×156 double]
%         Wb: [2×42 double]
%        tra: {1×42 cell}
%       uid2: '103-1240-0004-V'
%         PX: [1×1250 double]
%        PDF: [1×1250 double]
%         Fn: 1250
%        wav: '/Volumes/Gray/matlab/matlab-wav/lsCAN/103-1240-0004-V.wav'
%          w: [200240×1 double]
%         fs: 16000
%          M: 160
%    nsample: 200240
%     nframe: 1250
%         fx: [970×1 double]
%         tt: [970×3 double]
 
end
