function varargout = Process_Border_Interface(s,Border)
% ensure the inputs for the font interface are vaild. Note there is more
% depth to the border interface: border.Item('BORDER LOCATION') contains an
% interface specifically for the border.
% arguments in:
%               s: structure of properties
%               Font: handle to Excel font interface
% arguments out (optional):
%               s: structure of properties (modified to remove potentially
%               invalid fields)
%               s has two layers: the first specificies the border position
%               (see BORDER_ENUM function)
%               the second layer contains the options for that border
%               (colour, line style, line weight)
%
% The function is called by the PROCESS_MAIN_ROUTINE function.

narginchk(2,2)
nargoutchk(0,1)

% process border type data
s = Border_Name_Process(s);

%check all fields are valid, using Item 5 (diagonal down border) as a reference:
s = Valid_Border_Fields(s,fieldnames(get(Border.Item(5))));

%format the line style fields:
s = LineStyle_Enum(s);

%check any line weight options are in range:
s = Line_Weight_Check(s);

%check colour values:
s = Colour_Check(s);

%check tint and shade values
s = Tint_Shade_Check(s);

%apply formatting:
Apply_Borders(s,Border)

if nargout
    varargout{1} = s;
end


function s = Valid_Border_Fields(s,borderFields)
%check that all the fields in the font structure are valid

sFields = fieldnames(s);

%loop through, comparing each field in s with all of the font interface
%fields. Remove invalid fields

for n = 1:length(sFields)
    
    subFields = fieldnames(s.(sFields{n}));
    nFields = length(subFields);
    rmChk = false(nFields,1);
    for m = 1:nFields
        %check that every field in the structure matches one in the border
        %interface
        rmChk(m) = ~any(strcmp(subFields{m},borderFields));
        if rmChk(m)
            warning('%s is not a valid field for the Border interface, and will be ignored.',subFields{m})
            fprintf('\n')
        end
    end
    
    %remove any invalid borders:
    s.(sFields{n}) = rmfield(s.(sFields{n}),subFields(rmChk));
end


function s = Border_Name_Process(s)
%check the border selection string is valid and replace it with a number
%for Excel

%Enum for Excel borders (currently the numbers aren't used due to the
%limitations of structure field names). 
% 13, 14 and 15 aren't part of the Excel Enum and have been added to make
% it easier to select whole border sets.
BordersEnum = {'DiagonalDown' , 5;
    'DiagonalUp' , 6;
    'EdgeLeft' , 7;
    'EdgeTop' , 8;
    'EdgeBottom' , 9;
    'EdgeRight' , 10;
    'InsideVertical' , 11;
    'InsideHorizontal' , 12;
    'OutsideAll' , 13;
    'InsideAll' , 14;
    'All' , 15};

sFields = fieldnames(s);

for n = 1:length(sFields);
    
    %flag up 'xl' from start of border name, if it exists:
    xlFlag = any(regexp(sFields{n},'xl'));
    
    %check if current field is a valid border name
    if xlFlag
        f = strcmp(sFields{n}(3:end),BordersEnum(:,1)); %ignore 'xl'
    else
        f = strcmp(sFields{n},BordersEnum(:,1));
    end
    nBorder = [BordersEnum{f,2}];
    
    %empty array isn't a valid option for SWITCH, so replace it with NaN;
    if isempty(nBorder)
        nBorder = NaN;
    end
    
    switch nBorder
        
        case num2cell(5:12)
            %the standard Excel line styles
            
            %replace current field with new one which has 'xl' prefix.
            if ~xlFlag
                %precede the text with 'xl' as this is the format required by the
                %COM interface
                s.(sprintf('xl%s',sFields{n})) = s.(sFields{n});
                %delete old field:
                s = rmfield(s,sFields{n});
            end
            
        case 13
            %OutsideAll: create all 4 edge borders with the same formatting
            s.xlEdgeLeft = s.(sFields{n});
            s.xlEdgeRight = s.(sFields{n});
            s.xlEdgeTop = s.(sFields{n});
            s.xlEdgeBottom = s.(sFields{n});
            
            %delete old field:
            s = rmfield(s,sFields{n});
            
        case 14
            %InsideAll: create two inside line borders with the same
            %formatting
            s.xlInsideVertical = s.(sFields{n});
            s.xlInsideHorizontal = s.(sFields{n});
            
            %delete old field:
            s = rmfield(s,sFields{n});
            
        case 15
            %All: create outer and inner borders (don't include diagonal
            %because they are stupid)
            s.xlEdgeLeft = s.(sFields{n});
            s.xlEdgeRight = s.(sFields{n});
            s.xlEdgeTop = s.(sFields{n});
            s.xlEdgeBottom = s.(sFields{n});
            s.xlInsideVertical = s.(sFields{n});
            s.xlInsideHorizontal = s.(sFields{n});
            
            %delete old field:
            s = rmfield(s,sFields{n});
            
        otherwise
            %delete field:
            s = rmfield(s,sFields{n});
            warning('%s is not a valid field for the Border interface, and will be ignored.',sFields{n})
            fprintf('\n')
            
    end
  
