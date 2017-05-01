function varargout = Process_Interior_Interface(s,Interior)
% ensure the inputs for the interior interface are vaild. The interior
% interface contains properties for the cell itself, such as background
% colour.
% arguments in:
%               s: structure of properties
%               Interior: handle to Excel font interface
% arguments out (optional):
%               s: structure of properties (modified to remove potentially
%               invalid fields)
%
% The function is called by the PROCESS_MAIN_ROUTINE function.

narginchk(2,2)
nargoutchk(0,1)

%check all fields are valid:
s = Valid_Fields(s,fieldnames(get(Interior)));

%switch underline string with enum:
s = Pattern_Enum(s);

%check colour strings:
s = Colour_Check(s,'Color');
s = Colour_Check(s,'PatternColor');

%check tint and shade value:
s = Tint_Shade_Check(s);

%apply formatting:
Apply_Interior(s,Interior);

if nargout
    varargout{1} = s;
end

function s = Valid_Fields(s,interiorFields)
%check that all the fields in the font structure are valid (i.e. are one of
%the fields in the interface)

sFields = fieldnames(s);
nFields = length(sFields);

%loop through, comparing each field in s with all of the font interface
%fields. Remove invalid fields

rmChk = false(nFields,1);
for n = 1:nFields
    rmChk(n) = ~any(strcmp(sFields{n},interiorFields));
    if rmChk(n)
        warning('%s is not a valid field for the font interface, and will be ignored.',sFields{n})
        fprintf('\n')
    end
end

%remove any invalid fields:
s = rmfield(s,sFields(rmChk));

function s = Pattern_Enum(s)
% transpose Pattern string into a valid number for Excel; see
% patternEnum cell array below.

%enumeration for pattern types
patternEnum = {'Automatic' , -4105;
'Checker' , 9;
'CrissCross' , 16;
'Down' , -4121;
'Gray16' , 17;
'Gray25' , -4124;
'Gray50' , -4125;
'Gray75' , -4126;
'Gray8' , 18;
'Grid' , 15;
'Horizontal' , -4128;
'LightDown' , 13;
'LightHorizontal' , 11;
'LightUp' , 14;
'LightVertical' , 12;
'None' , -4142;
'SemiGray75' , 10;
'Solid' , 1;
'Up' , -4162;
'Vertical' , -4166};

%check if there is an pattern field to the structure, and if so check the
%string is valid.
if isfield(s,'Pattern')
    
    if ischar(s.Pattern)
        
        %remove the enum preface text, if it exists:
        s.Pattern = regexprep(s.Pattern,'xlPattern','');
        
        %compare the string with the Enum strings
        patternChk = strcmp(s.Pattern,patternEnum(:,1));
        
    elseif isnumeric(s.Pattern)
        %compare the number with the Enum values
        patternChk = s.Pattern == [patternEnum{:,2}];
        
    else
        warning('Pattern field must be numeric or a string. Field will be removed')
        s = rmfield(s,'Pattern');
        
    end
    
    if ~any(patternChk)
        %no valid string found, warn user and delete Underline field.
        warning([sprintf('Pattern format is not valid. Options are:\n'),...
            sprintf('%s\n',patternEnum{:,1})])
        
        s = rmfield(s,'Pattern');
    else
        %replace string with a number
        s.Pattern = patternEnum{patternChk,2};
    end
end


function s = Colour_Check(s,colourField)
%check that cell or pattern colour is the correct format (BGR string)
% colourField is a field name, either 'Color' or 'PatternColor'.

if isfield(s,colourField) && (~isnumeric(s.(colourField)) || length(s.(colourField)) ~= 1) 
    
    warning('%s must be a single number: use RGB_2_BGR_Hex function.\nField will be ignored',colourField)
    s = rmfield(s,colourField);
end



function s = Tint_Shade_Check(s)
%check that Tint and Shade property is between -1 and 1

if isfield(s,'TintAndShade')
    
    if ~isnumeric(s.TintAndShade) || length(s.TintAndShade) ~= 1 || s.TintAndShade < -1 || s.TintAndShade > 1
    
    warning('TintAndShade must be a numeric value between -1 and 1; field will be ignored')
    s = rmfield(s,'TintAndShade');
    
    end
end

function Apply_Interior(s,Interior)
% apply Interior formatting to Excel
% arguments in: s - structure of formatting information
%               Interior: handle to interior interface

sFields = fieldnames(s);
nFields = length(sFields);

for n = 1:nFields
    curField = sFields{n};
    try
        Interior.(curField) = s.(curField);
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



