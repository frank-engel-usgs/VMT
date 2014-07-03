function disableMenuBar(hf)
% Customizes the figure toolbars. Input argument is the figure handle (hf)
%
% FLE: disabled for now. Need to determine which group includes the "Edit
% Plot" tool and keep this one on. Cannot test this easily, as the figure
% toolbar groups are only testable while compiled, and I have to compile
% through another person for now.

all_tools = findall(hf); % finds hidden tools
hide_tools = findall(all_tools,'ToolTipString','Show Plot Tools and Dock Figure'); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Hide Plot Tools')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Open File')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','New Figure')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Insert Legend')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Insert Colorbar')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Data Cursor')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Rotate 3D')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Save')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Brush/Select Data')); 
hide_tools = vertcat(hide_tools,findall(all_tools,'ToolTipString','Link Plot')); 
% set(hide_tools,'Visible','Off')

hide_menu = findall(all_tools,'tag','figMenuDesktop');
hide_menu = vertcat(hide_menu,findall(all_tools,'tag','figMenuWindow'));
hide_menu = vertcat(hide_menu,findall(all_tools,'tag','figMenuTools'));
hide_menu = vertcat(hide_menu,findall(all_tools,'tag','figMenuInsert'));
% set(hide_menu,'visible','off')