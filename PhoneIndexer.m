classdef PhoneIndexer
    % Map back and forth between phone indices and spelling forms, and look
    % up properties of phones.
    % Demo:
    %  P = PhoneIndexer('/projects/speech/sys/kaldi-trunk/egs/librispeech/s5/data/lang_nosp/phones.txt')
    properties
       % Map from int indices to spelling form of phones
       Map
       % Cell array of spellings
       Spell
       % Cell array of short spellings
       ShortSpell
       % Info about beginning/end status of long phone.
       % Is the phone index a word-beginning such as as 'ay_B', singleton 'ay_S', word-end 'ay_E'?
       % 1 beginning
       % 2 singleton
       % 3 end
       % 0 other
       Be
       % Stress class: 0, 1 or 2, or -1 if there is no stress mark.
       Stress
    end
    
    methods
      %phone_index.ind2phone = f1; 
      function phone = ind2phone(obj,j)
        phone = obj.Spell{j+1};
      end
      
      function phones = inds2phones(obj,X)
        X1 = X + ones(size(X));
        phones = obj.Spell(X1);
      end
    %phone_index.ind2shortphone = f1s; 
      function phone = ind2shortphone(obj,j)
        phone = obj.ShortSpell{j+1};
      end
      
      function phones = inds2shortphones(obj,X)
        X1 = X + ones(size(X));
        phones = obj.ShortSpell(X1);
      end
       
    %phone_index.phone2ind = m;
      function ind = phone2ind(obj,ph)
        ind = obj.Map(ph);
      end
      
      function p = isbeginning(obj,j)
          p = (obj.Be(j+1) == 1 | obj.Be(j+1) == 2);
      end
      
      function p = isend(obj,j)
          p = (obj.Be(j+1) == 2 | obj.Be(j+1) == 3);
      end
      
      function stresslevel = stress(obj,j)
          stresslevel = obj.Stress(j+1);
      end
      
      % Constructor from filename
      function obj = PhoneIndexer(filename)
        obj.Map = containers.Map();
        obj.Spell = {};
        obj.ShortSpell = {};
        obj.Be = {};
        obj.Stress = {};
        istream = fopen(filename);

        % Iterate through the lines of alignments
        line = fgetl(istream);

        while ischar(line)
            A = strsplit(line);
            % Spelling of the phone.
            ph = A{1};
            % Index of the phone.
            k = str2num(A{2});
            % Map the spelling to the index.
            obj.Map(ph) = k;
            % Record the spelling for the index.
            obj.Spell{k+1} = ph;
            obj.ShortSpell{k+1} = trim_phone(ph);

            %line = fgetl(istream);
            % Is it a word-beginning
            [~,le] = size(char(ph));
            % disp(ph); disp(le);
            ph2 = char(ph);
            % beginning or singleton phone
            if strcmp(ph2(le-1:le),'_B')
              obj.Be{k+1} = 1;
            elseif strcmp(ph2(le-1:le),'_S')
                obj.Be{k+1} = 2;
            elseif strcmp(ph2(le-1:le),'_E')
                obj.Be{k+1} = 3;
            else obj.Be{k+1} = 0;
            end
            % Stress class
            obj.Stress{k+1} = stress(ph2);
            line = fgetl(istream);
        end
        fclose(istream);
        obj.Be = cell2mat(obj.Be);
        obj.Stress = cell2mat(obj.Stress);
      end

    end
end

function n = stress(p)
    if strfind(p,'0')
       n = 0;
    elseif strfind(p,'1') 
            n = 1;
    elseif strfind(p,'2')
            n = 2;
    else n = -1;
    end
end

function p2 = trim_phone(p)
    % Remove the part of phone symbol p after '_'.
    %p = p{1};
    p2 = p;
    loc = strfind(p,'_');
    if loc
        p2 = p2(1:(loc - 1));
    end
end