end
    

function s = LineStyle_Enum(s)
%check the line style selection string is valid and replace it with a
%number for Excel

lineStyles = {'None' , -4142;
    'Continuous' , 1;
    'Dash' , -4115;
    'DashDot' , 4;
    'DashDotDot' , 5;
    'Dot' , -4118;
    'Double' , -4119;
    'SlantDashDot' , 13};

borders = fieldnames(s);

for n = 1:length(borders);
    %get border sub structure, and check for lineweight
    subStruct = s.(borders{n});
    
    if isfield(subStruct,'LineStyle')
        
        % argument can be string or number:
        if ischar(subStruct.LineStyle)
            f = strcmpi(subStruct.LineStyle,lineStyles(:,1));
            
        elseif isnumeric(subStruct.LineStyle)
            f = subStruct.LineStyle == [lineStyles{:,2}];
        else
            warning('LineStyle field must be numeric or a string. Field will be removed')
            s.(borders{n}) = rmfield(s.(borders{n}),'LineStyle');
            
        end
        
        if any(f)
            %Replace the string with the corresponding number:
            s.(borders{n}).LineStyle = lineStyles{f,2};
            
        else
            %remove the field
            warning('%s of the %s structure, is not a valid linestyle, and will be ignored.',subStruct.LineStyle, borders{n})
            fprintf('\n')
            s.(borders{n}) = rmfield(s.(borders{n}),'LineStyle');
            
        end
    end
end


function s = Line_Weight_Check(s)
%check the line weight field is in range (must be between 1 and 4
%inclusive)

borders = fieldnames(s);
%loop through the total number of borders.
for n = 1:length(borders);
    
    %for each border, check line weight field exists
    if isfield(s.(borders{n}),'Weight')
        
        %check value is  a number
        if ~isnumeric(s.(borders{n}).Weight)
            
            %remove the field
            warning('%s Border weight value must be numeric. Field will be ignored',borders{n})
            fprintf('\n')
            s.(borders{n}) = rmfield(s.(borders{n}),'Weight');
            
            %check number is valid
        elseif s.(borders{n}).Weight < 1 || s.(borders{n}).Weight > 4
            
            %remove the field
            warning('%s Border weight must be between 1 and 4. Field will be ignored',borders{n})
            fprintf('\n')
            s.(borders{n}) = rmfield(s.(borders{n}),'Weight');
            
        end
        
    end
    
end

function s = Colour_Check(s)
%check that font colour is the correct format (BGR string)

borders = fieldnames(s);

%loop through the total number of borders.
for n = 1:length(borders);
    borderStruct = s.(borders{n});
    %for each border, check line weight field exists
    if isfield(borderStruct,'Color') && (~isnumeric(borderStruct.Color) || length(borderStruct.Color) ~= 1)
        
        %remove the field
        warning('Color field must be a single number: use RGB_2_BGR_Hex function.\nField will be ignored')
        fprintf('\n')
        s.(borders{n}) = rmfield(s.(borders{n}),'Color');
        
    end
    
end


function s = Tint_Shade_Check(s)
%check that Tint and Shade property is between -1 and 1

borders = fieldnames(s);

%loop through the total number of borders.
for n = 1:length(borders);
    borderStruct = s.(borders{n});
    %for each border, check line weight field exists
    
    if isfield(borderStruct,'TintAndShade')
        
        if ~isnumeric(borderStruct.TintAndShade) || length(borderStruct.TintAndShade) ~= 1 || borderStruct.TintAndShade < -1 || borderStruct.TintAndShade > 1
            
            warning('TintAndShade must be a numeric value between -1 and 1; field will be ignored')
            s.(borders{n}) = rmfield(s.(borders{n}),'TintAndShade');
            
        end
    end
    
end

function Apply_Borders(s,Border)
% apply border formatting to Excel
% arguments in: s - structure of formatting information
%               Border: handle to border interface

borders = fieldnames(s);
%loop through each border (left edge, diagonal up etc)
for n = 1:length(borders);
    
    %get the structure for the current border
    curStruct = s.(borders{n});
    subFields = fieldnames(curStruct);
    
    for m = 1:length(subFields)
        curField = subFields{m};
        try
            Border.Item(borders{n}).(curField) = curStruct.(curField);
        catch err
            %format value so it can be displayed if it's a number
            Val = curStruct.(curField);
            if isnumeric(Val)
                Val = num2str(Val);
            end
            warning('%s field with value:\n\t\t%s\nhas not been applied, see error below:\n\n%s',curField,Val,err.message)
            fprintf('\n')
        end
    end
end