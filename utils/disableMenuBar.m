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
set(hide_menu,'visible','off')


% Add an Edit tool to the standard toolbar
edit_icon(:,:,1) =   [...
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	19	34	34	14	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	2	31	35	35	27	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	1	21	24	11	23	34	35	35	35	35	33	21	11	26	17	NaN	NaN	NaN
    NaN	NaN	21	35	35	35	34	22	11	7	7	12	24	35	35	35	35	16	NaN	NaN
    NaN	NaN	25	35	35	27	5	NaN	NaN	NaN	NaN	NaN	NaN	7	30	35	35	20	NaN	NaN
    NaN	NaN	11	35	27	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	3	30	35	6	NaN	NaN
    NaN	NaN	24	34	4	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	8	35	18	NaN	NaN
    NaN	2	34	21	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	26	31	NaN	NaN
    19	31	35	11	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	16	35	29	15
    35	35	35	6	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	11	35	35	29
    34	35	35	6	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	11	35	35	29
    14	28	35	12	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	17	35	25	11
    NaN	2	34	23	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	28	30	NaN	NaN
    NaN	NaN	22	34	6	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	11	35	17	NaN	NaN
    NaN	NaN	12	35	29	3	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	5	32	35	6	NaN	NaN
    NaN	NaN	27	35	35	30	8	NaN	NaN	NaN	NaN	NaN	NaN	11	32	35	35	22	NaN	NaN
    NaN	NaN	18	35	35	35	35	25	15	10	11	16	28	35	35	35	35	13	NaN	NaN
    NaN	NaN	NaN	17	20	7	19	32	35	35	35	35	31	17	7	22	13	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	30	35	35	25	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	16	30	30	12	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    ];
edit_icon(:,:,2) = [...
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	16	30	30	13	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	2	28	31	31	24	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	1	19	21	10	21	30	31	31	31	31	29	18	10	23	15	NaN	NaN	NaN
    NaN	NaN	19	31	31	31	30	19	10	6	6	11	21	31	31	31	31	14	NaN	NaN
    NaN	NaN	22	31	31	24	4	NaN	NaN	NaN	NaN	NaN	NaN	6	27	31	31	18	NaN	NaN
    NaN	NaN	10	31	24	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	3	27	31	6	NaN	NaN
    NaN	NaN	21	30	4	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	7	31	16	NaN	NaN
    NaN	2	31	19	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	23	28	NaN	NaN
    16	27	31	9	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	14	31	26	13
    31	31	31	5	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	10	31	31	26
    30	31	31	5	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	10	31	31	26
    13	24	31	10	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	15	31	23	10
    NaN	2	30	20	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	25	27	NaN	NaN
    NaN	NaN	19	30	6	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	9	31	15	NaN	NaN
    NaN	NaN	10	31	26	3	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	5	28	31	6	NaN	NaN
    NaN	NaN	24	31	31	27	7	NaN	NaN	NaN	NaN	NaN	NaN	10	29	31	31	19	NaN	NaN
    NaN	NaN	16	31	31	31	31	23	13	9	10	14	24	31	31	31	31	12	NaN	NaN
    NaN	NaN	NaN	15	18	6	17	29	31	31	31	31	27	15	6	20	12	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	27	31	31	22	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	14	27	27	10	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    ];
edit_icon(:,:,3) = [...
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	17	31	31	13	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	2	28	32	32	25	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	1	19	22	10	21	31	32	32	32	32	30	19	10	24	15	NaN	NaN	NaN
    NaN	NaN	19	32	32	32	31	20	11	6	7	12	22	32	32	32	32	15	NaN	NaN
    NaN	NaN	23	32	32	25	4	NaN	NaN	NaN	NaN	NaN	NaN	6	27	32	32	18	NaN	NaN
    NaN	NaN	10	32	25	1	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	3	28	32	6	NaN	NaN
    NaN	NaN	22	31	4	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	8	32	17	NaN	NaN
    NaN	2	32	19	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	24	29	NaN	NaN
    17	28	32	10	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	15	32	27	14
    32	32	32	5	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	10	32	32	27
    31	32	32	6	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	11	32	32	27
    13	25	32	11	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	15	32	23	11
    NaN	2	31	21	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	26	28	NaN	NaN
    NaN	NaN	20	31	6	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	10	32	15	NaN	NaN
    NaN	NaN	11	32	27	3	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	5	29	32	6	NaN	NaN
    NaN	NaN	25	32	32	27	7	NaN	NaN	NaN	NaN	NaN	NaN	10	29	32	32	20	NaN	NaN
    NaN	NaN	16	32	32	32	32	23	14	9	10	15	25	32	32	32	32	12	NaN	NaN
    NaN	NaN	NaN	16	18	6	18	29	32	32	32	32	28	16	6	21	12	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	28	32	32	23	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN	15	28	27	11	NaN	NaN	NaN	NaN	NaN	NaN	NaN	NaN
    ];
edit_icon = edit_icon./255;




% Check if the edit tool is already there
hToolbar = findall(hf,'tag','FigureToolBar');
if isempty(hToolbar)
    set(hf,'toolbar','figure' )
    hToolbar = findall(hf,'tag','FigureToolBar');
end
hEdit = findobj(hToolbar,'tooltip','Open Plot Edit Dialog');
if ~isempty(hEdit) && ishandle(hEdit)
    % Tool already on figure
else
    % Add the tool
    hEdit = uipushtool(hToolbar,'cdata',edit_icon,...
        'tooltip','Open Plot Edit Dialog');
    set(hEdit,'ClickedCallback',{@editFigureDialog,hf,gcbf})
end