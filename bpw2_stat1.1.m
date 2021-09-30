function [Uid,Basic,Pdf,Phone,Phone_seq] = bpw2_stat1(tabfile,tokenfile)
 
if nargin < 1
    tabfile = '/projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/bpw2/exp/u1/decode_word_1/tab4';
    tokenfile = '/local/matlab/Kaldi-alignments-matlab/data-bpn/bp0V.tok'
end

% /local/matlab/Kaldi-alignments-matlab/data-bpn/bp0V.tok has vowel
% durations as computed with token_data_bpn.


tab_stream = fopen(tabfile);

n = 1;

% Iterate through the lines of the table
line_tab = fgetl(tab_stream);
while (ischar(line_tab) && n < 30)
    part = strsplit(line_tab,'\t');
    if (length(part) == 9)
        [uid,word_form1,word_form2,syl_count,citation_stress,decode_stress,weight1,weight2] = parse_line(line_tab);
        acoustic_scale = 0.083333;
        % See
        % /projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/bpw2/exp/u1/decode_word_1/tab-min.awk
        weight = weight1 +  acoustic_scale * weight2;
        % Decode_stress and lattice_stress should be the same. They are.
        [m,lattice_stress] = min(weight);
        if (lattice_stress ~= citation_stress)
            fprintf("%s\t%s\t%d\t%d\t%d\t%d\n",uid,word_form1,syl_count,citation_stress,decode_stress,lattice_stress);
            % ultimate, penultimate ...
            fprintf("%d ",weight);
            fprintf("\n");
        end
    end
    line_tab = fgetl(tab_stream);
    n = n+1;
end

fclose('all');

% Parse a line into a key and a vector of int.
function [key,a] = parse_alignment(line)
    key = sscanf(line,'%s',1);
    [~,klen] =  size(key);
    [~,llen] = size(line);
    line = line((klen+1):llen);
    a = sscanf(line,'%d')';
end

% Parse a line from the table.
% The input line looks like this.
% f58br08b11k1-s087-2	abacaxi	abacaxi_U411	4	1	1	4.45933 4.46457 4.43014 4.40614	5115.16 5122.39 5166.43 5153.47	362_364_3
% uid                   wf1     wf2             syl cit dec [w1] [w2]
%   bns04_st1921_trn 1 12 ; 6 7 ; 143 3 ; 50 8 ; 60 3 ; 143 4 ; 146 13
function [uid,word_form1,word_form2,syl_count,citation_stress,decode_stress,weight1,weight2] = parse_line(line)
    part = strsplit(line,'\t');
    uid = part{1};
    word_form1 = part{2};
    word_form2 = part{3};
    syl_count = str2num(part{4});
    citation_stress = str2num(part{5});
    decode_stress = str2num(part{6});
    weight1 = str2num(part{7});
    weight2 = str2num(part{8});
end



end

