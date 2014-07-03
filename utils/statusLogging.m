function statusLogging(log_listbox_handle, log_text)
% This function pushes the text in log_text to the log window specified by
% its handle log_listbox_handle. This function appends the log window text.
% 
% The input log_text should be formated as a cell array, containing each
% line of text as a row in the array. Max length of a line of text is 63
% characters.
%
% Last modified: 2013/03/12 (FLE)

% Get the current log window contents
log_contents = get(log_listbox_handle,'string');

% Append new log text
l = size(log_text,1)-1;
log_contents = vertcat(log_contents,log_text);

% Push updated log to the log window
set(log_listbox_handle,'string',log_contents)

% Make the last line the "active" line. This is to aid readability
set(log_listbox_handle,'value',length(log_contents))

% [EOF] statusLogging


