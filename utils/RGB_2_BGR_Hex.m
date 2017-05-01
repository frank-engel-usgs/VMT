function excelColour = RGB_2_Hex(colourVec)
% converts normalized RGB vector into a base 10 number representing a BGR
% hexadecimal colour for Excel
% input arguments:
%       colourVec: n by 3 numeric array, either normalised (between 0 and
%       1) or 8 bit (between 0 and 255)

%check input is valid:
if ~isnumeric(colourVec)
    error('RGB vector must be numeric.')
elseif size(colourVec,2) ~= 3
    error('RGB vector must be an n by 3 array')
elseif any(colourVec(:) > 1)
    error('RGB vector must be between 0 and 1.')
end

%make into 8 bit number for Excel
colourVec = round(colourVec*255);

%create a cell array of hex values (1 value per vec22 element)
cellHex = reshape(cellstr(dec2hex(colourVec,2))',[],3);

%concenecate each element to produce one BGR hex string per RGB row
excelColour = hex2dec(strcat(cellHex(:,3) , cellHex(:,2) , cellHex(:,1)));