function varargout = Excel_Ref_Check(refStr)
%check that the alphanumeric reference for Excel sheet range is valid
%e.g. AA46. Else error out.

narginchk(1,1)
nargoutchk(0,2)

letterRef = regexp(refStr,'[A-Z]'); %check that letters are in range
numRef = regexp(refStr,'\d'); %find numbers

% check if topLeft is a valid reference
% all the characters are capital letters or numbers;
% all the numbers are after all the letters
if length(refStr) ~= length([letterRef numRef])
    error('Not all characters in range string are valid. Check case.')
    
elseif isempty(letterRef) || isempty(numRef)
    error('The Excel reference is incomplete.')
    
elseif  ~(max(letterRef) < min(numRef))
    error('Numbers and letters appear to be in wrong order.')
    
end

if str2double(refStr(numRef)) < 1
    error('Row reference of Excel string must be greater than 0.')
end

if nargout == 1
    varargout{1} = true; %verification that it has worked (for IF arguments)
elseif nargout == 2
    varargout{1} = letterRef;
    varargout{2} = numRef;
end