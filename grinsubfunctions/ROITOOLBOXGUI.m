function [ROIguih] = ROITOOLBOXGUI(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK)
%% ROIfinderGUI.m
% function [] = ROIfinderGUI(IMG, GRINstruct, XLSdata, LICK, IMGSraw, varargin)

clearvars -except IMG GRINstruct GRINtable XLSdata IMGraw IMGSraw muIMGS LICK

if ~exist('IMG','var')

    clc; close all; clear all; clear java;
    
    disp('Contents of workspace before loading file:'); whos

    grinmat = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/gc33_031916g.mat';

    disp('File contains the following vars:'); whos('-file',grinmat);

    fprintf('Loading .mat file from... \n % s \n\n', grinmat); 
    
    % global IMG GRINstruct XLSdata GRINtable LICK IMGraw
   
    load(grinmat, 'IMG', 'GRINstruct', 'XLSdata', 'GRINtable', 'LICK', 'IMGraw')
    
    IMG = double(IMG);
    
    % IMG = IMG./10000;
    % max(max(max(max(IMG))))
    % min(min(min(min(IMG))))
else
    
    % global IMG GRINstruct XLSdata GRINtable LICK IMGraw
    
end

disp('Contents of workspace after loading file:'); whos


tv1 = [];
tv2 = [];
tv3 = [];
tv4 = [];
tv5 = [];
tv6 = [];
tv7 = [];
tv8 = [];
tv9 = [];

%----------------------------------------------------
%%     ESTABLISH GLOBALS
%----------------------------------------------------
clc
global GhaxGRIN GimgsliderYAH GimgsliderYBH GimgsliderXAH GimgsliderXBH
global slideValYA slideValYB slideValXA slideValXB slideValIM
global GupdateGraphH Gcheckbox1H Gcheckbox2H Gcheckbox3H Gcheckbox4H
global Gcheckbox5H Gcheckbox6H Gcheckbox7H
global CSUSvals IMGt ROIs LICKs LhaxGRIN 
global IM IMsz colorord haxROI IMpanel phIM
global tabgp btabs dtabs itabs gtabs
global ROIROI ROIfac ROIcof ROIf ROIc dfDiff rawDiff ROIfacDat ROIcofDat ROIDATA
global ROIgroups IMGSdf ROIinfo ROIMASK ROIMASKNEW
global ROIDATANEW ROIROINEW ROIfacDatNEW ROIcofDatNEW ROIinfoNEW
global BlurVal zcrit zout smoothimgnumH zcritnumH zoutnumH
global quantMinH minROIszH quantMin minROIsz
global Sframe Eframe frameBG frameSE
global memos memoboxH haxMINI racerline

ROIDATA = {};
ROIinfo.file = GRINstruct.file(1:end-4);

slideValYA = 0.15;
slideValYB = -0.15;
slideValXA = 100;
slideValXB = 0;
slideValIM = size(IMG,1);
CSUSvals = unique(GRINstruct.csus);
ROIfac = '1';
ROIcof = '1';
BlurVal = .14;
zcrit = 5;
zout = 9;
quantMin = .90;
minROIsz = 15;

ROIfac = CSUSvals(1);
ROIcof = CSUSvals(1);

% GET FRAME FOR CS_ONSET CS_MIDWAY US_ONSET US_MIDWAY
Fcson   = XLSdata.CSonsetFrame;
Fcsmid  = Fcson + round(XLSdata.CS_lengthFrames/2);
Fcsoff  = XLSdata.CSoffsetFrame;
Fusmid  = Fcsoff + round((XLSdata.framesPerTrial - Fcsoff)/2);
Fusend  = XLSdata.framesPerTrial;

Sframe = Fcsoff;
Eframe = Fusend;





% MATLAB Default Color Order
colorord = [0.0000    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];

IM = squeeze(IMGSraw(:,:,:,1));
IMsz = size(IM);

%----------------------------------------------------
%%     CREATE GRINplotGUI FIGURE WINDOW
%----------------------------------------------------
% close(graphguih)
% mainguih.CurrentCharacter = '+';
ROIguih = figure('Units', 'normalized','Position', [.02 .1 .85 .80], 'BusyAction',...
    'cancel', 'Name', ['ROI MODULE - FILE: ' ROIinfo.file(1:end-2)], 'Tag', 'ROI MODULE','MenuBar', 'none'); 


%----------------------------------------------------
%%     LEFT PANE MAIN PLOT WINDOW
%----------------------------------------------------

% LhaxGRIN = axes('Parent', graphguih, 'NextPlot', 'replacechildren',...
%     'Position', [0.05 0.08 0.55 0.85],'Color','none','XTick',[],'YTick',[],...
%     'XColor','none','YColor','none'); hold on;

GhaxGRIN = axes('Parent', ROIguih, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.08 0.55 0.65],...
    'XLimMode', 'manual','YLimMode', 'manual','Color','none');
    GhaxGRIN.YLim = [-.15 .15];
    GhaxGRIN.XLim = [1 100];


GimgsliderYAH = uicontrol('Parent', ROIguih, 'Units', 'normalized','Style','slider',...
	'Max',1,'Min',0,'Value',.15,'SliderStep',[0.01 0.10],...
	'Position', [-.01 0.42 0.03 0.25], 'Callback', @GimgsliderYA);

GimgsliderYBH = uicontrol('Parent', ROIguih, 'Units', 'normalized','Style','slider',...
	'Max',0,'Min',-1,'Value',-.15,'SliderStep',[0.01 0.10],...
	'Position', [-.01 0.04 0.03 0.25], 'Callback', @GimgsliderYB);

GimgsliderXAH = uicontrol('Parent', ROIguih, 'Units', 'normalized','Style','slider',...
	'Max',200,'Min',0,'Value',100,'SliderStep',[0.01 0.10],...
	'Position', [0.40 0.01 0.20 0.03], 'Callback', @GimgsliderXA);

GimgsliderXBH = uicontrol('Parent', ROIguih, 'Units', 'normalized','Style','slider',...
	'Max',200,'Min',0,'Value',1,'SliderStep',[0.01 0.10],...
	'Position', [0.05 0.01 0.20 0.03], 'Callback', @GimgsliderXB);



%----------------------------------------------------
%     DISPLAY LINES ON GRAPH CHECKBOXES
%----------------------------------------------------



DisplaypanelH = uipanel('Parent', ROIguih,'Title','Display on Line Graph','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.01 0.75 0.13 0.24]); % 'Visible', 'Off',

chva = 1;

if size(CSUSvals,1) > 0
Gcheckbox1H = uicontrol('Parent', DisplaypanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.86 .90 .10] ,'String',CSUSvals(1), 'Value',1,'Callback',{@plot_callback,1});
end
if size(CSUSvals,1) > 1
Gcheckbox2H = uicontrol('Parent', DisplaypanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.72 .90 .10] ,'String',CSUSvals(2), 'Value',chva,'Callback',{@plot_callback,2});
end
if size(CSUSvals,1) > 2
Gcheckbox3H = uicontrol('Parent', DisplaypanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.58 .90 .10] ,'String',CSUSvals(3), 'Value',chva,'Callback',{@plot_callback,3});
end
if size(CSUSvals,1) > 3
Gcheckbox4H = uicontrol('Parent', DisplaypanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.44 .90 .10] ,'String',CSUSvals(4), 'Value',chva,'Callback',{@plot_callback,4});
end
if size(CSUSvals,1) > 4 
Gcheckbox5H = uicontrol('Parent', DisplaypanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.30 .90 .10] ,'String',CSUSvals(5), 'Value',chva,'Callback',{@plot_callback,5});
end
if size(CSUSvals,1) > 5
Gcheckbox6H = uicontrol('Parent', DisplaypanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.16 .90 .10] ,'String',CSUSvals(6), 'Value',chva,'Callback',{@plot_callback,6});
end
if size(CSUSvals,1) > 6
Gcheckbox7H = uicontrol('Parent', DisplaypanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.02 .90 .10] ,'String',CSUSvals(7), 'Value',chva,'Callback',{@plot_callback,7});
end



%----------------------------------------------------
%           MEMO CONSOLE GUI WINDOW
%----------------------------------------------------

memopanelH = uipanel('Parent', ROIguih,'Title','Memo Log ','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.15 0.75 0.45 0.24]); % 'Visible', 'Off',


memos = {' ',' ',' ', ' ',' ',' ',' ',' ', ...
         'Welcome to ROI Finder', 'GUI is loading...'};

memoboxH = uicontrol('Parent',memopanelH,'Style','listbox','Units','normalized',...
        'Max',10,'Min',0,'Value',10,'FontSize', 13,'FontName', 'FixedWidth',...
        'String',memos,'FontWeight', 'bold',...
        'Position',[.02 .02 .96 .96]);  
    
% memolog('Ready!')



%----------------------------------------------------
%%     RIGHT PANE FIGURE PANELS
%----------------------------------------------------

tabgp = uitabgroup(ROIguih,'Position',[0.61 0.02 0.38 0.95]);
btabs = uitab(tabgp,'Title','Options');
dtabs = uitab(tabgp,'Title','Data');
itabs = uitab(tabgp,'Title','ROI');
gtabs = uitab(tabgp,'Title','Image');







%----------------------------------------------------
%%     IMAGE TAB
%----------------------------------------------------

IMpanel = uipanel('Parent', gtabs,'Title','Image Previews','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],'Position', [0.01 0.01 0.98 0.98]);


haxROI = axes('Parent', IMpanel, ...
    'Position', [0.01 0.21 0.98 0.65], 'Color','none','XLimMode', 'manual','YLimMode', 'manual',...
    'YDir','reverse','XColor','none','YColor','none','XTick',[],'YTick',[]); 
    haxROI.YLim = [0 IMsz(1)];
    haxROI.XLim = [0 IMsz(2)];
    hold on
    % 'NextPlot', 'replacechildren',
    
    
phIM = imagesc(IMGSraw(:,:,1,1) , 'Parent',haxROI);

haxROI.Title = text(0.5,0.5,'IMG Stack');


haxMINI = axes('Parent', IMpanel, 'NextPlot', 'replacechildren',...
    'Position', [0.01 0.02 0.98 0.18],...
    'XLimMode', 'manual','YLimMode', 'manual','Color','none');
    haxMINI.YLim = [-.10 .15];
    haxMINI.XLim = [1 100];


%----------------------------------------------------
%%     OPTIONS TAB
%----------------------------------------------------



%-----------------------------------
%    FIND ROI PANEL
%-----------------------------------
GIPpanelH = uipanel('Parent', btabs,'Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.02 0.02 0.45 0.95]); % 'Visible', 'Off',

findROIcallbackH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.90 .90 .09], 'FontSize', 13, 'String', 'FIND ROI',...
    'Callback', @findROIcallback, 'Enable','on');



buttongroup1 = uibuttongroup('Parent', GIPpanelH,'Title','ROI FACTOR',...
                  'Units', 'normalized','Position',[.01 0.45 .98 .40],...
                  'SelectionChangedFcn',@buttongroup1selection);
              
bva = 1;

if size(CSUSvals,1) > 0
    fac1 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.86 .90 .10],...
        'String',CSUSvals(1),'HandleVisibility','off');
end
if size(CSUSvals,1) > 1
    fac2 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.72 .90 .10],...
        'String',CSUSvals(2),'HandleVisibility','off');
