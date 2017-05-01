function Process_Misc_Interface(s,Interface)
% apply options to an interface in Excel. This function is for interfaces
% apart from Font,Borders, Interior or Range, and checks aren't performed
% on these fields.
% arguments in: s - structure of formatting information
%               Interface: handle to Interface (child of Range)
%
% The function is called by the PROCESS_MAIN_ROUTINE function.

sFields = fieldnames(s);
nFields = length(sFields);

for n = 1:nFields
    curField = sFields{n};
    try
        Interface.(curField) = s.(curField);
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
