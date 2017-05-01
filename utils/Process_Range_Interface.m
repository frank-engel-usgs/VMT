function varargout = Process_Range_Interface(s,Range)
% ensure the inputs for the range interface are vaild. The Range interface
% allows for the specification of things such as vertical/ horizontal text 
% alignment,column width/ row height and number format.
% arguments in:
%               s: structure of properties
%               Font: handle to Excel range interface
% arguments out (optional):
%               s: structure of properties (modified to remove potentially
%               invalid fields)
%
% The function is called by the PROCESS_STRUCTURE function.

narginchk(2,2)
nargoutchk(0,1)


%check all fields are valid:
s = Valid_Fields(s,fieldnames(get(Range)));

%Alignment formatting:
s = Vertical_Align(s);
s = Horizontal_Align(s);

%check row height/ column width arguments:
s = Cell_Size_Check(s,'RowHeight');
s = Cell_Size_Check(s,'ColumnWidth');

%apply formatting:
Apply_Range(s,Range)

if nargout
    varargout{1} = s;
end

function s = Valid_Fields(s,rangeFields)
%check that all the fields in the font structure are valid

sFields = fieldnames(s);
nFields = length(sFields);

%loop through, comparing each field in s with all of the range interface
%fields. Remove invalid fields

rmChk = false(nFields,1);
for n = 1:nFields
    rmChk(n) = ~any(strcmp(sFields{n},rangeFields));
    if rmChk(n)
        warning('%s is not a valid field for the Range interface, and will be ignored.',sFields{n})
        fprintf('\n')
    end
end

%remove any invalid fields:
s = rmfield(s,sFields(rmChk));


function s = Vertical_Align(s)
% apply the vertical alignment enum to replace the format strings with
% numbers

vertEnum = {'Bottom' , -4107;
'Center' , -4108;
'Distributed' , -4117;
'Justify' , -4130;
'Top' , -4160};


if isfield(s,'VerticalAlignment')
    
    vertChk = strcmp(s.VerticalAlignment,vertEnum(:,1));
    
    if ~any(vertChk)
        %no valid string found, warn user and delete the field.
        warning([sprintf('Vertical Alignment string is not valid. Options are:\n'),...
            sprintf('%s\n',vertEnum{:,1})])
        s = rmfield(s,'VerticalAlignment');
    else
        %replace string with a number
        s.VerticalAlignment = vertEnum{vertChk,2};
    end
end
    

function s = Horizontal_Align(s)
% apply the horizontal alignment enum to replace the format strings with
% numbers

horzEnum= {'Center' , -4108;
'CenterAcrossSelection' , 7;
'Distributed' , -4117;
'Fill' , 5;
'General' , 1;
'Justify' , -4130;
'Left' , -4131;
'Right' , -4152};


if isfield(s,'HorizontalAlignment')
    
    vertChk = strcmp(s.HorizontalAlignment,horzEnum(:,1));
    
    if ~any(vertChk)
        %no valid string found, warn user and delete the field.
        warning([sprintf('Horizontal Alignment string is not valid. Options are:\n'),...
            sprintf('%s\n',horzEnum{:,1})])
        
        s = rmfield(s,'HorizontalAlignment');
    else
        %replace string with a number
        s.HorizontalAlignment = horzEnum{vertChk,2};
    end
end


function s = Cell_Size_Check(s,cellField)
%ensure the argument for row heigh/ column width is valid
%arguments: s: structure of range properties
%           cellField: string to choose 'RowHeight' or 'ColumnWidth'

if isfield(s,cellField)
    val = s.(cellField);
    chk = false; %whether field is valid
    if ~isnumeric(val)
        
        warning('%s must be numeric; field will be ignored.',cellField)
        fprintf('\n')
        
    elseif length(val) ~= 1
        
        warning('%s must be a single number; field will be ignored.',cellField)
        fprintf('\n')
        
    elseif val < 1 %|| round(val) ~= val
        
        warning('%s must be a positive val.',cellField)
        fprintf('\n')
    
    else chk = true;
        
    end
    
    %delete the field if the criteria aren't matched:
    if ~chk
        s = rmfield(s,cellField);
    end
end


function Apply_Range(s,Range)
% apply range formatting to Excel
% arguments in: s - structure of formatting information
%               Range: handle to range interface

sFields = fieldnames(s);
nFields = length(sFields);

for n = 1:nFields
    curField = sFields{n};
    try
        Range.(curField) = s.(curField);
    catch err
        warning('%s field with value:\n\t\t%s\nhas not been applied, see error below:\n\n%s',curField,char(s.(curField)),err.message)
        fprintf('\n')
    end
end