end
if size(CSUSvals,1) > 2
    fac3 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.58 .90 .10],...
        'String',CSUSvals(3),'HandleVisibility','off');
end
if size(CSUSvals,1) > 3
    fac4 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.44 .90 .10],...
        'String',CSUSvals(4),'HandleVisibility','off');
end
if size(CSUSvals,1) > 4 
    fac5 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.30 .90 .10],...
        'String',CSUSvals(5),'HandleVisibility','off');
end
if size(CSUSvals,1) > 5
    fac6 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.16 .90 .10],...
        'String',CSUSvals(6),'HandleVisibility','off');
end
if size(CSUSvals,1) > 6
    fac7 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.02 .90 .10],...
        'String',CSUSvals(7),'HandleVisibility','off');
end





buttongroup2 = uibuttongroup('Parent', GIPpanelH,'Title','ROI COFACTOR',...
                  'Units', 'normalized','Position',[.01 0.01 .98 .40],...
                  'SelectionChangedFcn',@buttongroup2selection);
              
bva = 1;

if size(CSUSvals,1) > 0
    cofac1 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.86 .90 .10],...
        'String',CSUSvals(1),'HandleVisibility','off');
end
if size(CSUSvals,1) > 1
    cofac2 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.72 .90 .10],...
        'String',CSUSvals(2),'HandleVisibility','off');
end
if size(CSUSvals,1) > 2
    cofac3 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.58 .90 .10],...
        'String',CSUSvals(3),'HandleVisibility','off');
end
if size(CSUSvals,1) > 3
    cofac4 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.44 .90 .10],...
        'String',CSUSvals(4),'HandleVisibility','off');
end
if size(CSUSvals,1) > 4 
    cofac5 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.30 .90 .10],...
        'String',CSUSvals(5),'HandleVisibility','off');
end
if size(CSUSvals,1) > 5
    cofac6 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.16 .90 .10],...
        'String',CSUSvals(6),'HandleVisibility','off');
end
if size(CSUSvals,1) > 6
    cofac7 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.02 .90 .10],...
        'String',CSUSvals(7),'HandleVisibility','off');
end


function buttongroup1selection(source,callbackdata)
    
    % memolog(['Previous ROI factor: ' callbackdata.OldValue.String])
    % memolog(['Current ROI factor: ' callbackdata.NewValue.String])
    memolog(['Factor set to: ' callbackdata.NewValue.String])
    ROIfac = callbackdata.NewValue.String;
end


function buttongroup2selection(source,callbackdata)
    memolog(['Cofactor set to: ' callbackdata.NewValue.String])
    ROIcof = callbackdata.NewValue.String;
end


%-----------------------------------
%    ROI PARAMETERS PANEL
%-----------------------------------
ParamPanelH = uipanel('Parent', btabs,'Title','ROI Search Parameters','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.64 0.45 0.34]); % 'Visible', 'Off',


smoothimgtxtH = uicontrol('Parent', ParamPanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.85 0.46 0.10], 'FontSize', 10,'String', 'Smooth amount: ');
smoothimgnumH = uicontrol('Parent', ParamPanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.51 0.87 0.42 0.10], 'FontSize', 10,'Callback',@smoothimgnumHCallback);


quantMinT = uicontrol('Parent', ParamPanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.70 0.46 0.10], 'FontSize', 10,'String', 'Min Quantile: ');
quantMinH = uicontrol('Parent', ParamPanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.51 0.72 0.42 0.10], 'FontSize', 10,'Callback',@quanMinFun);

minROIszT = uicontrol('Parent', ParamPanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.55 0.46 0.10], 'FontSize', 10,'String', 'Min ROI pixels: ');
minROIszH = uicontrol('Parent', ParamPanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.51 0.57 0.42 0.10], 'FontSize', 10,'Callback',@minROIszFun);



% zcrittxtH = uicontrol('Parent', ParamPanelH, 'Style', 'Text', 'Units', 'normalized',...
%     'Position', [0.01 0.70 0.46 0.10], 'FontSize', 10,'String', 'Z-score min: ');
% zcritnumH = uicontrol('Parent', ParamPanelH, 'Style', 'Edit', 'Units', 'normalized', ...
%     'Position', [0.51 0.72 0.42 0.10], 'FontSize', 10,'Callback',@zcritnumHCallback);
% 
% 
% zouttxtH = uicontrol('Parent', ParamPanelH, 'Style', 'Text', 'Units', 'normalized',...
%     'Position', [0.01 0.55 0.46 0.10], 'FontSize', 10,'String', 'Z-score max: ');
% zoutnumH = uicontrol('Parent', ParamPanelH, 'Style', 'Edit', 'Units', 'normalized', ...
%     'Position', [0.51 0.57 0.42 0.10], 'FontSize', 10,'Callback',@zoutnumHCallback);


smoothimgnumH.String    = num2str(BlurVal);
% zcritnumH.String      = num2str(zcrit);
% zoutnumH.String       = num2str(zout);
quantMinH.String        = num2str(quantMin);
minROIszH.String        = num2str(minROIsz);







%-----------------------------------
%    PLOT DISPLAY CHECKLIST PANEL
%-----------------------------------
TimePanelH = uipanel('Parent', btabs,'Title','Timing Parameters','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.25 0.45 0.34]); % 'Visible', 'Off',

frameinfoH = uicontrol('Parent', TimePanelH, 'Units', 'normalized', ...
    'Position', [.01 0.80 .98 .18], 'FontSize', 13, 'String', 'Frame Timing Info',...
    'Callback', @frameinfocallback, 'Enable','on');


custFrameTimingH = uicontrol('Parent', TimePanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [.01 0.15 .98 .12], 'FontSize', 11,'String', 'Start Frame     -     End Frame');
SframeH = uicontrol('Parent', TimePanelH, 'Style', 'Edit', 'Units', 'normalized','Enable', 'Off',...
    'Position', [.01 0.01 .48 .13], 'FontSize', 10,'Callback',@custSFrameTiming);
EframeH = uicontrol('Parent', TimePanelH, 'Style', 'Edit', 'Units', 'normalized','Enable', 'Off', ...
    'Position', [.51 0.01 .48 .13], 'FontSize', 10,'Callback',@custEFrameTiming);

SframeH.String = num2str(Sframe);
EframeH.String = num2str(Eframe);


function custSFrameTiming(hObject, eventdata, handles)

    Sframe = str2double(get(hObject,'String'));
    SframeH.String = SframeH.String;
    memolog(['Start frame updated to: ' SframeH.String])
    memolog(['Frame range now: ' SframeH.String ' - ' EframeH.String])

end

function custEFrameTiming(hObject, eventdata, handles)

    Eframe = str2double(get(hObject,'String'));
    memolog(['End frame updated to: ' EframeH.String])
    memolog(['Frame range now: ' SframeH.String ' - ' EframeH.String])

end








frameBG = uibuttongroup('Parent', TimePanelH,'Title','Comparison Frame Range',...
                  'Units', 'normalized','Position',[.01 0.30 .98 .48],...
                  'SelectionChangedFcn',@frameBGfun);
              
    framerange1 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.01 0.70 .48 .20],'String','Baseline','HandleVisibility','off');


    framerange2 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.01 0.39 .48 .20],'String','Custom','HandleVisibility','off');
    
    
    framerange3 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.51 0.70 .48 .20],'String','CS Frames','HandleVisibility','off');

    framerange4 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.51 0.39 .48 .20],'String','US Frames','HandleVisibility','off');

function frameBGfun(source,callbackdata)
    
    frameSE = callbackdata.NewValue.String;
    
    
    memolog(['ROI period updated to: ' callbackdata.NewValue.String])
    
    
    if strcmp(frameSE,'Baseline')
        SframeH.String = 1;
        EframeH.String = Fcson-1;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    if strcmp(frameSE,'CS Frames')
        SframeH.String = Fcson;
        EframeH.String = Fcsoff;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    if strcmp(frameSE,'US Frames')
        SframeH.String = Fcsoff+1;
        EframeH.String = Fusend;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    if strcmp(frameSE,'Custom')
        SframeH.String = SframeH.String;
        EframeH.String = EframeH.String;
        SframeH.Enable = 'on';
        EframeH.Enable = 'on';
    end
    
    Sframe = str2num(SframeH.String);
    Eframe = str2num(EframeH.String);
    
    memolog(['Frame range: ' SframeH.String ' - ' EframeH.String])
    
end

frameBG.SelectedObject = framerange4;














%-----------------------------------
%    SAVE AND EXPORT PANEL
%-----------------------------------
GexportpanelH = uipanel('Parent', btabs,'Title','I/O','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.02 0.45 0.20]); % 'Visible', 'Off',

GexportvarsH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.65 0.95 0.28], 'FontSize', 13, 'String', 'Export ROIs to Workspace ',...
    'Callback', @exportROIs);


GsavedatasetH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.34 0.95 0.28], 'FontSize', 13, 'String', 'Save ROIs to .mat',...
    'Callback', @saveROIs);

GloadmatdataH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.28], 'FontSize', 13, 'String', 'Load ROIs from .mat',...
    'Callback', {@loadROIs,ROIDATA});



%----------------------------------------------------
%%    IMAGE VIEW PANEL
%----------------------------------------------------

IMGpanelH = uipanel('Parent', itabs,'Title','GRIN Image','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.01 0.01 0.98 0.97]); % 'Visible', 'Off',

haxIMG = axes('Parent', IMGpanelH, 'NextPlot', 'replacechildren',...
    'Position', [0.01 0.01 0.90 0.80], 'PlotBoxAspectRatio', [1 1 1], ...
    'XColor','none','YColor','none','YDir','reverse');

    haxIMG.XLim = [.5 slideValIM+.5];
    haxIMG.YLim = [.5 slideValIM+.5];

if all(IMG(1) == IMG(1:XLSdata.blockSize))

    IMG = IMG(1:XLSdata.blockSize:end,1:XLSdata.blockSize:end,:,:);
    IMGt = squeeze(reshape(IMG,numel(IMG(:,:,1)),[],size(IMG,3),size(IMG,4)));
    hIMG = imagesc(IMG(:,:,1,1) , 'Parent',haxIMG);
    slideValIM = size(IMG,1);
    XLSdata.blockSize = 1;
    
else

    hIMG = imagesc(IMGSraw(:,:,1,1) , 'Parent',haxIMG);
    
end



updateROIH = uicontrol('Parent', IMGpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.92 0.25 0.07], 'FontSize', 13, 'String', 'Update ROI',...
    'Callback', @updateROI);


RObg = uibuttongroup('Parent', IMGpanelH,'Visible','off','Units', 'normalized',...
                  'Position',[0.31 0.86 0.60 0.13],...
                  'SelectionChangedFcn',@bselection);
              
