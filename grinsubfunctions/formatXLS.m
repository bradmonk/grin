function [] = formatXLS
%% formatXLS


%% GET ALL XLS FILES FROM DIRECTORY WITH SELECTED PREFIX

filedir = uigetdir();
xlsFiles = dir([filedir,'/gc33*.xls*']);
xlsFileNames = {xlsFiles(:).name}';
xlsFullPaths = strcat(repmat([filedir '/'],length(xlsFileNames),1), xlsFileNames);



%% GET ALL DATA FROM THOSE XLS FILES AND STORE AS STRUCTURAL ARRAY

for nn = 1:numel(xlsFullPaths)

    [xlsN,xlsT,xlsR] = xlsread(xlsFullPaths{nn});
    
    xlsdata.File{nn} = xlsFileNames{nn};
    xlsdata.Num{nn}  = xlsN;
    xlsdata.Txt{nn}  = xlsT;
    xlsdata.Raw{nn}  = xlsR;
    

end


%% SAVE STRUCT AS .MAT FILE

save('xlsdata.mat','xlsdata')
load('xlsdata.mat')

%%

% helpdlg('Choose 10 points from the figure',...
%         'Point Selection');

% uiwait(msgbox('Operation Completed','Success','modal'));


% uigetpref allows you to have a help box that displays only one time if
% the user checkmarks "never display again".
% pref_value = uigetpref(group,pref,title,question,pref_choices)


xlsdata.File{1}








end