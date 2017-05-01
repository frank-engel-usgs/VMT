function varargout = Excel_Write_Format(varargin)
% EXCEL_WRITE_FORMAT Writes to Excel with the ability to format the spreadsheet.
% A COM server is used for this can only be run on Windows computers.
%
% EXCEL_WRITE_FORMAT(fileNames , Data)
% EXCEL_WRITE_FORMAT(fileNames , Data , topLeft)
% EXCEL_WRITE_FORMAT(fileNames , Data , propStruct)
% EXCEL_WRITE_FORMAT(fileNames , Data , topLeft , propStruct)
% EXCEL_WRITE_FORMAT(fileNames , Data , topLeft , sheetNames)
% EXCEL_WRITE_FORMAT(fileNames , Data , topLeft , sheetNames, propStruct)
%
% Arguments in:
%
%   fileName: the filename to open/ save the spreadsheet as. The default
%   file extension is .xlsx ; xls (97-2003) and CSV can also be used,
%   though CSV won't keep any of the formatting or topLeft position. 
%
%   Data: the data to be written to the spreadsheet.
%
%   topLeft (optional): The reference for the top left corner of the
%   spreadsheet; this can be in Excel notation (e.g. B3) or a 2x1 
%   numeric vector (e.g. [3,2]). Otherwise, topLeft is taken as A1.
%
%   sheetName (optional): The name of the worksheet in the workbook. This
%   can be an existing sheet, or the name for a new one.
%       
%   propStruct (optional): A structure of properties to format the
%   spreadsheet. This consists of sub-structures relying on the
%   COM interface syntax.
%
%   if sheetName is to be specified, then topLeft must also be
%   specified as an earlier argument; this avoids confusion as the
%   strings are potentially interchangable (e.g. sheetName could be
%   'A1'). In this case, topLeft can be left empty.
%   propStruct can be passed in without specifying sheetName or
%   topLeft, but must be the last argument.
%
% Arguments out:
%   fileName (optional): output the fileName cell array, which may have
%   been modified (they will have a file path and extension)
%
% Argument lengths:
% The function supports multiple read requests, including writing to the
% same file several times (this should also be quicker than repeated
% calls to XLSREAD as the COM server is held open for the entire
% operation); in this case, ALL inputs should be in cell arrays; do not use
% a vector structure for the formatting information.
%
% DETAILS:
%
% Properties Structure:
% The properties structure largely mimics how the COM interface works: all
% fields are based around the Range interface, or children of it. To see
% what fields can be modified and their default values, run
% DISPLAY_EXCEL_FORMAT_OPTIONS. this program focuses on the following
% properties: font (size, bold etc.), interior (e.g. cell colour), Borders
% (line style, line weight etc.), and finally the range interface itself
% (e.g. column width).
% Note that Excel uses a hexadecimal BGR reference - this format can be 
% generated from normalised RGB data using RGB_2_HEX.)
% For example, in order to set the font size to 12, the following code is 
% used (where Range is the handle to the range interface):
%
%   Range.Font.Size = 12;
%
% To perform this, propStruct must have the following field:
%
%   propStruct.Font.Size = 12.
%
% Most of the common options follow this trend, e.g.
%
%   propStruct.Range.ColumnWidth = 10;
%   propStruct.Interior.Color = RGB_2_HEX([0.05 0.35 0.7])
%
% A notable exception is the border interface, which requires extra depth.
% Before the options can be set, the specific border must be requested
% (e.g. the EdgeTop border, or InsideVertical). The structure in this case
% might look like:
%
%   propStruct.Border.EdgeLeft.LineStyle = 'DashDot';
%   propStruct.Border.InsideVertical.Weight = 2;
%
%
% Enumerations:
% Some properties use enumerations, such as the underline property of
% the font interface. The text argument is switched for a number recognised
% by Excel, based on the xlUnderlineStyle Enumeration. 
% The properties structure accepts the Enum value or the Enum string, which
% can either be the full Excel Enum string, or a shortened version without
% the Enum preface.
% For example, to double-underline the text:
%
%   propStruct.Font.Underline = 'xlUnderlineStyleDouble';
%   propStruct.Font.Underline = 'Double';
%   propStruct.Font.Underline = -4119;
%
% All equate to the same thing.
% The exception is the border type enumeration. These cannot be numeric as
% they form structure names. However, the 'xl' preface to the border name
% can be ignored; for example:
%
%   propStruct.xlEdgeBottom.Weight = 2
%   propStruct.EdgeBottom.Weight = 2
%
% Equate to the same thing, although if the shortened version is used, it
% is replaced with the full version by the PROCESS_BORDER function.
%
% For convenience, three additional border options can be used as well as 
% the standard enumeration options. These are:
%
%   InsideAll: create InsideHorizontal and InsideVertical lines
%   OutsideAll: create EdgeTop, EdgeLeft, EdgeBottom and EdgeRight lines
%   All: create InsideAll and OutsideAll lines.
%
% For these three options, all lines created have the same properties of
% that structure's fields.
%
% <a href="http://msdn.microsoft.com/en-us/library/office/ff838815.aspx">The Enumerations are listed at MSDN.</a>
%
% See also WRITE_FORMAT_EXAMPLE, DISPLAY_EXCEL_FORMAT_OPTIONS ,RGB_2_BGR_HEX
%
% Written by Tom Bruen.
% To point out the inevitable bugs or offer suggestions, contact me at
% tom.bruen@gmail.com
%
% Change log:
% v1.0 27/06/2013