% Create three radio buttons in the button group.
if size(CSUSvals,1) > 0
CSUSr1 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(1),...
                  'Position',[.01 .52 .32 .45],...
                  'BackgroundColor',colorord(1,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 1
CSUSr2 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(2),...
                  'Position',[.34 .52 .32 .45],...
                  'BackgroundColor',colorord(2,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 2
CSUSr3 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(3),...
                  'Position',[.67 .52 .32 .45],...
                  'BackgroundColor',colorord(3,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 3
CSUSr4 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(4),...
                  'Position',[.01 .01 .32 .45],...
                  'BackgroundColor',colorord(4,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 4              
CSUSr5 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(5),...
                  'Position',[.34 .01 .32 .45],...
                  'BackgroundColor',colorord(5,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 5
CSUSr6 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(6),...
                  'Position',[.67 .01 .32 .45],...
                  'BackgroundColor',colorord(6,:),...
                  'HandleVisibility','off');
end              
 
% Make the uibuttongroup visible after creating child objects. 
RObg.Visible = 'on';



% haxIMG.XLim = [0 slideValIM];
% haxIMG.YLim = [0 slideValIM];

axis(haxIMG,[.5 slideValIM+.5 .5 slideValIM+.5]);
    
    

IMGsliderH = uicontrol('Parent', IMGpanelH, 'Units', 'normalized','Style','slider',...
	'Max',size(IMG,3),'Min',1,'Value',1,'SliderStep',[1 1]./size(IMG,3),...
	'Position', [0.01 0.801 0.94 0.05], 'Callback', @IMGslider);


AXsliderH = uicontrol('Parent', IMGpanelH, 'Units', 'normalized','Style','slider',...
	'Max',size(IMG,1)*2,'Min',size(IMG,1)/2,'Value',size(IMG,1),...
    'SliderStep',[1 1]./(size(IMG,1)),...
	'Position', [0.93 0.02 0.05 0.80], 'Callback', @AXslider);






%----------------------------------------------------
%%        CREATE DATA TABLE
%----------------------------------------------------


hROI = imrect(haxIMG, [XLSdata.blockSize*4+.5 XLSdata.blockSize*4+.5 ...
                       XLSdata.blockSize*2 XLSdata.blockSize*2]);

ROIpos = hROI.getPosition;


tv1 = round(ROIpos(1):ROIpos(1)+ROIpos(3));
tv2 = round(ROIpos(2):ROIpos(2)+ROIpos(4));

tv3 = squeeze(mean(mean(IMG(tv1,tv2,:,:))));


for nn = 1:size(XLSdata.CSUSvals,1)
    
    ROIs(:,nn) = mean(tv3(:,GRINstruct.tf(:,nn)),2);
    
end




tablesize = size(ROIs);
colnames = CSUSvals;
colfmt = repmat({'numeric'},1,length(colnames));
coledit = zeros(1,length(colnames))>1;
colwdt = repmat({100},1,length(colnames));


htable = uitable('Parent', dtabs,'Units', 'normalized',...
                 'Position', [0.02 0.02 0.95 0.95],...
                 'Data',  ROIs,... 
                 'ColumnName', colnames,...
                 'ColumnFormat', colfmt,...
                 'ColumnWidth', colwdt,...
                 'ColumnEditable', coledit,...
                 'ToolTipString',...
                 'Select cells to highlight them on the plot',...
                 'CellSelectionCallback', {@select_callback});






%----------------------------------------------------
%    PLOT DOT MARKERS AND MAKE THEM INVISIBLE
%----------------------------------------------------
GhaxGRIN.ColorOrderIndex = 1; 
hmkrs = plot(GhaxGRIN, ROIs, 'LineStyle', 'none',...
                    'Marker', '.',...
                    'MarkerSize',45);
                

leg1 = legend(hmkrs,unique(GRINstruct.csus));
	set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
                
set(hmkrs,'Visible','off','HandleVisibility', 'off')
                
%----------------------------------------------------
%    PLOT CS ON / OFF POINTS
%----------------------------------------------------                

CSonsetFrame = round(XLSdata.CSonsetDelay .* XLSdata.framesPerSec);
CSoffsetFrame = round((XLSdata.CSonsetDelay+XLSdata.CS_length) .* XLSdata.framesPerSec);


line([CSonsetFrame CSonsetFrame],GhaxGRIN.YLim,...
    'Color',[.8 .8 .8],'HandleVisibility', 'off','Parent',GhaxGRIN)
line([CSoffsetFrame CSoffsetFrame],GhaxGRIN.YLim,...
    'Color',[.8 .8 .8],'HandleVisibility', 'off','Parent',GhaxGRIN)
                



%----------------------------------------------------
%    PLOT DATA ON MINI AXES
%---------------------------------------------------- 
phMINI = plot(haxMINI, ROIs);
line([CSonsetFrame CSonsetFrame],haxMINI.YLim,...
    'Color',[.8 .8 .8],'HandleVisibility', 'off','Parent',haxMINI)
line([CSoffsetFrame CSoffsetFrame],haxMINI.YLim,...
    'Color',[.8 .8 .8],'HandleVisibility', 'off','Parent',haxMINI)
racerline = line([0 0],haxMINI.YLim,'Color',[.2 .8 .2],'Parent',haxMINI);
axes(GhaxGRIN)


%------------------------------------------------------------------------------
%        MAIN FUNCTION PROCESSES
%------------------------------------------------------------------------------
        
    CSUSvals = unique(GRINstruct.csus);

    
    GhaxGRIN.ColorOrderIndex = 1; 
    hp = plot(GhaxGRIN, ROIs , 'LineWidth',2);
    
    pause(1)
    
                            
%----------------------------------------------------
%        MAKE LINE PLOT OF DATA FROM COLUMN 1
%----------------------------------------------------

axdata = hp;
for cc = 1:size(axdata,1)

    colorz{cc} = axdata(cc).Color;
    % colors = {'b','m','r','y','c','k'}; % Use consistent color for lines
end

    set(hp,'Visible','off','HandleVisibility', 'off')
    


GhaxGRIN.NextPlot = 'Add';

GhaxGRIN.ColorOrderIndex = 1; 
for nn = 1:size(htable.Data,2)
    
	plot(GhaxGRIN, htable.Data(:,nn),...
        'DisplayName', htable.ColumnName{nn}, 'Color', colorz{nn}, 'LineWidth',2);

end
























% tabgp.SelectedTab = tabgp.Children(1);

tabgp.SelectedTab = tabgp.Children(2);
pause(.2)

tabgp.SelectedTab = tabgp.Children(3);
pause(.2)

tabgp.SelectedTab = tabgp.Children(4);
pause(.2)

tabgp.SelectedTab = tabgp.Children(1);
pause(.2)

memolog('Ready!')


















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        GUI HELPER FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





















%-----------------------------------------------------
% AXES SLIDER CALLBACK FUNCTIONS
%-----------------------------------------------------
function GimgsliderYA(hObject, eventdata)
slideValYA = GimgsliderYAH.Value;
GhaxGRIN.YLim = [slideValYB slideValYA];
end

function GimgsliderYB(hObject, eventdata)
slideValYB = GimgsliderYBH.Value;
GhaxGRIN.YLim = [slideValYB slideValYA];
end

function GimgsliderXA(hObject, eventdata)
slideValXA = GimgsliderXAH.Value;
GhaxGRIN.XLim = [slideValXB slideValXA];
end

function GimgsliderXB(hObject, eventdata)
slideValXB = GimgsliderXBH.Value;
GhaxGRIN.XLim = [slideValXB slideValXA];
end



%-----------------------------------------------------
% MANUAL ROI SELECTION RADIO BUTTONS CALLBACK
%-----------------------------------------------------
function bselection(source,callbackdata)
   display(['Previous: ' callbackdata.OldValue.String]);
   display(['Current: ' callbackdata.NewValue.String]);
   display('------------------');
   
   IMnow = find(strcmp(callbackdata.NewValue.String,CSUSvals));
   
   IM = squeeze(IMGSraw(:,:,:,IMnow));
   
   slideVal = ceil(IMGsliderH.Value);
   hIMG = imagesc(IM(:,:,slideVal) , 'Parent', haxIMG);
   drawnow
end







%------------------------------------------------------------------------------
%        UPDATE ROI
%------------------------------------------------------------------------------
function updateROI(hObject, eventdata)
    
    set(hmkrs,'Visible','on','HandleVisibility', 'on')
    delete(hmkrs)
    
    delete(leg1)
    delete(hp)
    
    delete(findobj(haxIMG,'Tag','imrect'))
    
    delete(GhaxGRIN.Children)

    memolog('UPDATING ROI...')
    
    
    hROI = imrect(haxIMG);
    
    ROIpos = hROI.getPosition;
    
    

    % ROImask = hROI.createMask(hIMG);
    % ROIarea = ROIpos(3) * ROIpos(4);
    % ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));

    tv1 = round(ROIpos(1):ROIpos(1)+ROIpos(3));
    tv2 = round(ROIpos(2):ROIpos(2)+ROIpos(4));

    tv3 = squeeze(mean(mean(IMG(tv1,tv2,:,:))));


    for nn = 1:size(XLSdata.CSUSvals,1)

        ROIs(:,nn) = mean(tv3(:,GRINstruct.tf(:,nn)),2);

    end




    tablesize = size(ROIs);
    colnames = CSUSvals;
    colfmt = repmat({'numeric'},1,length(colnames));
    coledit = zeros(1,length(colnames))>1;
    colwdt = repmat({100},1,length(colnames));


    htable = uitable('Parent', dtabs,'Units', 'normalized',...
                     'Position', [0.02 0.02 0.95 0.95],...
                     'Data',  ROIs,... 
                     'ColumnName', colnames,...
                     'ColumnFormat', colfmt,...
                     'ColumnWidth', colwdt,...
                     'ColumnEditable', coledit,...
                     'ToolTipString',...
                     'Select cells to highlight them on the plot',...
                     'CellSelectionCallback', {@select_callback});






    %----------------------------------------------------
    %    PLOT DOT MARKERS AND MAKE THEM INVISIBLE
    %----------------------------------------------------
    GhaxGRIN.ColorOrderIndex = 1; 
    hmkrs = plot(GhaxGRIN, ROIs, 'LineStyle', 'none',...
                        'Marker', '.',...
                        'MarkerSize',45);


    leg1 = legend(hmkrs,unique(GRINstruct.csus));
        set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
        set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])                

    set(hmkrs,'Visible','off','HandleVisibility', 'off')


    %----------------------------------------------------
    %    PLOT CS ON / OFF POINTS
    %----------------------------------------------------                

    CSonsetFrame = round(XLSdata.CSonsetDelay .* XLSdata.framesPerSec);
    CSoffsetFrame = round((XLSdata.CSonsetDelay+XLSdata.CS_length) .* XLSdata.framesPerSec);


    line([CSonsetFrame CSonsetFrame],GhaxGRIN.YLim,...
        'Color',[.8 .8 .8],'HandleVisibility', 'off','Parent',GhaxGRIN)
    line([CSoffsetFrame CSoffsetFrame],GhaxGRIN.YLim,...
        'Color',[.8 .8 .8],'HandleVisibility', 'off','Parent',GhaxGRIN)




    %------------------------------------------------------------------------------
    %        MAIN FUNCTION PROCESSES
    %------------------------------------------------------------------------------
        
    CSUSvals = unique(GRINstruct.csus);

    GhaxGRIN.ColorOrderIndex = 1; 
    hp = plot(GhaxGRIN, ROIs , 'LineWidth',2);
    
    pause(1)
    
                            
    %----------------------------------------------------
    %        MAKE LINE PLOT OF DATA FROM COLUMN 1
    %----------------------------------------------------

    axdata = hp;
    for cc = 1:size(axdata,1)

        colorz{cc} = axdata(cc).Color;
        % colors = {'b','m','r','y','c','k'}; % Use consistent color for lines
    end

        set(hp,'Visible','off','HandleVisibility', 'off')



    GhaxGRIN.NextPlot = 'Add';
    GhaxGRIN.ColorOrderIndex = 1; 

    for nn = 1:size(htable.Data,2)

        plot(GhaxGRIN, htable.Data(:,nn),...
            'DisplayName', htable.ColumnName{nn}, 'Color', colorz{nn}, 'LineWidth',2);

    end


