function varargout = Process_Font_Interface(s,Font)
% ensure the inputs for the font interface are vaild. The font interface
% contains properties such as font name, size, bold/ italic/ underline and
% colour.
% arguments in:
%               s: structure of properties
%               Font: handle to Excel font interface
% arguments out (optional):
%               s: structure of properties (modified to remove potentially
%               invalid fields)
%
% The function is called by the PROCESS_MAIN_ROUTINE function.

narginchk(2,2)
nargoutchk(0,1)

%check all fields are valid:
s = Valid_Fields(s,fieldnames(get(Font)));

%switch underline string with enum:
s = Underline_Enum(s);

%check font name:
s = Font_Name_Check(s);

%check colour string:
s = Colour_Check(s);

%apply formatting to spreadsheet:
Apply_Fonts(s,Font)


if nargout
    varargout{1} = s;
end

function sNew = Valid_Fields(s,fontFields)
%check that all the fields in the font structure are valid

sFields = fieldnames(s);
nFields = length(sFields);

%loop through, comparing each field in s with all of the font interface
%fields. Remove invalid fields

rmChk = false(nFields,1);
for n = 1:nFields
    rmChk(n) = ~any(strcmp(sFields{n},fontFields));
    if rmChk(n)
        warning('%s is not a valid field for the font interface, and will be ignored.',sFields{n})
        fprintf('\n')
    end
end

%remove any invalid fields:
sNew = rmfield(s,sFields(rmChk));

function s = Underline_Enum(s)
% transpose Underline string into a valid number for Excel; see
% unerlineEnum cell array below.

%enumeration for underline styles
underlineEnum = {'None',-4142;
    'Single',2;
    'Double',-4119;
    'SingleAccounting',4;
    'DoubleAccounting',5};

%check if there is an Underline field to the structure, and if so check the
%string is valid.
if isfield(s,'Underline')
    
    if ischar(s.Underline)
    %remove the Enum preface to the useful bit of the string:
    s.Underline = regexprep(s.Underline,'xlUnderlineStyle','');
    
    %check if the string is found in the table:
    underlineChk = strcmp(s.Underline,underlineEnum(:,1));
    
    elseif isnumeric(s.Underline)
        %check if the number is found in the table:
        underlineChk = s.Underline == [underlineEnum{:,2}];
        
    else
        %wrong format:
        warning('Underline field must be numeric or a string. Field will be removed')
        s = rmfield(s,'Underline');
        return
    end
        

    if ~any(underlineChk)
        %no valid string found, warn user and delete Underline field.
        warning([sprintf('Underline format is not valid. Options are:\n'),...
            sprintf('%s\n',underlineEnum{:,1})])
        
        s = rmfield(s,'Underline');
    else
        %replace string with a number
        s.Underline = underlineEnum{underlineChk,2};
    end
end


function s = Font_Name_Check(s)
%if there is a font field to the font properties structure, check the name
%is valid

if isfield(s,'Name') && ~any(strcmp(s.Name,listfonts))
    warning('%s is not a valid font name, name field will be ignored.',s.Name)
    s = rmfield(s,'Name');
end


function s = Colour_Check(s)
%check that font colour is the correct format (BGR string)

if isfield(s,'Name') && (~isnumeric(s.Color) || length(s.Color) ~= 1)
    
    warning('Color field must be a single number: use RGB_2_BGR_Hex function.\nField will be ignored')
    s = rmfield(s,'Color');
end


function Apply_Fonts(s,Font)
% apply font formatting to Excel
% arguments in: s - structure of formatting information
%               Font: handle to font interface

sFields = fieldnames(s);
nFields = length(sFields);

for n = 1:nFields
    curField = sFields{n};
    
    try
        Font.(curField) = s.(curField);
    catch err
        
        %format value so it can be displayed if it's a number
        Val = s.(curField);
        if isnumeric(Val)
            Val = num2str(Val);
        end
        
        warning('%s field with value:\n\t\t%s\nhas not been applied, see error below:\n\n%s',curField,Val,err.message)
        fprintf('\n')
    end
end