narginchk(2,5)
nargoutchk(0,1)

%check to see if there are multiple data sets to write, or just one
if ischar(varargin{1}) || (iscell(varargin{1}) && length(varargin{1}) == 1)
    %single request
    nRequests = 1;
    
    % put each element of varargin in a cell so they can be referenced in
    % the loop below.
    varargin = cellfun(@(x) {x},varargin,'UniformOutput',false);

else
    %multiple write requests: 
    argLength = cellfun(@numel,varargin);
    
    % check each argument is a cell array and all cells have the same length
    if all(cellfun(@iscell,varargin)) && all(mean(argLength) == argLength)
    nRequests = argLength(1);
    else
        error('For multiple write requests, all arguments should be cell arrays of the same length')
    end
end

tic
% send to function to process inputs (outputs all 5 possible arguments even
% if some are empty)
fileName = cell(nRequests,1);
Data = cell(nRequests,1);
topLeft = cell(nRequests,1);
sheetName = cell(nRequests,1);
propStruct = cell(nRequests,1);
for n = 1:nRequests
    [fileName{n} Data{n} topLeft{n} sheetName{n} propStruct{n}] = Parse_Inputs(cellfun(@(x) x{n}, varargin,'uniformOutput',false));
end

%open a COM server and set a cleanup function to delete it once finished
Excel = actxserver('excel.application');
leaveOpen = true;
c = onCleanup(@() Excel_cleanUp(Excel,leaveOpen));