end



%-----------------------------------------------------
% MANUAL ROI SELECTION IMAGE SIDER CALLBACKS
%-----------------------------------------------------
% IMAGE SIDER CALLBACK
function IMGslider(hObject, eventdata)

    slideVal = ceil(IMGsliderH.Value);

    hIMG = imagesc(IM(:,:,slideVal) , 'Parent', haxIMG);
              pause(.01)

    
    % disp(['image: ' num2str(slideVal) ' (' num2str(IMGsliderH.Value) ')'])
    memolog(['image: ' num2str(slideVal) ' (' num2str(IMGsliderH.Value) ')'])

end

% IMAGE AXES SIZE CALLBACK
function AXslider(hObject, eventdata)

    slideValIM = AXsliderH.Value;
    
    axis(haxIMG,[.5 slideValIM+.5 .5 slideValIM+.5]);
    
    % haxIMG.XLim = [0 slideValIM];
    % haxIMG.YLim = [0 slideValIM];
    
    memolog(['XLim: ' num2str(haxIMG.XLim) ' YLim: ' num2str(haxIMG.YLim)])
    
end



%----------------------------------------------------
%    DATA SPREADSHEET CALLBACK FUNCTIONS
%----------------------------------------------------

function plot_callback(hObject, eventdata, column)

    % htable.ColumnName{column}

    if (hObject.Value)

        GhaxGRIN.NextPlot = 'Add';

        plot(GhaxGRIN, htable.Data(:,column),...
            'DisplayName', htable.ColumnName{column},...
            'Color', colorz{column}, 'LineWidth',2);
    else
        delete(findobj(GhaxGRIN, 'DisplayName', htable.ColumnName{column}))
    end
end

function select_callback(hObject, eventdata)

    set(hmkrs, 'Visible', 'off') % turn them off to begin

    sel = eventdata.Indices;

    selcols = unique(sel(:,2));
    table = hObject.Data;

    for idx = 1:numel(selcols)
        col = selcols(idx);
        xvals = sel(:,1);
        xvals(sel(:,2) ~= col) = [];

        if col <= size(table,2)
            yvals = table(xvals, col)';
            % Create Z-vals = 1 in order to plot markers above lines
            zvals = col*ones(size(xvals));
            % Plot markers for xvals and yvals using a line object
            hmkrs(col).Visible = 'on';
            hmkrs(col).XData = xvals;
            hmkrs(col).YData = yvals;
            hmkrs(col).ZData = zvals;
        end

    end
end





%----------------------------------------------------
%        MASK KERNEL FUNCTION FOR FIND ROI
%----------------------------------------------------
function Mask = GRINkern(varargin)


    if nargin < 1
    
        GNpk  = 2.5;	% HIGHT OF PEAK
        GNnum = 11;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 1
        v1 = varargin{1};
        
        GNpk  = v1;     % HIGHT OF PEAK
        GNnum = 11;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 2
        [v1, v2] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 3
        [v1, v2, v3] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 4
        [v1, v2, v3, v4] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = v4;     % RESOLUTION
        doMASKfig = 0;
        
    elseif nargin == 5
        [v1, v2, v3, v4, v5] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = v4;     % RESOLUTION
        doMASKfig = v5;

    else
        warning('Too many inputs')
    end

%% -- MASK SETUP
GNx0 = 0;       % x-axis peak locations
GNy0 = 0;   	% y-axis peak locations
GNspr = ((GNnum-1)*GNres)/2;

a = .5/GNsd^2;
c = .5/GNsd^2;

[X, Y] = meshgrid((-GNspr):(GNres):(GNspr), (-GNspr):(GNres):(GNspr));
Z = GNpk*exp( - (a*(X-GNx0).^2 + c*(Y-GNy0).^2)) ;

Mask=Z;

spf1=sprintf('  SIZE OF MASK:   % s x % s', num2str(GNnum), num2str(GNnum));
spf2=sprintf('  STDEV OF SLOPE: % s', num2str(GNsd));
spf3=sprintf('  HIGHT OF PEAK:  % s', num2str(GNpk));
spf4=sprintf('  RESOLUTION:     % s', num2str(GNres));


% memolog('SMOOTHING KERNEL PARAMETERS:')
% memolog(spf1)
% memolog(spf2)
% memolog(spf3)
% memolog(spf4)



end








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     SINGLE FACTOR NO COFACTOR ROI FINDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------
%        SINGLE FACTOR NO COFACTOR ROI FINDER
%----------------------------------------------------
function findHighActivity(ROIf,TreatGroup,IMGSdf,IMGSraw,Sframe,Eframe)
    
    rawDiff = IMGSraw(:,:,:,ROIf);
    dfDiff = IMGSdf(:,:,:,ROIf);
        
    dfDiffmu = mean(dfDiff(:,:,Sframe:Eframe),3);
    
    ff = 1;
    if Eframe ~= XLSdata.framesPerTrial && Sframe ~= 1
    
        NONdfDiff = dfDiff(:,:,1:Sframe);
        NONdfDiff(:,:,end+1:end+size(dfDiff(:,:,Eframe+1:end),3)) = dfDiff(:,:,Eframe+1:end);
        NONdfDiffmu = mean(NONdfDiff,3);
        
        DFmu = dfDiffmu - NONdfDiffmu;
        
%         %for f = Sframe:Eframe
%         for f = 1:size(dfDiff,3)
%             dfFRAMES(:,:,f) = dfDiff(:,:,f) - NONdfDiffmu(:,:);
%             % dfFRAMES(:,:,f) = (dfDiff(:,:,f) - NONdfDiffmu(:,:)) ./ NONdfDiffmu(:,:);
%             %ff=ff+1;
%         end
        
    elseif Eframe == XLSdata.framesPerTrial && Sframe ~= 1
        
        NONdfDiff = dfDiff(:,:,1:Sframe);
        NONdfDiffmu = mean(NONdfDiff,3);
        
        DFmu = dfDiffmu - NONdfDiffmu;
        
%         for f = Sframe:Eframe
%             dfFRAMES(:,:,f) = dfDiff(:,:,f) - NONdfDiffmu(:,:);
%             %dfFRAMES(:,:,f) = (dfDiff(:,:,f) - NONdfDiffmu(:,:)) ./ NONdfDiffmu(:,:);
%             ff=ff+1;
%         end
        
    elseif Eframe ~= XLSdata.framesPerTrial && Sframe == 1
        
        NONdfDiff = dfDiff(:,:,Eframe+1:end);
        NONdfDiffmu = mean(NONdfDiff,3);
        
        DFmu = dfDiffmu - NONdfDiffmu;
        
%         for f = Sframe:Eframe
%             dfFRAMES(:,:,f) = dfDiff(:,:,f) - NONdfDiffmu(:,:);
%             %dfFRAMES(:,:,f) = (dfDiff(:,:,f) - NONdfDiffmu(:,:)) ./ NONdfDiffmu(:,:);
%             ff=ff+1;
%         end
        
    else
        
        msgbox('The selected frame range is invalid!');
        return
        
    end
    
    
