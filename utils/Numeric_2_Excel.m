function ExcelString = Numeric_2_Excel(vec,varargin)
%convert a number into a Excel alphabetical column reference
% e.g. 1 == A
%      26 == Z
%      100 == CV
%      702 == ZZ
%      703 == AAA
%
% Input Arguments:
%   Column number to convert into a aphabetical reference
%   (optional) offset to shift columns (otherwise default is starting
%   at A1). Offset is such that [0 0] doesn't shift the current array.
%   For example, Offset = [5,1] would shift A1 to B6.
%
% See also EXCEL_2_NUMERIC, EXCEL_REF_CHECK.

narginchk(1,2)

%make sure number is a two element positive vector:
if ~isnumeric(vec)
    error('Cell reference must be numeric.')
elseif length(vec) ~= 2
    error('Cell reference must be a 2 element vector.')
    
elseif any(vec < 1)
    error('Minimum element value of 2 element vector is 1.')
    
end

if nargin > 1
    %add offset to shift columns
    Offset = varargin{1};
    if ~isnumeric(Offset)
        error('offset argument must be an integer above 0')
        
    elseif numel(Offset) ~= 2
        error('Offset must be a 2 element vector.')
        
    end
    
    Offset = round(Offset); %round just in case isn't integer
    if all(Offset >= 0)
        vec = vec + Offset;
        
    else
        error('Offset vectors must have integers > 0')
        
    end
end

%split vec into row and column indicies:
row = vec(1);
col = vec(2);

Order = Order_Calc(col); %send to function to get order of number

alphaStr = Alpha_Base(col,Order);
%form Excel reference string:

ExcelString = sprintf('%s%0d',alphaStr,row);



function Order = Order_Calc(n)
%calculate order of number for weird base 26/27 scheme;
%e.g. 1 = order 0
%     26 = order 0
%     27 = order 1
%     702 = order 1
%     703 = order 2

s = 0;
Order = -1;
while s <= n
    Order = Order + 1;
    s = sum(26.^(0:Order));
end

Order = Order - 1;

function alphaStr = Alpha_Base(n,Order)
%loop through orders to split up order columns (start with largest order
%and work down to least significant.

p = 26.^(Order:-1:0); %matrix of powers

valArray = zeros(1,Order+1);
for I = 1: Order + 1
    valArray(I) = floor(n/ p(I));
    
    %catch for 26:
    if valArray(I) == 0
        valArray(I) = 26;
        valArray(I-1) = valArray(I-1) - 1;
    end
    
    %get remained for next iteration:
    n = n - p(I)*valArray(I);
end

%convert to letters using ASCII
alphaStr = char(valArray+64);