%loop through all of the files to write to:
for n = 1:nRequests
    
    %send to function to open the worksheet:
    if isempty(sheetName{n})
        [workBook workSheet] = Open_Worksheet(Excel,fileName{n});
    else
        [workBook workSheet] = Open_Worksheet(Excel,fileName{n},sheetName{n});
    end
    
    %get the range interface for the data to be written to:
    if isempty(topLeft{n})
        matRange = Mat_2_Excel_Range(size(Data{n}));
    else
        matRange = Mat_2_Excel_Range(size(Data{n}),topLeft{n});
    end
    Range = workSheet.Range(matRange);
    
    %write the data to Excel:
    Range.Value = Data{n};

    %send to top function to process formatting structure
    if ~isempty(propStruct{n})
        Process_Main_Routine(propStruct{n},Range)
    end
    
    %activate the top left cell so data is on screen when opened:
    workSheet.Range(regexprep(matRange,':\w*','')).Activate; %regexprep to remove the colon and bottom right cell reference
    
    %check file isn't read only, and save (remove overwrite alert temporarily)
    Excel.DisplayAlerts = false;
    if workBook.ReadOnly
        warning('%s is read only so cannot be saved. It may already be open in Excel.',fileName{n})
        
    else
        %handle different file extensions:
        [~,~,fileExt] = fileparts(fileName{n});
        
        if strcmpi(fileExt,'.xlsx')
            workBook.SaveAs(fileName{n})
            
        elseif strcmpi(fileExt,'.xls')
            %97-2003 xls format: Excel9 Enum = 56
            workBook.SaveAs(fileName{n},56)
            
        elseif strcmpi(fileExt,'.csv')
             %CSV Enum = 6
            workBook.SaveAs(fileName{n},6)
            
        else
            warning('Invalid file extension: %s will not be saved.',fileName{n})
            
        end
        workBook.Saved = 1; %in case
        workBook.Close
        
    end
    Excel.DisplayAlerts = true;
end

fprintf('\nWriting is complete. Elapsed Time: %0.2f seconds\n',toc) 
if nargout > 0
    varargout{1} = fileName;
end

function [fileName Data topLeft sheetName propStruct] = Parse_Inputs(Args)
% process the filename and optional arguments.
% the output arguments are all 5 possible input arguments. the three
% optional arguments will be empty unless they have been passed in by the
% user and are valid.

% 1: FILE NAME:
fileName = Args{1};