%     %-----------------------------------------
%     phIM = imagesc(rawDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
%     cmax = max(max(max(rawDiff)));
%     cmin = min(min(min(rawDiff)));
%     cmax = cmax - abs(cmax/2.5);
%     cmin = cmin + abs(cmin/2.5);
%     if cmin == cmax; msgbox('No ROIs found!'); return; end
%     haxROI.CLim = [cmin cmax];
%     %----
%     for ff = 1:size(rawDiff,3)
% 
%         phIM.CData = rawDiff(:,:,ff);
% 
%         haxROI.Title = text(0.5,0.5,sprintf('Highest [%s] activity between %s - %s .   FRAME(%.0f)',...
%         TreatGroup, num2str(Sframe), num2str(Eframe), ff));
% 
%         pause(.04)
%     end
%     %-----------------------------------------
    
    
    
    %% GET DATA ABOVE QUANTILE THRESHOLD FOR DF STACK
clear USFHa USFH_Zscore USFHzcrit USFHzout USFH


% FACTORdf   = dfFRAMES(:,:,Sframe:Eframe);
% COFACTdf   = NONdfDiff;
% USFHa = reshape(DFmu,numel(DFmu),[],1);    
% % USFHa = reshape(dfDiff(:,:,Sframe:Eframe),numel(dfDiff(:,:,Sframe:Eframe)),[],1);
% 
%     qcrit = quantile(USFHa,quantMin);
%     
%     USFHqcrit   = min(USFHa(USFHa>qcrit));
% 
% USFH = mean(FACTORdf,3);
% % USFH = mean(dfDiff(:,:,Sframe:Eframe),3);
% ZdfDiff = convn( USFH, GRINkern(.5, 9, BlurVal, .1, 1),'same');
% 
%     lintrans = @(x,a,b,c,d) (c.*(1-(x-a)./(b-a)) + d.*((x-a)./(b-a)));
%     ZdfDiff = lintrans(ZdfDiff,...
%                         min(min(min(min(ZdfDiff)))),...
%                         max(max(max(max(ZdfDiff)))),...
%                         min(min(min(min(dfDiff)))),...
%                         max(max(max(max(dfDiff)))));
% 
% ZdfDiff(ZdfDiff<USFHqcrit) = 0;

    DFmuCon = convn( DFmu, GRINkern(.5, 9, BlurVal, .1, 1),'same');

    qcrit = quantile(DFmuCon(:),quantMin);
    
    DFmuCon(DFmuCon<qcrit) = 0;
        
    %-----------------------------------------
    cmax = max(max(max(DFmuCon)));
    cmin = min(min(min(DFmuCon)));
    cmax = cmax - abs(cmax/5);
    cmin = cmin + abs(cmin/5);
    if cmin == cmax; msgbox('No ROIs found!'); return; end
    haxROI.CLim = [cmin cmax];

    phIM = imagesc(DFmuCon,'Parent',haxROI,'CDataMapping','scaled');
    pause(1)
    % mbx = msgbox('CLICK OK TO CONTINUE');
    % uiwait(mbx);
    %-----------------------------------------
    
    
    %% DETERMINE CONTINGUOUS PIXEL REGIONS WITH HIGH Z-SCORES


    colorlist = [.99 .00 .00; .00 .99 .00; .99 .88 .88; .11 .77 .77;
                 .77 .77 .11; .77 .11 .77; .00 .00 .99; .22 .33 .44];

    BW = im2bw(DFmuCon, graythresh(DFmuCon));

    %BWc = convn( BW, GRINkern(.5, 9, BlurVal, .1, 1) ,'same');
    %BW = im2bw(BWc, graythresh(BWc));

    BW_filled = imfill(BW,'holes');
        
    %-----------------------------------------
    cmax = max(max(max(BW_filled))).*1.0;
    cmin = min(min(min(BW_filled))).*1.0;
    cmax = cmax - abs(cmax/5);
    cmin = cmin + abs(cmin/5);
    if cmin == cmax; msgbox('No ROIs found!'); return; end
    haxROI.CLim = [cmin cmax];

    phIM = imagesc(BW_filled,'Parent',haxROI,'CDataMapping','scaled');
    pause(1)
    %-----------------------------------------


    %-----------------------------------------
    cmax = max(max(max(dfDiff)));
    cmin = min(min(min(dfDiff)));
    cmax = cmax - abs(cmax/1.2);
    cmin = cmin + abs(cmin/1.2);
    if cmin == cmax; msgbox('No ROIs found!'); return; end
    haxROI.CLim = [cmin cmax];

    phIM = imagesc(dfDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
    pause(1)
    %-----------------------------------------


    [B,L] = bwboundaries(BW,'noholes');

    clear TooSmall
    for mm = 1:size(B,1)

        TooSmall(mm) = length(B{mm}) < minROIsz;

    end


    B(TooSmall) = [];
    ROIROI = B;
    ROIMASK = BW_filled;

    haxROI.Title = text(0.5,0.5,sprintf('Found %.0f ROIs that past tests',length(B)));

    if length(B) > 2
    for k = 1:length(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1),'Parent',haxROI, 'Color', colorlist(1,:) , 'LineWidth', 2)
        pause(.04)
    end
    else
        msgbox('No ROIs found! Decrease quantile.');
        return;
    end


    phIM.CData = dfDiff(:,:,1);
    pause(.5)

    for m = 1:size(dfDiff,3)

        phIM.CData = dfDiff(:,:,m);

        racerline.XData = [m m];
        pause(.03)
    end




    %-----------------------------------------
    cmax = max(max(max(mean(dfDiff(:,:,Sframe:Eframe),3))));
    cmin = min(min(min(mean(dfDiff(:,:,Sframe:Eframe),3))));
    cmax = cmax - abs(cmax/2);
    cmin = cmin + abs(cmin/2);
    if cmin == cmax; msgbox('No ROIs found!'); return; end
    haxROI.CLim = [cmin cmax];

    phIM.CData = mean(dfDiff(:,:,Sframe:Eframe),3);

    haxROI.Title = text(0.5,0.5,...
        sprintf('Displaying mean difference between frames %.0f - %.0f',Sframe,Eframe));
    %-----------------------------------------




    %% GET DATA FOR ROI LINE PLOTS


    for v = 1:size(dfDiff,3)

        dfROI(:,:,v) = IMGSdf(:,:,v,ROIf) .* BW_filled;
        dROI = dfROI(:,:,v);
        dROI = dROI(:);
        ROIfacDat(v) = mean(dROI(dROI~=0));

    end


    %% PLOT ROI LINE PLOTS IN MAIN AXES

    delete(findobj(GhaxGRIN.Children))

    haxROI.Title = text(0.5,0.5,sprintf('Found %.0f ROI ROIs',length(ROIROI)));


    GhaxGRIN.ColorOrderIndex = 1;
    phMainData = plot([ROIfacDat]','Parent',GhaxGRIN, 'LineWidth',2);



    GhaxGRIN.ColorOrderIndex = 1; 
    hmkrs = plot(GhaxGRIN, [ROIfacDat]', 'LineStyle', 'none',...
                        'Marker', '.','MarkerSize',45);


    leg1 = legend(hmkrs,{TreatGroup});
        set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
        set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
        set(hmkrs,'Visible','off','HandleVisibility', 'off')                

    pause(.1)


    %% PREPARE ROI DATA FOR OUTPUT TO MAT FILE

    ROIinfo.ROIf = ROIf;
    ROIinfo.ROIc = ROIf;
    ROIinfo.TreatmentGroup = TreatGroup;
    ROIinfo.Sframe = Sframe;
    ROIinfo.Eframe = Eframe;
    ROIinfo.Fcson  = Fcson;
    ROIinfo.Fcsmid = Fcsmid;
    ROIinfo.Fcsoff = Fcsoff;
    ROIinfo.Fusmid = Fusmid;
    ROIinfo.Fusend = Fusend;


end









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%     ROI FINDER PROCESSING FUNCTION      #######   MAIN   ######
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------------------------------------
%        FIND ROI FUNCTION
%------------------------------------------------------------------------------
function findROIcallback(hObject, eventdata)

tabgp.SelectedTab = tabgp.Children(4); pause(1)

BlurVal   = str2num(smoothimgnumH.String);
quantMin  = str2num(quantMinH.String);
minROIsz  = str2num(minROIszH.String);


haxROI.Title = text(0.5,0.5,sprintf('Mean of Current IMG Stack'));
phIM.CData = squeeze(mean(squeeze(mean(IMG,4)),3));

racerline = line([nn nn],haxMINI.YLim,'Color',[.2 .8 .2],'Parent',haxMINI);
axes(GhaxGRIN)
% racerline.XData = [nn nn];
pause(1)




IMGSrawMean = squeeze(mean(IMGSraw,4));
%-----------------------------------------
% phIM.CData = IMGraw;
phIM = imagesc(IMGSrawMean(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
cmax = max(max(max(IMGSrawMean)));
cmin = min(min(min(IMGSrawMean)));
cmax = cmax - abs(cmax/5);
cmin = cmin + abs(cmin/5);
if cmin == cmax; msgbox('No ROIs found!'); return; end
haxROI.CLim = [cmin cmax];

phIM = imagesc(IMGSrawMean(:,:,1),'Parent',haxROI);
%-----------------------------------------

for nn = 1:size(IMGSrawMean,3)
    
    phIM.CData = IMGSrawMean(:,:,nn);
    haxROI.Title = text(0.5,0.5,sprintf('Mean of Original Stack  FRAME(%.0f) ',nn));
    
    racerline.XData = [nn nn];
    pause(.03)
end












% GET FRAME FOR CS_ONSET CS_MIDWAY US_ONSET US_MIDWAY
Fcson   = XLSdata.CSonsetFrame;
Fcsmid  = Fcson + round(XLSdata.CS_lengthFrames/2);
Fcsoff  = XLSdata.CSoffsetFrame;
Fusmid  = Fcsoff + round((XLSdata.framesPerTrial - Fcsoff)/2);
Fusend  = XLSdata.framesPerTrial;
Sframe = str2num(SframeH.String);
Eframe = str2num(EframeH.String);


% GET TREATMENT GROUP STRINGS
TreatmentGroup = unique(GRINstruct.csus);

for nn = 1:size(GRINstruct.tf,2)
    RFac(nn) = strcmp(TreatmentGroup{nn},ROIfac);
    RCof(nn) = strcmp(TreatmentGroup{nn},ROIcof);
end

ROIf = find(RFac);
ROIc = find(RCof);







for nn = 1:size(GRINstruct.tf,2)

    IMGSdf(:,:,:,nn) = squeeze(mean(IMG(:,:,:,GRINstruct.tf(:,nn)),4));
        
end


% THE SIZE OF IMGSraw and IMGSdf is now ( nYpixels , nXpixels , nFRAMES , nGroups )
% NOTE THIS DOES *NOT* MEAN ( nYpixels , nXpixels , nFRAMES , *nTRIALS* )
%
% dfDiff  = IMG(factor)    -   IMG(cofactor)
% rawDiff = IMGraw(factor) -   IMGraw(cofactor)



%------------------------------------------------------------------------------
if strcmp(ROIfac,ROIcof)
    findHighActivity(ROIf,TreatmentGroup{ROIf},IMGSdf,IMGSraw,Sframe,Eframe)
    return
end
%------------------------------------------------------------------------------





haxROI.Title = text(0.5,0.5,sprintf('Making stack of: [%s] - [%s] ',...
    TreatmentGroup{ROIf},TreatmentGroup{ROIc}));


rawDiff = IMGSraw(:,:,:,ROIf) - IMGSraw(:,:,:,ROIc);
dfDiff = IMGSdf(:,:,:,ROIf) - IMGSdf(:,:,:,ROIc);
    









%-----------------------------------------
phIM = imagesc(rawDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
cmax = max(max(max(rawDiff)));
cmin = min(min(min(rawDiff)));
cmax = cmax - abs(cmax/2.5);
cmin = cmin + abs(cmin/2.5);
if cmin == cmax; msgbox('No ROIs found!'); return; end
haxROI.CLim = [cmin cmax];
%----
for nn = 1:size(rawDiff,3)
    
    phIM.CData = rawDiff(:,:,nn);
    
    haxROI.Title = text(0.5,0.5,sprintf('[%s] - [%s]    rawDiff(%.0f)',...
    TreatmentGroup{ROIf},TreatmentGroup{ROIc}, nn));

    racerline.XData = [nn nn];
    pause(.04)
end
%-----------------------------------------





%-----------------------------------------
phIM = imagesc(dfDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
cmax = max(max(max(dfDiff)));
cmin = min(min(min(dfDiff)));
cmax = cmax - abs(cmax/1.5);
cmin = cmin + abs(cmin/1.5);
if cmin == cmax; msgbox('No ROIs found!'); return; end
haxROI.CLim = [cmin cmax];
%----
for nn = 1:size(dfDiff,3)
    
    phIM.CData = dfDiff(:,:,nn);
        
    haxROI.Title = text(0.5,0.5,sprintf('[%s] - [%s]    dfDiff(%.0f)',...
    TreatmentGroup{ROIf},TreatmentGroup{ROIc}, nn));
    
    racerline.XData = [nn nn];
    pause(.04)
end
%-----------------------------------------





%% GET DATA ABOVE QUANTILE THRESHOLD FOR DF STACK

%{
% clear USFHa USFH_Zscore USFHzcrit USFHzout USFH
% % haxROI.Title = text(0.5,0.5,sprintf('Preparing ROI Trace %.0f ',1));
% 
% 
% USFHa = reshape(rawDiff(:,:,Sframe:Eframe),numel(rawDiff(:,:,Sframe:Eframe)),[],1);
% 
% USFH_Zscore = zscore(USFHa);
% USFHzcrit   = min(USFHa(USFH_Zscore>zcrit));
% USFHzout    = min(USFHa(USFH_Zscore>zout));
% 
% if isempty(USFHzout); 
%     USFHzout = max(USFHa); 
% end
% 
% USFH = mean(rawDiff(:,:,Sframe:Eframe),3);
% ZrawDiff = convn( USFH, GRINkern(.5, 9, BlurVal, .1, 1),'same');
% ZrawDiff(ZrawDiff<USFHzcrit | ZrawDiff>USFHzout) = 0;
% ----------------------------------------------------------
% USFHa = reshape(dfDiff(:,:,Sframe:Eframe),numel(dfDiff(:,:,Sframe:Eframe)),[],1);
% 
%     qcrit = quantile(USFHa,quantMin);
%     
%     USFHqcrit   = min(USFHa(USFHa>qcrit));
% 
% USFH = mean(dfDiff(:,:,Sframe:Eframe),3);
% ZdfDiff = convn( USFH, GRINkern(.5, 9, BlurVal, .1, 1),'same');
% 
%     lintrans = @(x,a,b,c,d) (c.*(1-(x-a)./(b-a)) + d.*((x-a)./(b-a)));
%     ZdfDiff = lintrans(ZdfDiff,...
%                         min(min(min(min(ZdfDiff)))),...
%                         max(max(max(max(ZdfDiff)))),...
%                         min(min(min(min(USFH)))),...
%                         max(max(max(max(USFH)))));
% 
% ZdfDiff(ZdfDiff<USFHqcrit) = 0;
%}

clear USFHa USFH_Zscore USFHzcrit USFHzout USFH


    DFmu = mean(dfDiff(:,:,Sframe:Eframe),3);
    
    DFmuCon = convn( DFmu, GRINkern(.5, 9, BlurVal, .1, 1),'same');

    qcrit = quantile(DFmuCon(:),quantMin);
    
    DFmuCon(DFmuCon<qcrit) = 0;


%% DETERMINE CONTINGUOUS PIXEL REGIONS WITH HIGH Z-SCORES
colorlist = [.99 .00 .00; .00 .99 .00; .99 .88 .88; .11 .77 .77;
             .77 .77 .11; .77 .11 .77; .00 .00 .99; .22 .33 .44];

BW = im2bw(DFmuCon, graythresh(DFmuCon));

% BWc = convn( BW, GRINkern(.5, 9, BlurVal, .1, 1) ,'same');
% BW = im2bw(BWc.*1.0, graythresh(BW.*1.0));

BW_filled = imfill(BW,'holes');

%-----------------------------------------
cmax = max(max(max(BW_filled))).*1.0;
cmin = min(min(min(BW_filled))).*1.0;
cmax = cmax - abs(cmax/5);
cmin = cmin + abs(cmin/5);
if cmin == cmax; msgbox('No ROIs found!'); return; end
haxROI.CLim = [cmin cmax];

phIM = imagesc(BW_filled,'Parent',haxROI,'CDataMapping','scaled');
pause(1)
%-----------------------------------------


%-----------------------------------------
cmax = max(max(max(dfDiff)));
cmin = min(min(min(dfDiff)));
cmax = cmax - abs(cmax/1.2);
cmin = cmin + abs(cmin/1.2);
if cmin == cmax; msgbox('No ROIs found!'); return; end
haxROI.CLim = [cmin cmax];

phIM = imagesc(dfDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
pause(1)
%-----------------------------------------


[B,L] = bwboundaries(BW,'noholes');

clear TooSmall
for mm = 1:size(B,1)

    TooSmall(mm) = length(B{mm}) < minROIsz;

end


B(TooSmall) = [];
ROIROI = B;
ROIMASK = BW_filled;

haxROI.Title = text(0.5,0.5,sprintf('Found %.0f ROIs that past tests',length(B)));

for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1),'Parent',haxROI, 'Color', colorlist(1,:) , 'LineWidth', 2)
    pause(.04)
end



phIM.CData = dfDiff(:,:,1);
haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'BASELINE'));
pause(.5)

for m = 1:size(dfDiff,3)
    
    phIM.CData = dfDiff(:,:,m);
    
    if m == Fcson
    haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',Fcson,'CS ON'));
    elseif m == Fcsoff
    haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',Fcsoff,'CS OFF'));
    % elseif m == Fcsoff
    % haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'US ON'));
    % elseif m == Fusend
    % haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'US OFF'));
    end
    
    racerline.XData = [nn nn];
    pause(.03)
