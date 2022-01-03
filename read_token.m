function Tok = read_token(tokenfile, verbose)
% From a token file, construct
Tok.Tu = {};  % Cell array of uids for tokens.
Tok.To = [];  % Vector of word offsets for tokens.
Tok.max = 0;  % Maximum index

if nargin < 1
    tokenfile = '/local/res/some/parse/pps.tok';
end

if nargin < 2
   verbose = 0;
end

% Running index.
j = 1;

token_stream = fopen(tokenfile);

itxt = fgetl(token_stream);
while ischar(itxt)
    if (verbose > 0) 
        disp(itxt);
    end
    itxt = strtrim(itxt);
    part = strsplit(itxt);
    uid = part{1};
    offset = str2num(part{2});
    Tok.Tu{j} = uid;
    Tok.To(j) = offset;   % This was formerly a cell
    itxt = fgetl(token_stream);
    j = j + 1;
end
fclose(token_stream);

Tok.max = j - 1;

end

% struct with fields:

% Tu: {1×118 cell}
% To: [1×118 double]
% max: 118

