for f in `cat /local/matlab/Kaldi-alignments-matlab/copy.txt`; do echo $f; cp -R $f .; done
rm -R matlab-mat/*
rm -R matlab-wav/*
cp /local/matlab/Kaldi-alignments-matlab/matlab-mat/ls3ademo.mat matlab-mat
cp -R /local/matlab/Kaldi-alignments-matlab/matlab-wav/ls3ademo matlab-wav