end




%-----------------------------------------
cmax = max(max(max(mean(dfDiff(:,:,Sframe:Eframe),3))));
cmin = min(min(min(mean(dfDiff(:,:,Sframe:Eframe),3))));
cmax = cmax - abs(cmax/2);
cmin = cmin + abs(cmin/2);
if cmin == cmax; msgbox('No ROIs found!'); return; end
haxROI.CLim = [cmin cmax];

phIM.CData = mean(dfDiff(:,:,Sframe:Eframe),3);

haxROI.Title = text(0.5,0.5,...
    sprintf('Displaying mean difference between frames %.0f - %.0f',Sframe,Eframe));
%-----------------------------------------







%% GET DATA FOR ROI LINE PLOTS


for v = 1:size(dfDiff,3)

    dfROI(:,:,v) = IMGSdf(:,:,v,ROIf) .* BW_filled;
    % dfROI(:,:,nn) = dfDiff(:,:,nn) .* BW_filled;
    dROI = dfROI(:,:,v);
    dROI = dROI(:);
    ROIfacDat(v) = mean(dROI(dROI~=0));

end

for v = 1:size(dfDiff,3)

    dfROI(:,:,v) = IMGSdf(:,:,v,ROIc) .* BW_filled;
    % dfROI(:,:,v) = dfDiff(:,:,v) .* BW_filled;
    dROI = dfROI(:,:,v);
    dROI = dROI(:);
    ROIcofDat(v) = mean(dROI(dROI~=0));

end




%% PLOT ROI LINE PLOTS IN MAIN AXES

delete(findobj(GhaxGRIN.Children))

haxROI.Title = text(0.5,0.5,sprintf('Found %.0f ROI ROIs',length(ROIROI)));


