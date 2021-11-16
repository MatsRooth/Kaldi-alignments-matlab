function ls_CAN_realization(part)
% Make a table of realizations for all words in librispeech, for CAN data.
% All words are recorded, not just tokens of CANae1.

if (nargin < 1)
  part = 360;
end

if (part == 100)
 ls_realization('/Volumes/gray/matlab/matlab-mat/lsCAN.mat', '/local/res/phon/stress/datar/lsCAN-realization.tok');
end

if (part == 360)
 ls_realization('/Volumes/gray/matlab/matlab-mat/can360.mat', '/local/res/phon/stress/datar/can360-realization.tok');
end

if (part == 500)
 ls_realization('/Volumes/gray/matlab/matlab-mat/can360.mat', '/local/res/phon/stress/datar/can500-realization.tok');
end


end