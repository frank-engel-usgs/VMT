function varargout = Display_Excel_Format_Options(varargin)
% Displays the fields that can be modified using the properties structure.
% Arguments in:
%       dispFlag (optional): true/ false flag to determine whether to
%       display the fields at the command line.
%       intFlag (optional): true/ false flag to determine whether to hide
%       the interfaces within the Range interface. These currently aren't
%       supported by the program. Note that Font, Interior and Border
%       interfaces are displayed.
%
% Arguments out: S: structure containing the fields available to modify for
% the following interfaces:
%
% Range (cell range that the data will be written to)
% Font (child of Range)
% Interior (child of Range)
% Border (child of Range): note that the Border interface isn't accessed
% directly as per the other fields; to format a border, the border item
% (e.g. EdgeTop, InsideVertical) must be selected from the Border
% interface, and then the properties set.
%
% The structure should work with any field in the Range interface, but the
% PROCESS_MAIN_ROUTINE function sends to some
% other functions (whose names begin with PROCESS) which perform some
% checks and processing on the inputs. The PROCESS_MISC function attempts
% to apply any fields in the properties structure that aren't covered by
% the other routines.

% parse input arguments:
narginchk(0,2)
nargoutchk(0,1)

%1: display at command line:
if nargin > 0
    dispFlag = varargin{1};
    if ~(islogical(dispFlag) || isnumeric(dispFlag) && (dispFlag == 0 || dispFlag == 1))
        error('Input argument 1 must be a logical flag.')
    end
else
    dispFlag = true;
end

%2: show interface fields:
if nargin > 0
    intFlag = varargin{2};
    if ~(islogical(intFlag) || isnumeric(intFlag) && (intFlag == 0 || intFlag == 1))
        error('Input argument 2 must be a logical flag.')
    end
else
    intFlag = false;
end



Excel = actxserver('excel.application');
book = Excel.Workbook.Add;

%RANGE INTERFACE:
Range = book.ActiveSheet.Range('A1:A1');
S.Range = Range.get;

if ~intFlag
    %remove interface fields
    S.Range = Remove_Interface_Fields(S.Range);
end

if dispFlag
    fprintf('\nThe fields for the Range interface are: \n')
    disp(S.Range)
    fprintf('______________________________________________________\n')
end

%FONT INTERFACE:
S.Font = Range.Font.get;

if ~intFlag
    %remove interface fields
    S.Font = Remove_Interface_Fields(S.Font);
end

if dispFlag
    fprintf('\nThe fields for the Font interface are: \n')
    disp(S.Font)
    fprintf('______________________________________________________\n')
end


% BORDER INTERFACE: (get the first border item - item 5)
S.Border = Range.Border.Item(5).get;

if ~intFlag
    %remove interface fields
    S.Border = Remove_Interface_Fields(S.Border);
end

if dispFlag
    fprintf('\nThe fields for a border interface are: \n')
    disp(S.Border)
    fprintf('______________________________________________________\n')
end


% INTERIOR INTERFACE:
S.Interior = Range.Interior.get;

if ~intFlag
    %remove interface fields
    S.Interior = Remove_Interface_Fields(S.Interior);
end

if dispFlag
    fprintf('\nThe fields for the Interior interface are: \n')
    disp(S.Interior)
    fprintf('______________________________________________________\n')
end

book.Close;
Excel.Quit;
Excel.delete;

if nargout > 0
    varargout{1} = S;
end

function S = Remove_Interface_Fields(S)
% remove any interface fields from the structure.

Fields = fieldnames(S);
for n = 1:length(Fields)
    
    if isinterface(S.(Fields{n}))
        S = rmfield(S,Fields{n});
    end
    
end