GhaxGRIN.ColorOrderIndex = 1;
phMainData = plot([ROIfacDat; ROIcofDat]','Parent',GhaxGRIN, 'LineWidth',2);



GhaxGRIN.ColorOrderIndex = 1; 
hmkrs = plot(GhaxGRIN, [ROIfacDat; ROIcofDat]', 'LineStyle', 'none',...
                    'Marker', '.','MarkerSize',45);
                

leg1 = legend(hmkrs,{TreatmentGroup{ROIf},TreatmentGroup{ROIc}});
    set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
    set(hmkrs,'Visible','off','HandleVisibility', 'off')                


% if max(ROIfacDat) > .1;
%     GhaxGRIN.YLim = [0 max(ROIfacDat)];
% else
%     GhaxGRIN.YLim = [0 .1];
% end
% pause(.1)

% if max(ROIfacDat) > .1 && min(ROIfacDat) >= 0
%     
%     GhaxGRIN.YLim = [0 max(ROIfacDat)];
%     
% elseif max(ROIfacDat) > .1 && min(ROIfacDat) < 0
%     
%     GhaxGRIN.YLim = [min(ROIfacDat) max(ROIfacDat)];
%     
% else
%     GhaxGRIN.YLim = [0 .1];
% end
pause(.1)


%% PREPARE ROI DATA FOR OUTPUT TO MAT FILE

ROIinfo.ROIf = ROIf;
ROIinfo.ROIc = ROIc;
ROIinfo.TreatmentGroup = TreatmentGroup;
ROIinfo.Sframe = Sframe;
ROIinfo.Eframe = Eframe;
ROIinfo.Fcson  = Fcson;
ROIinfo.Fcsmid = Fcsmid;
ROIinfo.Fcsoff = Fcsoff;
ROIinfo.Fusmid = Fusmid;
ROIinfo.Fusend = Fusend;


%%
end












%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        PLOT ROI LOADED FROM MAT FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------------------------------------------------------
%        PLOT ROI LOADED FROM MAT FILE
%------------------------------------------------------------------------------
function plotROIloaded(ROIDATANEW, ROIMASKNEW, ROIROINEW, ROIfacDatNEW, ROIcofDatNEW, ROIinfoNEW)


tabgp.SelectedTab = tabgp.Children(4);
pause(1)
    
     
ROIc = ROIinfoNEW.ROIf;
ROIf = ROIinfoNEW.ROIc;
TreatmentGroup = ROIinfoNEW.TreatmentGroup;
Sframe = ROIinfoNEW.Sframe;
Eframe = ROIinfoNEW.Eframe;
Fcson  = ROIinfoNEW.Fcson;
Fcsmid = ROIinfoNEW.Fcsmid;
Fcsoff = ROIinfoNEW.Fcsoff;
Fusmid = ROIinfoNEW.Fusmid;
Fusend = ROIinfoNEW.Fusend;     
    

for k = 1:length(ROIROINEW)
    boundary = ROIROINEW{k};
    plot(boundary(:,2), boundary(:,1),'Parent',haxROI, 'Color', [.00 .99 .00] , 'LineWidth', 2)
end


for m = 1:size(dfDiff,3)
    
    phIM.CData = dfDiff(:,:,m);
    
    if m == Fcson
    haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',Fcson,'CS ON'));
    elseif m == Fcsoff
    haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',Fcsoff,'CS OFF'));
    end
    
    pause(.03)
end



%-----------------------------------------
cmax = max(max(max(mean(dfDiff(:,:,Sframe:Eframe),3))));
cmin = min(min(min(mean(dfDiff(:,:,Sframe:Eframe),3))));
cmax = cmax - abs(cmax/2);
cmin = cmin + abs(cmin/2);
haxROI.CLim = [cmin cmax];

phIM.CData = mean(dfDiff(:,:,Sframe:Eframe),3);

haxROI.Title = text(0.5,0.5,...
    sprintf('Displaying mean difference between frames %.0f - %.0f',Sframe,Eframe));
%-----------------------------------------






%% GET DATA FOR ROI LINE PLOTS


for nn = 1:size(dfDiff,3)

    dfROI(:,:,nn) = IMGSdf(:,:,nn,ROIf) .* ROIMASKNEW;

    dROI = dfROI(:,:,nn);
    dROI = dROI(:);
    ROIfacDatNEW(nn) = mean(dROI(dROI~=0));
    % ROIfacDatNEW(nn) = mean(dROI);

end

for nn = 1:size(dfDiff,3)

    dfROI(:,:,nn) = IMGSdf(:,:,nn,ROIc) .* ROIMASKNEW;

    dROI = dfROI(:,:,nn);
    dROI = dROI(:);
    ROIcofDatNEW(nn) = mean(dROI(dROI~=0));
    % ROIcofDatNEW(nn) = mean(dROI);

end



%% PLOT ROI LINE PLOTS IN MAIN AXES

delete(findobj(GhaxGRIN.Children))

haxROI.Title = text(0.5,0.5,sprintf('Found %.0f ROI ROIs',length(ROIROI)));

GhaxGRIN.ColorOrderIndex = 1;
phMainData = plot([ROIfacDatNEW; ROIcofDatNEW; ROIfacDat; ROIcofDat]',...
                 'Parent',GhaxGRIN, 'LineWidth',2);
phMainData(1).LineStyle = '-';
phMainData(2).LineStyle = '-';
phMainData(3).LineStyle = ':';
phMainData(4).LineStyle = ':';
phMainData(3).Color = phMainData(1).Color;
phMainData(4).Color = phMainData(2).Color;


GhaxGRIN.ColorOrderIndex = 1; 
hmkrs = plot(GhaxGRIN, [ROIfacDatNEW; ROIcofDatNEW; ROIfacDat; ROIcofDat]',...
            'LineStyle', 'none','Marker', '.','MarkerSize',45);
hmkrs(1).LineStyle = '-';
hmkrs(2).LineStyle = '-';
hmkrs(3).LineStyle = ':';
hmkrs(4).LineStyle = ':';
hmkrs(3).Color = hmkrs(1).Color;
hmkrs(4).Color = hmkrs(2).Color;        


leg1 = legend(hmkrs,{[TreatmentGroup{ROIf} ' [SOLID=LOADED]'],[TreatmentGroup{ROIc} ' [SOLID=LOADED]'],...
                     [TreatmentGroup{ROIf} ' [DOT=WRKSPC]'], [TreatmentGroup{ROIc} ' [DOT=WRKSPC]']});
    set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
    set(hmkrs,'Visible','off','HandleVisibility', 'off')                



% if max([ROIfacDat ROIfacDatNEW]) > .1 && min([ROIfacDat ROIfacDatNEW]) >= 0
%     
%     GhaxGRIN.YLim = [0 max([ROIfacDat ROIfacDatNEW])];
%     
% elseif max([ROIfacDat ROIfacDatNEW]) > .1 && min([ROIfacDat ROIfacDatNEW]) < 0
%     
%     GhaxGRIN.YLim = [min([ROIfacDat ROIfacDatNEW]) max([ROIfacDat ROIfacDatNEW])];
%     
% else
%     GhaxGRIN.YLim = [0 .1];
% end







%%
end










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        DATA I/O SAVE & LOAD FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------
%        DATA I/O SAVE & LOAD FUNCTIONS
%----------------------------------------------------


function exportROIs(varargin)
    
    checkLabels = {'Save ROIROI to variable named:' ...
                   'Save ROIMASK to variable named:' ...
                   'Save ROIfacDat to variable named:' ...
                   'Save ROIcofDat to variable named:' ...
                   'Save ROIinfo to variable named:'}; 
    varNames = {'ROIROI','ROIMASK','ROIfacDat','ROIcofDat','ROIinfo'}; 
    items = {ROIROI,ROIMASK,ROIfacDat,ROIcofDat,ROIinfo};
    export2wsdlg(checkLabels,varNames,items,...
                 'Save Variables to Workspace');
    
end



function saveROIs(varargin)
    
    % [file,path] = uiputfile('*.mat','Save ROIs As');
    
    ROIinfo.ROIgroups = ROIgroups;
    
    uisave({'ROIROI','ROIMASK','ROIfacDat','ROIcofDat','ROIinfo'},...
           ['ROI_' ROIinfo.file(1:end-2) ' ' ROIfac{:} ' ' ROIcof{:}]);
    
end



function ROIDATA = loadROIs(hObject, eventdata, ROIDATA)
    
    [filename, pathname, filterindex] = uigetfile( ...
        {'*.mat','MAT-files (*.mat)'}, ...
        'Pick a file', ...
        'MultiSelect', 'on');

    % uiopen('.mat')
    
    
    
    ROIDATA = load([pathname,filename]);
    
    [ROIROINEW] = deal(ROIDATA.ROIROI);
    [ROIMASKNEW] = deal(ROIDATA.ROIMASK);
    [ROIfacDatNEW] = deal(ROIDATA.ROIfacDat);
    [ROIcofDatNEW] = deal(ROIDATA.ROIcofDat);
    [ROIinfoNEW] = deal(ROIDATA.ROIinfo);
    
    
    plotROIloaded(ROIDATANEW, ROIMASKNEW, ROIROINEW, ROIfacDatNEW, ROIcofDatNEW, ROIinfoNEW)
    
%     ROIDATA = {ROIROI , ROIfacDat , ROIcofDat};
    
end




%%
%----------------------------------------------------
%  PARAMETERS PANEL CALLBACKS FOR UICONTROL EDIT TEXT
%----------------------------------------------------

function smoothimgnumHCallback(hObject, eventdata, handles)

    BlurVal = str2double(get(hObject,'String'));
    memolog(sprintf('Convolution blur at %.2f stdev of Gaussian mask',BlurVal));

end

function zcritnumHCallback(hObject, eventdata, handles)

    zcrit = str2double(get(hObject,'String'));
    display(zcrit);

end

function zoutnumHCallback(hObject, eventdata, handles)

    zout = str2double(get(hObject,'String'));
    display(zout);

end

function quanMinFun(hObject, eventdata, handles)

    quantMin = str2double(get(hObject,'String'));
    memolog(sprintf('Quantile threshold set to %.1f percent',quantMin*100));

end

function minROIszFun(hObject, eventdata, handles)

    minROIsz = str2double(get(hObject,'String'));
    memolog(sprintf('Minimum ROI size set to %.0f pixels',minROIsz));

end




%----------------------------------------------------
%        MEMO LOG UPDATE
%----------------------------------------------------
function memolog(spf)
    
    if iscellstr(spf)
        spf = [spf{:}];
    end

    memos(1:end-1) = memos(2:end);
    memos{end} = spf;
    memoboxH.String = memos;
    pause(.02)

end





%----------------------------------------------------
%        FRAME INFO CALLBACK
%----------------------------------------------------
function frameinfocallback(hObject, eventdata)
    
    Fcson   = XLSdata.CSonsetFrame;
    Fcsmid  = Fcson + round(XLSdata.CS_lengthFrames/2);
    Fcsoff  = XLSdata.CSoffsetFrame;
    Fusmid  = Fcsoff + round((XLSdata.framesPerTrial - Fcsoff)/2);
    Fusend  = XLSdata.framesPerTrial;
    
    
    memolog(' ')
    memolog(sprintf('Frames per second: %s',num2str(XLSdata.framesPerSec)))
    memolog(sprintf('CS onset frame: %s',num2str(Fcson)))
    memolog(sprintf('CS middle frame: %s',num2str(Fcsmid)))
    memolog(sprintf('CS last frame: %s',num2str(Fcsoff)))
    memolog(sprintf('US middle frame: %s',num2str(Fusmid)))
    memolog(sprintf('Total/last frame: %s',num2str(Fusend)))

end













%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------
%        FIND ROI FUNCTION
%----------------------------------------------------
%----------------------------------------------------
%        PROCESS DATA FUNCTION
%----------------------------------------------------
%----------------------------------------------------
%        PLOT LICKING DATA FUNCTION
%----------------------------------------------------
%{
%----------------------------------------------------
%        PLOT LICKING DATA FUNCTION
%----------------------------------------------------
function plotLickData(hObject, eventdata)
    

    LICKmu = squeeze(sum(LICK,1));

    for nn = 1:size(XLSdata.CSUSvals,1)

        LICKs(:,nn) = mean(LICKmu(:,GRINstruct.tf(:,nn)),2);

    end

    % LhaxGRIN.ColorOrderIndex = 1; 
    % hpLick = plot(LhaxGRIN, LICKs , ':', 'LineWidth',2,'HandleVisibility', 'off');

    lickfigh = figure('Units', 'normalized','Position', [.02 .05 .50 .32], 'BusyAction',...
    'cancel', 'Name', 'lickfigh', 'Tag', 'lickfigh','MenuBar', 'none'); 

%     LhaxGRIN = axes('Parent', lickfigh, 'NextPlot', 'replacechildren',...
%     'Position', [0.05 0.05 0.9 0.9],'Color','none','XTick',[],'YTick',[],...
%     'XColor','none','YColor','none'); hold on;

    LhaxGRIN = axes('Parent', lickfigh, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.05 0.9 0.9],'Color','none'); hold on;

    LhaxGRIN.ColorOrderIndex = 1; 
    hpLick = plot(LhaxGRIN, LICKs , ':', 'LineWidth',2,'HandleVisibility', 'off');
    
    
    legLick = legend(hpLick,XLSdata.CSUSvals);
	set(legLick, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(legLick, 'Position', legLick.Position .* [1 .94 1 1.4])                
    

end



%----------------------------------------------------
%        PROCESS DATA FUNCTION
%----------------------------------------------------
function processDat(hObject, eventdata)

tabgp.SelectedTab = tabgp.Children(4);
pause(1)

% %-----------------------------------------
% % phIM.CData = IMGraw;
% phIM = imagesc(IMGSrawMean(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
% cmax = max(max(max(IMGSrawMean)));
% cmin = min(min(min(IMGSrawMean)));
% cmax = cmax - abs(cmax/5);
% cmin = cmin + abs(cmin/5);
% haxROI.CLim = [cmin cmax];
% 
% phIM = imagesc(IMGSrawMean(:,:,1),'Parent',haxROI);
% for nn = 1:size(IMGSrawMean,3)
%     phIM.CData = IMGSrawMean(:,:,nn);
%     haxROI.Title = text(0.5,0.5,sprintf('Mean of Original Stack  FRAME(%.0f) ',nn));
%     pause(.04)
% end
% %-----------------------------------------


% GET FRAME RANGE OF INTEREST
Fcson   = XLSdata.CSonsetFrame;
Fcsmid  = Fcson + round(XLSdata.CS_lengthFrames/2);
Fcsoff  = XLSdata.CSoffsetFrame;
Fusmid  = Fcsoff + round((XLSdata.framesPerTrial - Fcsoff)/2);
Fusend  = XLSdata.framesPerTrial;

TreatmentGroup = unique(GRINstruct.csus);

for nn = 1:size(GRINstruct.tf,2)
    RFac(nn) = strcmp(TreatmentGroup{nn},ROIfac);
    RCof(nn) = strcmp(TreatmentGroup{nn},ROIcof);
end

ROIf = find(RFac);
ROIc = find(RCof);






haxROI.Title = text(0.5,0.5,sprintf('Making stack of: [%s] - [%s] ',...
    TreatmentGroup{ROIf},TreatmentGroup{ROIc}));


for nn = 1:size(GRINstruct.tf,2)

    IMGSdf(:,:,:,nn) = squeeze(mean(IMG(:,:,:,GRINstruct.tf(:,nn)),4));
        
end


% THE SIZE OF IMGSraw and IMGSdf is now ( nYpixels , nXpixels , nFRAMES , nGroups )
% NOTE THIS DOES *NOT* MEAN ( nYpixels , nXpixels , nFRAMES , *nTRIALS* )
%
% dfDiff  = IMG(factor)    -   IMG(cofactor)
% rawDiff = IMGraw(factor) -   IMGraw(cofactor)



rawDiff = IMGSraw(:,:,:,ROIf) - IMGSraw(:,:,:,ROIc);
dfDiff = IMGSdf(:,:,:,ROIf) - IMGSdf(:,:,:,ROIc);
    









%-----------------------------------------
phIM = imagesc(rawDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
cmax = max(max(max(rawDiff)));
cmin = min(min(min(rawDiff)));
cmax = cmax - abs(cmax/2.5);
cmin = cmin + abs(cmin/2.5);
haxROI.CLim = [cmin cmax];
%----
for nn = 1:size(rawDiff,3)
    
    phIM.CData = rawDiff(:,:,nn);
    
    haxROI.Title = text(0.5,0.5,sprintf('[%s] - [%s]    rawDiff(%.0f)',...
    TreatmentGroup{ROIf},TreatmentGroup{ROIc}, nn));
    
    pause(.04)
end
%-----------------------------------------
end





%----------------------------------------------------
%        FIND ROI FUNCTION
%----------------------------------------------------
function findROI(hObject, eventdata)

    
tabgp.SelectedTab = tabgp.Children(4);
pause(1)


%-----------------------------------------
% phIM.CData = IMGraw;
% phIM = imagesc(IMGraw,'Parent',haxROI,'CDataMapping','scaled');
% cmax = max(max(max(IMGSrawMean)));
% cmin = min(min(min(IMGSrawMean)));
% haxROI.CLim = [cmin cmax];
%-----------------------------------------
% haxROI.Title = text(0.5,0.5,sprintf('Preparing ROI Trace %.0f ',1));

BlurVal = str2num(smoothimgnumH.String);
zcrit   = str2num(zcritnumH.String);
zout    = str2num(zoutnumH.String);


% haxROI.Title = text(0.5,0.5,sprintf('Mean of Original Stack'));
% phIM.CData = squeeze(mean(squeeze(mean(IMGSraw,4)),3));
% pause(1)



haxROI.Title = text(0.5,0.5,sprintf('Mean of Current IMG Stack'));
phIM.CData = squeeze(mean(squeeze(mean(IMG,4)),3));

pause(1)




IMGSrawMean = squeeze(mean(IMGSraw,4));
%-----------------------------------------
% phIM.CData = IMGraw;
phIM = imagesc(IMGSrawMean(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
cmax = max(max(max(IMGSrawMean)));
cmin = min(min(min(IMGSrawMean)));
cmax = cmax - abs(cmax/5);
cmin = cmin + abs(cmin/5);
haxROI.CLim = [cmin cmax];
%-----------------------------------------

phIM = imagesc(IMGSrawMean(:,:,1),'Parent',haxROI);

for nn = 1:size(IMGSrawMean,3)
    
    phIM.CData = IMGSrawMean(:,:,nn);
    haxROI.Title = text(0.5,0.5,sprintf('Mean of Original Stack  FRAME(%.0f) ',nn));
    pause(.04)
    
end












% GET FRAME FOR CS_ONSET CS_MIDWAY US_ONSET US_MIDWAY
Fcson   = XLSdata.CSonsetFrame;
Fcsmid  = Fcson + round(XLSdata.CS_lengthFrames/2);
Fcsoff  = XLSdata.CSoffsetFrame;
Fusmid  = Fcsoff + round((XLSdata.framesPerTrial - Fcsoff)/2);
Fusend  = XLSdata.framesPerTrial;



% GET TREATMENT GROUP STRINGS
% clear fid
% for nn = 1:size(GRINstruct.tf,2)
%     fid(nn) = find(GRINstruct.id==nn,1); 
% end
% TreatmentGroup = GRINstruct.csus(fid);

TreatmentGroup = unique(GRINstruct.csus);

for nn = 1:size(GRINstruct.tf,2)
    RFac(nn) = strcmp(TreatmentGroup{nn},ROIfac);
    RCof(nn) = strcmp(TreatmentGroup{nn},ROIcof);
end

ROIf = find(RFac);
ROIc = find(RCof);






haxROI.Title = text(0.5,0.5,sprintf('Making stack of: [%s] - [%s] ',...
    TreatmentGroup{ROIf},TreatmentGroup{ROIc}));


for nn = 1:size(GRINstruct.tf,2)

    IMGSdf(:,:,:,nn) = squeeze(mean(IMG(:,:,:,GRINstruct.tf(:,nn)),4));
        
end


% THE SIZE OF IMGSraw and IMGSdf is now ( nYpixels , nXpixels , nFRAMES , nGroups )
% NOTE THIS DOES *NOT* MEAN ( nYpixels , nXpixels , nFRAMES , *nTRIALS* )
%
% dfDiff  = IMG(factor)    -   IMG(cofactor)
% rawDiff = IMGraw(factor) -   IMGraw(cofactor)



rawDiff = IMGSraw(:,:,:,ROIf) - IMGSraw(:,:,:,ROIc);
dfDiff = IMGSdf(:,:,:,ROIf) - IMGSdf(:,:,:,ROIc);
    









%-----------------------------------------
phIM = imagesc(rawDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
cmax = max(max(max(rawDiff)));
cmin = min(min(min(rawDiff)));
cmax = cmax - abs(cmax/2.5);
cmin = cmin + abs(cmin/2.5);
haxROI.CLim = [cmin cmax];
%----
for nn = 1:size(rawDiff,3)
    
    phIM.CData = rawDiff(:,:,nn);
    
    haxROI.Title = text(0.5,0.5,sprintf('[%s] - [%s]    rawDiff(%.0f)',...
    TreatmentGroup{ROIf},TreatmentGroup{ROIc}, nn));
    
    pause(.04)
end
%-----------------------------------------





%-----------------------------------------
phIM = imagesc(dfDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
cmax = max(max(max(dfDiff)));
cmin = min(min(min(dfDiff)));
cmax = cmax - abs(cmax/1.5);
cmin = cmin + abs(cmin/1.5);
haxROI.CLim = [cmin cmax];
%----
for nn = 1:size(dfDiff,3)
    
    phIM.CData = dfDiff(:,:,nn);
        
    haxROI.Title = text(0.5,0.5,sprintf('[%s] - [%s]    dfDiff(%.0f)',...
    TreatmentGroup{ROIf},TreatmentGroup{ROIc}, nn));
    
    pause(.04)
     
end
%-----------------------------------------





%% GET Z-SCORE DATA FOR RAW AND DF STACKS


clear USFHa USFH_Zscore USFHzcrit USFHzout USFH
% haxROI.Title = text(0.5,0.5,sprintf('Preparing ROI Trace %.0f ',1));


USFHa = reshape(rawDiff(:,:,Fcsoff:Fusmid),numel(rawDiff(:,:,Fcsoff:Fusmid)),[],1);

USFH_Zscore = zscore(USFHa);
USFHzcrit   = min(USFHa(USFH_Zscore>zcrit));
USFHzout    = min(USFHa(USFH_Zscore>zout));

if isempty(USFHzout); 
    USFHzout = max(USFHa); 
end

USFH = mean(rawDiff(:,:,Fcsoff:Fusmid),3);
ZrawDiff = convn( USFH, GRINkern(.5, 9, BlurVal, .1, 1),'same');
ZrawDiff(ZrawDiff<USFHzcrit | ZrawDiff>USFHzout) = 0;




clear USFHa USFH_Zscore USFHzcrit USFHzout USFH

USFHa = reshape(dfDiff(:,:,Fcsoff:Fusmid),numel(dfDiff(:,:,Fcsoff:Fusmid)),[],1);

USFH_Zscore = zscore(USFHa);
USFHzcrit   = min(USFHa(USFH_Zscore>zcrit));
USFHzout    = min(USFHa(USFH_Zscore>zout));

if isempty(USFHzout); 
    USFHzout = max(USFHa); 
end

USFH = mean(dfDiff(:,:,Fcsoff:Fusmid),3);
ZdfDiff = convn( USFH, GRINkern(.5, 9, BlurVal, .1, 1),'same');
ZdfDiff(ZdfDiff<USFHzcrit | ZdfDiff>USFHzout) = 0;







%% DETERMINE CONTINGUOUS PIXEL REGIONS WITH HIGH Z-SCORES


colorlist = [.99 .00 .00; .00 .99 .00; .99 .88 .88; .11 .77 .77;
             .77 .77 .11; .77 .11 .77; .00 .00 .99; .22 .33 .44];

BW = im2bw(ZdfDiff, graythresh(ZdfDiff));

BWc = convn( BW, GRINkern(.5, 9, BlurVal, .1, 1) ,'same');

BW = im2bw(BWc, graythresh(BWc));

BW_filled = imfill(BW,'holes');


%-----------------------------------------
cmax = max(max(max(BW_filled))).*1.0;
cmin = min(min(min(BW_filled))).*1.0;
cmax = cmax - abs(cmax/5);
cmin = cmin + abs(cmin/5);
haxROI.CLim = [cmin cmax];

phIM = imagesc(BW_filled,'Parent',haxROI,'CDataMapping','scaled');
pause(1)
%-----------------------------------------


%-----------------------------------------
cmax = max(max(max(dfDiff)));
cmin = min(min(min(dfDiff)));
cmax = cmax - abs(cmax/1.2);
cmin = cmin + abs(cmin/1.2);
haxROI.CLim = [cmin cmax];

phIM = imagesc(dfDiff(:,:,1),'Parent',haxROI,'CDataMapping','scaled');
pause(1)
%-----------------------------------------


[B,L] = bwboundaries(BW,'noholes');

clear TooSmall
for mm = 1:size(B,1)

    TooSmall(mm) = length(B{mm}) < minROIsz;

end


B(TooSmall) = [];
ROIROI = B;
ROIMASK = BW_filled;

haxROI.Title = text(0.5,0.5,sprintf('Found %.0f ROIs that past tests',length(B)));

for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1),'Parent',haxROI, 'Color', colorlist(1,:) , 'LineWidth', 2)
    pause(.04)
end



phIM.CData = dfDiff(:,:,1);
haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'BASELINE'));
pause(.5)

for m = 1:size(dfDiff,3)
    
    phIM.CData = dfDiff(:,:,m);
    
    if m == Fcson
    haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',Fcson,'CS ON'));
    elseif m == Fcsoff
    haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',Fcsoff,'CS OFF'));
    % elseif m == Fcsoff
    % haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'US ON'));
    % elseif m == Fusend
    % haxROI.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'US OFF'));
    end
    
    pause(.04)
end




%-----------------------------------------
cmax = max(max(max(mean(dfDiff(:,:,Sframe:Eframe),3))));
cmin = min(min(min(mean(dfDiff(:,:,Sframe:Eframe),3))));
cmax = cmax - abs(cmax/2);
cmin = cmin + abs(cmin/2);
haxROI.CLim = [cmin cmax];

phIM.CData = mean(dfDiff(:,:,Sframe:Eframe),3);

haxROI.Title = text(0.5,0.5,...
    sprintf('Displaying mean difference between frames %.0f - %.0f',Sframe,Eframe));
%-----------------------------------------







%% GET DATA FOR ROI LINE PLOTS


for v = 1:size(dfDiff,3)

    dfROI(:,:,v) = IMGSdf(:,:,v,ROIf) .* BW_filled;
    % dfROI(:,:,nn) = dfDiff(:,:,nn) .* BW_filled;
    dROI = dfROI(:,:,v);
    dROI = dROI(:);
    ROIfacDat(v) = mean(dROI(dROI~=0));

end

for v = 1:size(dfDiff,3)

    dfROI(:,:,v) = IMGSdf(:,:,v,ROIc) .* BW_filled;
    % dfROI(:,:,v) = dfDiff(:,:,v) .* BW_filled;
    dROI = dfROI(:,:,v);
    dROI = dROI(:);
    ROIcofDat(v) = mean(dROI(dROI~=0));

end




%% PLOT ROI LINE PLOTS IN MAIN AXES

delete(findobj(GhaxGRIN.Children))

haxROI.Title = text(0.5,0.5,sprintf('Found %.0f ROI ROIs',length(ROIROI)));


GhaxGRIN.ColorOrderIndex = 1;
phMainData = plot([ROIfacDat; ROIcofDat]','Parent',GhaxGRIN, 'LineWidth',2);



GhaxGRIN.ColorOrderIndex = 1; 
hmkrs = plot(GhaxGRIN, [ROIfacDat; ROIcofDat]', 'LineStyle', 'none',...
                    'Marker', '.','MarkerSize',45);
                

leg1 = legend(hmkrs,{TreatmentGroup{ROIf},TreatmentGroup{ROIc}});
    set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
    set(hmkrs,'Visible','off','HandleVisibility', 'off')                


% if max(ROIfacDat) > .1;
%     GhaxGRIN.YLim = [0 max(ROIfacDat)];
% else
%     GhaxGRIN.YLim = [0 .1];
% end
% pause(.1)

% if max(ROIfacDat) > .1 && min(ROIfacDat) >= 0
%     
%     GhaxGRIN.YLim = [0 max(ROIfacDat)];
%     
% elseif max(ROIfacDat) > .1 && min(ROIfacDat) < 0
%     
%     GhaxGRIN.YLim = [min(ROIfacDat) max(ROIfacDat)];
%     
% else
%     GhaxGRIN.YLim = [0 .1];
% end
pause(.1)


%% PREPARE ROI DATA FOR OUTPUT TO MAT FILE

ROIinfo.ROIf = ROIf;
ROIinfo.ROIc = ROIc;
ROIinfo.TreatmentGroup = TreatmentGroup;
ROIinfo.Fcson  = Fcson;
ROIinfo.Fcsmid = Fcsmid;
ROIinfo.Fcsoff = Fcsoff;
ROIinfo.Fusmid = Fusmid;
ROIinfo.Fusend = Fusend;


%%
end


%}