if ischar(fileName)
    %check if the fileName is full or relative, and whether there is a file
    %extension
    [filePath,~,fileExt] = fileparts(fileName);
    
    if isempty(filePath)
        %add current directory path
        fileName = [pwd ,'\' fileName];
    end
    
    if isempty(fileExt)
        %add .xlsx file extension
        fileName = [fileName,'.xlsx'];
    end
    
else
    error('File name must be a string')
end

% 2: DATA (no manipulation required at present)
Data = Args{2};

% OPTIONAL ARGUMENTS:
% There can be up to three optional arguments. The valid possibilities are:
% 1 optional argument:
%   topLeft
%   propStruct
% 
% 2 optional arguments:
%   topLeft , propStruct
%   topLeft , sheetName
% 
% 3 optional arguments:
%   topLeft , sheetName , propStruct

%leave all optional arguments as empty initially.
propStruct = [];
topLeft = [];
sheetName = [];

%handle various numbers of arguments.
nArgs = length(Args);
optArgs = Args(3:nArgs);
optNo = nArgs - 2;
switch optNo
    case 0
        return
        
    case 1
        %argument can be properties structure or top left cell reference
        arg1 = optArgs{1};
        if isempty(arg1) || isstruct(arg1)
            propStruct = arg1;
            
        elseif (ischar(arg1) && Excel_Ref_Check(arg1)) || (isnumeric(arg1) && numel(arg1) == 2)
            %top left can be numeric or a string
            topLeft = arg1;
        else
            error('Optional Argument 1 is not valid. It can be a structure of properties or an Excel Reference')
        end
        
    case 2
        %first argument must be the topLeft reference
        arg1 = optArgs{1};
        if isempty(arg1) || (ischar(arg1) && Excel_Ref_Check(arg1)) || (isnumeric(arg1) && numel(arg1) == 2)
            %top left can be numeric or a string
            topLeft = arg1;
        else
            error('Optional Argument 1 is not valid. It can be a structure of properties or an Excel Reference')
        end
        
        %second argument can be sheet name or properties structure
        arg2 = optArgs{2};
        if isempty(arg2) || ischar(arg2)
            sheetName = arg2;
        elseif isstruct(arg2)
            propStruct = arg2;
        else
            error('Optional Argument 2 is not valid. It can be a structure of properties or a Sheet name')
        end

        
    case 3
        %first argument must be the topLeft reference
        arg1 = optArgs{1};
        if isempty(arg1) || (ischar(arg1) && Excel_Ref_Check(arg1)) || (isnumeric(arg1) && numel(arg1) == 2)
            %top left can be numeric or a string
            topLeft = arg1;
        else
            error('Optional Argument 1 is not valid. It can be a structure of properties or an Excel cell reference')
        end
        
        %second argument muts be sheet name or properties structure
        arg2 = optArgs{2};
        if isempty(arg2) || ischar(arg2)
            sheetName = arg2;
        else
            error('Optional Argument 2 is not valid. It must be a Sheet name')
        end
        
        %third argument muts be the properties structure
        arg3 = optArgs{3};
        if  isempty(arg3) || isstruct(arg3)
            propStruct = arg3;
        else
            error('Optional Argument 3 is not valid. It must be a structure of formatting properties')
        end
        
    otherwise
        % this should have been taken care of earlier, but just in case.
        error('Incorrect number of optional arguments')
end


function Excel_cleanUp(Excel,leaveOpen)
%tidy up the COM object once the function has run: delete the object, and
%either leave Excel open or close it, depending on user preference

if leaveOpen
    Excel.Visible = 1;
else
    Excel.ActiveWorkbook.Close
    Excel.Quit
end
Excel.delete


function [workBook workSheet] = Open_Worksheet(Excel,fileName,varargin)
% return the required worksheet in Excel. This can be from an existing
% workbook, or a new one can be created. Similarly, the worksheet can be
% named, or a default used.
% arguments in:
%       Excel: handle to Excel COM server
%       fileName: name the Excel file (existing or new)
%       sheet name (optional): name of the worksheet (existing or new).
%       Otherwise the active sheet will be used (default for Excel is
%       Sheet1)
%
% arguments out:
%       workBook: handle to workbook interface
%       workSheet: handle to worksheet interface

%deal with sheets argument
existingSheet = false;
if nargin > 2
    sheetName = varargin{1};
    %check name is correct format
    if ~ischar(sheetName)
        warning('Sheet name: %s is not valid and a new sheet will be created instead')
    else
        existingSheet = true;
    end
end
    
%check if file exists
[isFile ~] = fileattrib(fileName);

%either open the existing file or set up a new workbook
if isFile
    %open the workbook
    workBook = Excel.workbooks.Open(fileName);
    workBook.Activate;
else
    %create a new workbook
    workBook = Excel.Workbooks.Add;
    
end

% set the active worksheet
if ~existingSheet
    %use default:
    workSheet = workBook.ActiveSheet;
else
    % check if the requested sheet name exists: if it is, make it active,
    % otherwise create a new sheet and name it.
    
    %loop through to find existing sheets
    nSheets = workBook.Sheets.Count; %number of sheets
    allNames = cell(nSheets,1);
    for n = 1:nSheets
        allNames{n} = workBook.Sheets.Item(n).Name;
    end
    
    %compare requested sheet name with existing sheets
    if any(strcmp(sheetName,allNames))
        
        %open existing and make it the active sheet:
        workSheet = workBook.Sheets.Item(sheetName);
        workSheet.Activate
        
    else
        %no sheet found, so create new and activate it:
        workSheet = workBook.Sheets.Add();
        workSheet.Name = sheetName;
        workSheet.Activate;
    end
end
            

function ExcelRange = Mat_2_Excel_Range(matSize,varargin)
%convert a matrix size into an alphanumeric data range (e.g. A1:C3)
%arguments:
%   1: matrix size - 2x1 array: (1) rows, (2) columns
%   2 (optional): top left of array range:
%                   can be an Excel reference (default is A1)
%                   or length 2 vector numeric reference ([3,2] == B3)

narginchk(1,2)
if nargin > 1
    %parse second argument, which is the top left of the cell range.
    topLeft = varargin{1};
    
    if ischar(topLeft)
        
        %send to some checks to see if Excel range is in the correct format
        %(function errors out in the event of incorrect format)
        Excel_Ref_Check(topLeft);
        
        %calculate offsets for use in generating bottom right Excel
        %reference
        topLeftNum = Excel_2_Numeric(topLeft);
        rowOffset = topLeftNum(1) - 1;
        colOffset = topLeftNum(2) - 1;
        
    elseif isnumeric(topLeft) %look for 2 element positive vector 
        
        if numel(topLeft) ~= 2
            error('If top left reference is numeric, it must be a 2 element vector')
        elseif any(topLeft < 1)
            error('Minimum element value of 2 element vector is 1')
        end
        
        %shift by -1 to create an offset relative to A1 cell
        rowOffset = topLeft(1) - 1;
        colOffset = topLeft(2) - 1;
        
        %convert numeric reference to Excel format:
        topLeft = Numeric_2_Excel(topLeft);
        
    end
else
    topLeft = 'A1';
    rowOffset = 0;
    colOffset = 0;
end

%convert numeric index into letters array
bottomRight = Numeric_2_Excel(matSize,[rowOffset colOffset]);

%assemble Excel_Range string:
ExcelRange = sprintf('%s:%s%0.0f',topLeft,bottomRight);


function Process_Main_Routine(propStruct,Range)
% go through the structure of options and apply the formatting. Some fields
% have functions for specifically handling those interfaces and others may
% have to be run as is (without checks or processing).
% arguments in:
%   Range: COM object which is the interface to the currently selected
%   range in Excel.
%   propStruct: structure of formatting information. The top level
%   fieldnames are interfaces to be processed, and each contains a
%   sub structure containing the fields and associated values to set the
%   fields to. Note that the BORDERS interface has an additional level,
%   because each border (left hand, bottom, inside vertical etc.) has its
%   own properties.
% 
% Example structure:
% 
% propStruct.Font.Bold = 1;
% propStruct.Font.Name = 'Lucida Sans';
% 
% propStruct.Border.EdgeLeft.LineStyle = 'DashDotDot';
% propStruct.Border.EdgeLeft.Color = RGB_2_BGR_HEX([0.4 0 0]);
% propStruct.Border.EdgeBottom.Weight = 4;
% propStruct.Border.EdgeBottom.Color = RGB_2_BGR_HEX([1 1 1]);
% 
% propStruct.Range.RowHeight = 80;
% propStruct.Range.VerticalAlignment = 'Top';
% propStruct.Range.NumberFormat = '0##.##;[Red]-0##.####';
% 
% propStruct.Interior.Color = RGB_2_BGR_Hex([0.4 0 0]);
% propStruct.Interior.TintAndShade = 0.5;
%


%look for specific fields for which there is processing
if isfield(propStruct, 'Font')
    Process_Font_Interface(propStruct.Font,Range.Font)
end

if isfield(propStruct, 'Border')
    Process_Border_Interface(propStruct.Border,Range.Borders)
end

if isfield(propStruct, 'Range')
    Process_Range_Interface(propStruct.Range,Range)
end

if isfield(propStruct, 'Interior')
    Process_Interior_Interface(propStruct.Interior,Range.Interior)
end

%find any other fields:
propNames = fieldnames(propStruct);
compStr = 'Font|Range|Interior|Border'; %logical OR of each field
otherFields = propNames(cellfun(@isempty,regexp(propNames,compStr)));

%get the valid fieldnames of the Range object
rangeFields = fieldnames(Range.get);

%loop through trying each field
for n = 1:length(otherFields)
    curField = otherFields{n};
    
    %if the interface is valid, send to the function to apply the
    %formatting
    if any(strcmp(curField,rangeFields))
        Process_Misc_Interface(propStruct.(curField),Range.(curField))
        
    else
        warning('%s is not a valid interface of the Range object',curField)
        
    end
end