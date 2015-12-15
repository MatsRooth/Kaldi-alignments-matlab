function [F,Sb,Pb,Wb,tra] = parse_ali(uid,Align_pdf,Align_phone,Tra,P,n)
  % INPUTS:
  %   uid:  utterance id 
  %   Align_pdf: cell array of sequences/vectors of pdf-ids
  %   Align_phone: cell array of [phone-ids; lengths] matrices
  %   Tra: transcript - map from key/uid to text (cell array of string)
  %   P: map between phones and indices
  %   n : index of utterance of interest
  %
  % OUTPUTS:
  %   F : subphone/phone/word occupying each frame
  %     column index: frames
  %     row 1: index of token subphone that the frame is in
  %     row 2: index of token phone that the frame is in
  %     row 3: index of token word that the frame is in
  %   Sb (subphone boundary) - (2 by num_subphones) matrix where 1st row is
  %                            start frame for each subphone, 2nd row end
  %                            frame for each subphone (inclusive)
  %   Pb (phone boundary) - like Sb, but for phones
  %   Wb (word boundary) - like Sb, but for words
  %   tra : cell array of string - transcript for utterance of interest


  % Default arguments. Need adjustment
  if nargin < 6
    [Uid,~,Align_pdf,~,Align_phone] = load_ali();
    Tra = load_kaldi_transcript('/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/train/text');
    P = phone_indexer('/projects/speech/sys/kaldi-trunk/egs/rm/s5/data/lang/phones.txt');
    n = 1;
    uid = cell2mat(Uid(n));
  end

  % Vector indexed by frames giving the pdf used for each frame.
  alipdf = Align_pdf{n};

  % Matrix indexed by token phone indices, giving the phone ID for each
  % token phone in row 1, and the number of frames it occupies in row 2.
  aliphone = Align_phone{n};

  % (horizontal) cell array of words
  tra = Tra(uid);

  % Number of frames in the utterance.
  [~,num_frames] = size(alipdf);

  % Number of phones the utterance.
  [~,num_phones] = size(aliphone);

  % Number of words the utterance.
  [~,num_words] = size(tra);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %  Initialize return values. 
  %  Documentation is at the start.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Columns indexed by frames.
  % In row 1, the token supphone index occupying the frame.
  % In row 2, the token phone index occupying the frame.
  % In row 3, the token word index occupying the frame.
  F = zeros(3,num_frames);

  % Start frame (row 1) and end frame (row 2) of the token phone.
  % Entries are frame indices.
  Pb = zeros(2,num_phones);

  % Same for words.
  Wb = zeros(2,num_words);

  % Same for supphones. Nf is an upper bound on the number of suphones,
  % trim the matrix later.
  Sb = zeros(2,num_frames);

  % Phone and subphone indices used in the frame iteration.  
  phone_index = 1;
  subphone_index = 1; 


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %  Set values for frame 1, phone 1, and subphone 1.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % The first frame is in phone 1 and subphone 1.
  F(1,1) = 1;
  F(2,1) = 1;

  % The first phone and subphone start at frame 1.
  Pb(1,1) = 1;
  Sb(1,1) = 1;
  % Current phone in index form.
  current_phone = aliphone(1,phone_index);

  % Remaining number of frames for current phone, including 
  % the current one.
  num_remaining_frames = aliphone(2,phone_index);

  % word index
  word_index = 0;
  % Like word_index, but is 0 outside words.
  current_word = 0;

  % Does a word start already at frame 1?
  if P.isbeginning(current_phone)
    word_index = word_index + 1;
    current_word = word_index;
    Wb(1,word_index) = 1;
  end


  % For each frame starting after frame 1.
  for frame = 2:num_frames
    num_remaining_frames = num_remaining_frames - 1;
    % If there is a new subphone. This can miss a non-final subphone when
    % pdfs are shared. The necessary information seems to not be available
    % in the output of the ali-to-xxxx programs.
    if alipdf(frame-1) ~= alipdf(frame) || num_remaining_frames == 0
      % Mark end of previous token subphone.
      Sb(2,subphone_index) = frame - 1;
      subphone_index = subphone_index + 1;
      % Record start of new subphone.
      Sb(1,subphone_index) = frame;
      % If there is an new phone according to aliphone
      if num_remaining_frames == 0 
        % Record end of previous phone.
        Pb(2,phone_index) = frame - 1;
        % If phone filler is a word end, record the end of wi.
        % Without the check, this caused an error with wi = 0.
        if P.isend(current_phone) && word_index > 0
          Wb(2,word_index) = frame - 1;
          current_word = 0;
        end
        phone_index = phone_index + 1;
        % Record start of new phone.
        Pb(1,phone_index) = frame;
        % New phone filler and number of frames remaining.
        current_phone = aliphone(1,phone_index);
        num_remaining_frames = aliphone(2,phone_index);
        % If current phone filler is a word beginning.
        if P.isbeginning(current_phone)
          word_index = word_index + 1;
          current_word = word_index;
          Wb(1,word_index) = frame;
        end
      end 
    end
    % Record token phone, token subphone, and token word indices for current frame.
    F(1,frame) = subphone_index;
    F(2,frame) = phone_index;
    F(3,frame) = current_word;
  end

  % The last frame ends the last phone and the last subphone.
  Pb(2,phone_index) = num_frames;
  Sb(2,subphone_index) = num_frames;

  % If the last word doesn't have it's end marked, marked it as Nf.
  if Wb(2,word_index) == 0
      Wb(2,word_index) = num_frames;
  end

  % Reduce Sb and Pb to initial parts, since they
  % are indexed as subphones or phones rather than frames.
  Sb = Sb(:,1:subphone_index);

  Pb = Pb(:,1:phone_index); 
end
