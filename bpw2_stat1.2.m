function bpw2_stat1(matfile)

if nargin < 1
    matfile = '/local/matlab/Kaldi-alignments-matlab/data-bpn/tab4-sample.mat'; % Made with token_data_bpw2.
end

% Load sets L to a structure. It has to be initialized first.
L = 0;
load(matfile);



% Scale for combining the two weights.
acoustic_scale = 0.083333;
% Then combine by this formulat, see
% /projects/speech/sys/kaldi-master/egs/bp_ldcWestPoint/bpw2/exp/u1/decode_word_1/tab-min.awk
% weight = weight1 +  acoustic_scale * weight2;

% Duration in frames
D = cellfun(@sum,L.phonedur)';

% Combined weights
W1 = cellfun(@(x,y) x + acoustic_scale * y,L.weight1,L.weight2,'UniformOutput',false)';

% Combined weights scaled down by duration.
% This produces weights around 8.
W2 = cellfun(@(x,y) x ./ y,W1,num2cell(D),'UniformOutput',false);

% Logical indices of ultimate-stressed bisyllables,
% and penultimate-stressed bisyllables.
U21 = L.syl == 2 & L.cstress == 1;
U22 = L.syl == 2 & L.cstress == 2;

% Corresponding matrices of weights 
U21w = cell2mat(W2(U21));
U22w = cell2mat(W2(U22));


xlabel('weight 21');

fig1 = figure();
scatter(U21w(1:100,1),U21w(1:100,2),'blue');

hold;
scatter(U22w(1:100,1),U22w(1:100,2),'red');

xlabel('weight per frame 21');
ylabel('weight per frame 22');

axis([7.0 9.5 7.0 9.5]);

diagline = refline([1 0]);
diagline.Color = [0.5 0.5 0.5];
legend('lexical 21','lexical 22','equal weight');


%%%%%%%% Duration %%%%%%%%

% Matrices of vowel duration
U21d = cell2mat(L.voweldur(U21)');
U22d = cell2mat(L.voweldur(U22)');

fig2 = figure();
subplot(1,2,1);
scatter(U21d(1:100,1) + (0.9 * rand(1,100))',U21d(1:100,2) + (0.9 * rand(1,100))','blue');
axis([0 30 0 30]);
legend('lexical 21');
xlabel('initial vowel duration centiseconds (plus 0.9 noise)');
ylabel('final vowel duration centiseconds (plus 0.9 noise)');


subplot(1,2,2);
scatter(U22d(1:100,1) + (0.9 * rand(1,100))',U22d(1:100,2) + (0.9 * rand(1,100))','red');
axis([0 30 0 30]);
legend('lexical 22');
xlabel('initial vowel duration centiseconds (plus 0.9 noise)');
ylabel('final vowel duration centiseconds (plus 0.9 noise)'); 

n = 1;

% L = load_lattice_table(latticefile);

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

