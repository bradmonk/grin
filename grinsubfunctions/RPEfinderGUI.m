function [graphguih] = RPEfinderGUI(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK)
%% RPEfinderGUI.m
% function [] = RPEfinderGUI(IMG, GRINstruct, XLSdata, LICK, IMGSraw, varargin)

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
global IM IMsz colorord haxRPE IMpanel phIM
global tabgp btabs dtabs itabs gtabs
global RPEROI RPEfac RPEcof RPEf RPEc dfDiff rawDiff RPEfacDat RPEcofDat RPEDATA
global RPEgroups IMGSdf RPEinfo RPEMASK RPEMASKNEW
global RPEDATANEW RPEROINEW RPEfacDatNEW RPEcofDatNEW RPEinfoNEW
global BlurVal zcrit zout


RPEDATA = {};
RPEinfo.file = GRINstruct.file(1:end-4);

slideValYA = 0.15;
slideValYB = -0.15;
slideValXA = 100;
slideValXB = 0;
slideValIM = size(IMG,1);
CSUSvals = unique(GRINstruct.csus);
RPEfac = '1';
RPEcof = '1';
BlurVal = .14;
zcrit = 5;
zout = 9;

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
graphguih = figure('Units', 'normalized','Position', [.02 .1 .85 .65], 'BusyAction',...
    'cancel', 'Name', 'graphguih', 'Tag', 'graphguih','MenuBar', 'none'); 


%----------------------------------------------------
%%     LEFT PANE MAIN PLOT WINDOW
%----------------------------------------------------

% LhaxGRIN = axes('Parent', graphguih, 'NextPlot', 'replacechildren',...
%     'Position', [0.05 0.08 0.55 0.85],'Color','none','XTick',[],'YTick',[],...
%     'XColor','none','YColor','none'); hold on;

GhaxGRIN = axes('Parent', graphguih, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.08 0.55 0.85],...
    'XLimMode', 'manual','YLimMode', 'manual','Color','none');
    GhaxGRIN.YLim = [-.15 .15];
    GhaxGRIN.XLim = [1 100];


GimgsliderYAH = uicontrol('Parent', graphguih, 'Units', 'normalized','Style','slider',...
	'Max',1,'Min',0,'Value',.15,'SliderStep',[0.01 0.10],...
	'Position', [-.01 0.62 0.03 0.30], 'Callback', @GimgsliderYA);

GimgsliderYBH = uicontrol('Parent', graphguih, 'Units', 'normalized','Style','slider',...
	'Max',0,'Min',-1,'Value',-.15,'SliderStep',[0.01 0.10],...
	'Position', [-.01 0.08 0.03 0.30], 'Callback', @GimgsliderYB);

GimgsliderXAH = uicontrol('Parent', graphguih, 'Units', 'normalized','Style','slider',...
	'Max',200,'Min',0,'Value',100,'SliderStep',[0.01 0.10],...
	'Position', [0.40 0.01 0.20 0.03], 'Callback', @GimgsliderXA);

GimgsliderXBH = uicontrol('Parent', graphguih, 'Units', 'normalized','Style','slider',...
	'Max',200,'Min',0,'Value',1,'SliderStep',[0.01 0.10],...
	'Position', [0.05 0.01 0.20 0.03], 'Callback', @GimgsliderXB);













%----------------------------------------------------
%%     RIGHT PANE FIGURE PANELS
%----------------------------------------------------

tabgp = uitabgroup(graphguih,'Position',[0.61 0.02 0.38 0.95]);
btabs = uitab(tabgp,'Title','Options');
dtabs = uitab(tabgp,'Title','Data');
itabs = uitab(tabgp,'Title','ROI');
gtabs = uitab(tabgp,'Title','Image');







%----------------------------------------------------
%%     IMAGE TAB
%----------------------------------------------------

IMpanel = uipanel('Parent', gtabs,'Title','Image Previews','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],'Position', [0.01 0.01 0.98 0.98]);


haxRPE = axes('Parent', IMpanel, ...
    'Position', [0.01 0.01 0.98 0.85], 'Color','none','XLimMode', 'manual','YLimMode', 'manual',...
    'YDir','reverse','XColor','none','YColor','none','XTick',[],'YTick',[]); 
    haxRPE.YLim = [0 IMsz(1)];
    haxRPE.XLim = [0 IMsz(2)];
    hold on
    % 'NextPlot', 'replacechildren',
    
    
phIM = imagesc(IMGSraw(:,:,1,1) , 'Parent',haxRPE);

haxRPE.Title = text(0.5,0.5,'IMG Stack');


%----------------------------------------------------
%%     OPTIONS TAB
%----------------------------------------------------



%-----------------------------------
%    FIND RPE PANEL
%-----------------------------------
GIPpanelH = uipanel('Parent', btabs,'Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.02 0.02 0.45 0.95]); % 'Visible', 'Off',

findRPEcallbackH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.90 .90 .09], 'FontSize', 13, 'String', 'FIND RPE',...
    'Callback', @findRPEcallback, 'Enable','on');



buttongroup1 = uibuttongroup('Parent', GIPpanelH,'Title','RPE FACTOR',...
                  'Units', 'normalized','Position',[.01 0.45 .98 .40],...
                  'SelectionChangedFcn',@buttongroup1selection);
              
bva = 1;

if size(CSUSvals,1) > 0
    fac1 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.86 .90 .10],......
        'String',CSUSvals(1),'HandleVisibility','off');
end
if size(CSUSvals,1) > 1
    fac2 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.72 .90 .10],......
        'String',CSUSvals(2),'HandleVisibility','off');
end
if size(CSUSvals,1) > 2
    fac3 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.58 .90 .10],......
        'String',CSUSvals(3),'HandleVisibility','off');
end
if size(CSUSvals,1) > 3
    fac4 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.44 .90 .10],......
        'String',CSUSvals(4),'HandleVisibility','off');
end
if size(CSUSvals,1) > 4 
    fac5 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.30 .90 .10],......
        'String',CSUSvals(5),'HandleVisibility','off');
end
if size(CSUSvals,1) > 5
    fac6 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.16 .90 .10],......
        'String',CSUSvals(6),'HandleVisibility','off');
end
if size(CSUSvals,1) > 6
    fac7 = uicontrol(buttongroup1,'Style','radiobutton','Units', 'normalized','Position',[.05 0.02 .90 .10],......
        'String',CSUSvals(7),'HandleVisibility','off');
end





buttongroup2 = uibuttongroup('Parent', GIPpanelH,'Title','RPE COFACTOR',...
                  'Units', 'normalized','Position',[.01 0.01 .98 .40],...
                  'SelectionChangedFcn',@buttongroup2selection);
              
bva = 1;

if size(CSUSvals,1) > 0
    cofac1 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.86 .90 .10],......
        'String',CSUSvals(1),'HandleVisibility','off');
end
if size(CSUSvals,1) > 1
    cofac2 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.72 .90 .10],......
        'String',CSUSvals(2),'HandleVisibility','off');
end
if size(CSUSvals,1) > 2
    cofac3 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.58 .90 .10],......
        'String',CSUSvals(3),'HandleVisibility','off');
end
if size(CSUSvals,1) > 3
    cofac4 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.44 .90 .10],......
        'String',CSUSvals(4),'HandleVisibility','off');
end
if size(CSUSvals,1) > 4 
    cofac5 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.30 .90 .10],......
        'String',CSUSvals(5),'HandleVisibility','off');
end
if size(CSUSvals,1) > 5
    cofac6 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.16 .90 .10],......
        'String',CSUSvals(6),'HandleVisibility','off');
end
if size(CSUSvals,1) > 6
    cofac7 = uicontrol(buttongroup2,'Style','radiobutton','Units', 'normalized','Position',[.05 0.02 .90 .10],......
        'String',CSUSvals(7),'HandleVisibility','off');
end


RPEfac = CSUSvals(1);
RPEcof = CSUSvals(2);








function buttongroup1selection(source,callbackdata)
    display('------------------');
    display(['Previous RPE factor: ' callbackdata.OldValue.String]);
    display(['Current RPE factor: ' callbackdata.NewValue.String]);
    display('------------------');

    RPEfac = callbackdata.NewValue.String;
end


function buttongroup2selection(source,callbackdata)
    display('------------------');
    display(['Previous RPE cofactor: ' callbackdata.OldValue.String]);
    display(['Current RPE cofactor: ' callbackdata.NewValue.String]);
    display('------------------');

    RPEcof = callbackdata.NewValue.String;
end

          
%-----------------------------------
%    CUSTOM FUNCTIONS PANEL
%-----------------------------------
GcustomfunpanelH = uipanel('Parent', btabs,'Title','Custom Code & Data Exploration','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.64 0.45 0.34]); % 'Visible', 'Off',
              
GrunCustomAH = uicontrol('Parent', GcustomfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.73 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function A',...
    'Callback', @GrunCustomA, 'Enable','off');

GrunCustomBH = uicontrol('Parent', GcustomfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.50 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function B',...
    'Callback', @GrunCustomB, 'Enable','off');

GrunCustomCH = uicontrol('Parent', GcustomfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.26 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function C',...
    'Callback', @GrunCustomC, 'Enable','off');

GrunCustomDH = uicontrol('Parent', GcustomfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function D',...
    'Callback', @GrunCustomD, 'Enable','off');





%-----------------------------------
%    PLOT DISPLAY CHECKLIST PANEL
%-----------------------------------
DisplaypanelH = uipanel('Parent', btabs,'Title','Display on Line Graph','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.25 0.45 0.34]); % 'Visible', 'Off',



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
    'Callback', {@loadROIs,RPEDATA});



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


%------------------------------------------------------------------------------
%%        GUI HELPER FUNCTIONS
%------------------------------------------------------------------------------





% SLIDER CALLBACK FUNCTIONS
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




% IMAGE SIDER CALLBACK
function IMGslider(hObject, eventdata)

    slideVal = ceil(IMGsliderH.Value);

    hIMG = imagesc(IM(:,:,slideVal) , 'Parent', haxIMG);
              pause(.01)

    % disp(['image: ' num2str(slideVal) ' (' num2str(IMGsliderH.Value) ')'])
    disp(['image: ' num2str(slideVal) ' (' num2str(IMGsliderH.Value) ')'])

end

% IMAGE AXES SIZE CALLBACK
function AXslider(hObject, eventdata)

    slideValIM = AXsliderH.Value;
    
    axis(haxIMG,[.5 slideValIM+.5 .5 slideValIM+.5]);
    
    % haxIMG.XLim = [0 slideValIM];
    % haxIMG.YLim = [0 slideValIM];
    
    disp(['XLim: ' num2str(haxIMG.XLim) ' YLim: ' num2str(haxIMG.YLim)])
    
end



%----------------------------------------------------
%        UPDATE GRAPH CALLBACK
%----------------------------------------------------
%{
function GupdateGraph(boxidselecth, eventdata)

    return

    if Gcheckbox1H.Value
        smoothimg
    end
    
    if Gcheckbox2H.Value
        cropimg
    end
    
    if Gcheckbox3H.Value
        imgblocks
    end

    if Gcheckbox4H.Value
        reshapeData
    end

    if Gcheckbox5H.Value
        alignCSframes
    end

    if Gcheckbox6H.Value
        dFoverF
    end

    if Gcheckbox7H.Value
        timepointMeans
    end

     
end
%}



%----------------------------------------------------
%%     DATA VIEW PANEL
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

    disp('UPDATING ROI...')
    
    
    
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





%------------------------------------------------------------------------------
%        PLOT LICKING DATA
%------------------------------------------------------------------------------
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





















%------------------------------------------------------------------------------
%        FIND RPE FUNCTION
%------------------------------------------------------------------------------
function findRPEcallback(hObject, eventdata)

    
tabgp.SelectedTab = tabgp.Children(4);
pause(1)


%-----------------------------------------
% phIM.CData = IMGraw;
% phIM = imagesc(IMGraw,'Parent',haxRPE,'CDataMapping','scaled');
% cmax = max(max(max(IMGSrawMean)));
% cmin = min(min(min(IMGSrawMean)));
% haxRPE.CLim = [cmin cmax];
%-----------------------------------------
% haxRPE.Title = text(0.5,0.5,sprintf('Preparing ROI Trace %.0f ',1));




% haxRPE.Title = text(0.5,0.5,sprintf('Mean of Original Stack'));
% phIM.CData = squeeze(mean(squeeze(mean(IMGSraw,4)),3));
% pause(1)



haxRPE.Title = text(0.5,0.5,sprintf('Mean of Current IMG Stack'));
phIM.CData = squeeze(mean(squeeze(mean(IMG,4)),3));

pause(1)




IMGSrawMean = squeeze(mean(IMGSraw,4));
%-----------------------------------------
% phIM.CData = IMGraw;
phIM = imagesc(IMGSrawMean(:,:,1),'Parent',haxRPE,'CDataMapping','scaled');
cmax = max(max(max(IMGSrawMean)));
cmin = min(min(min(IMGSrawMean)));
cmax = cmax - abs(cmax/5);
cmin = cmin + abs(cmin/5);
haxRPE.CLim = [cmin cmax];
%-----------------------------------------

phIM = imagesc(IMGSrawMean(:,:,1),'Parent',haxRPE);

for nn = 1:size(IMGSrawMean,3)
    
    phIM.CData = IMGSrawMean(:,:,nn);
    haxRPE.Title = text(0.5,0.5,sprintf('Mean of Original Stack  FRAME(%.0f) ',nn));
    pause(.04)
    
end












% GET FRAME FOR CS_ONSET CS_MIDWAY US_ONSET US_MIDWAY
Fcson   = XLSdata.CSonsetFrame;
Fcsmid  = Fcson + round(XLSdata.CS_lengthFrames/2);
Fcsoff  = XLSdata.CSoffsetFrame;
Fusmid  = Fcsoff + round((XLSdata.framesPerTrial - Fcsoff)/2);
Fusend  = XLSdata.framesPerTrial;



% GET TREATMENT GROUP STRINGS
clear fid
for nn = 1:size(GRINstruct.tf,2)
    fid(nn) = find(GRINstruct.id==nn,1); 
end
TreatmentGroup = GRINstruct.csus(fid);





for nn = 1:size(GRINstruct.tf,2)
    RFac(nn) = strcmp(TreatmentGroup{nn},RPEfac);
    RCof(nn) = strcmp(TreatmentGroup{nn},RPEcof);
end

RPEf = find(RFac);
RPEc = find(RCof);






haxRPE.Title = text(0.5,0.5,sprintf('Making stack of: [%s] - [%s] ',...
    TreatmentGroup{RPEf},TreatmentGroup{RPEc}));


for nn = 1:size(GRINstruct.tf,2)

    IMGSdf(:,:,:,nn) = squeeze(mean(IMG(:,:,:,GRINstruct.tf(:,nn)),4));
        
end


% THE SIZE OF IMGSraw and IMGSdf is now ( nYpixels , nXpixels , nFRAMES , nGroups )
% NOTE THIS DOES *NOT* MEAN ( nYpixels , nXpixels , nFRAMES , *nTRIALS* )
%
% dfDiff  = IMG(factor)    -   IMG(cofactor)
% rawDiff = IMGraw(factor) -   IMGraw(cofactor)



rawDiff = IMGSraw(:,:,:,RPEf) - IMGSraw(:,:,:,RPEc);
dfDiff = IMGSdf(:,:,:,RPEf) - IMGSdf(:,:,:,RPEc);
    









%-----------------------------------------
phIM = imagesc(rawDiff(:,:,1),'Parent',haxRPE,'CDataMapping','scaled');
cmax = max(max(max(rawDiff)));
cmin = min(min(min(rawDiff)));
cmax = cmax - abs(cmax/1.5);
cmin = cmin + abs(cmin/1.5);
haxRPE.CLim = [cmin cmax];
%----
for nn = 1:size(rawDiff,3)
    
    phIM.CData = rawDiff(:,:,nn);
    
    haxRPE.Title = text(0.5,0.5,sprintf('[%s] - [%s]    rawDiff(%.0f)',...
    TreatmentGroup{RPEf},TreatmentGroup{RPEc}, nn));
    
    pause(.04)
end
%-----------------------------------------





%-----------------------------------------
phIM = imagesc(dfDiff(:,:,1),'Parent',haxRPE,'CDataMapping','scaled');
cmax = max(max(max(dfDiff)));
cmin = min(min(min(dfDiff)));
cmax = cmax - abs(cmax/1.5);
cmin = cmin + abs(cmin/1.5);
haxRPE.CLim = [cmin cmax];
%----
for nn = 1:size(dfDiff,3)
    
    phIM.CData = dfDiff(:,:,nn);
        
    haxRPE.Title = text(0.5,0.5,sprintf('[%s] - [%s]    dfDiff(%.0f)',...
    TreatmentGroup{RPEf},TreatmentGroup{RPEc}, nn));
    
    pause(.04)
     
end
%-----------------------------------------





%% GET Z-SCORE DATA FOR RAW AND DF STACKS


clear USFHa USFH_Zscore USFHzcrit USFHzout USFH
% haxRPE.Title = text(0.5,0.5,sprintf('Preparing ROI Trace %.0f ',1));


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
haxRPE.CLim = [cmin cmax];

phIM = imagesc(BW_filled,'Parent',haxRPE,'CDataMapping','scaled');
pause(1)
%-----------------------------------------


%-----------------------------------------
cmax = max(max(max(dfDiff)));
cmin = min(min(min(dfDiff)));
cmax = cmax - abs(cmax/1.2);
cmin = cmin + abs(cmin/1.2);
haxRPE.CLim = [cmin cmax];

phIM = imagesc(dfDiff(:,:,1),'Parent',haxRPE,'CDataMapping','scaled');
pause(1)
%-----------------------------------------


[B,L] = bwboundaries(BW,'noholes');

clear TooSmall
for mm = 1:size(B,1)

    TooSmall(mm) = length(B{mm}) < 15;

end


B(TooSmall) = [];
RPEROI = B;
RPEMASK = BW_filled;

haxRPE.Title = text(0.5,0.5,sprintf('Found %.0f ROIs that past tests',length(B)));

for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1),'Parent',haxRPE, 'Color', colorlist(1,:) , 'LineWidth', 2)
    pause(.04)
end



phIM.CData = dfDiff(:,:,1);
haxRPE.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'BASELINE'));
pause(.5)

for m = 1:size(rawDiff,3)
    
    phIM.CData = dfDiff(:,:,m);
    
    if m == Fcson
    haxRPE.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',Fcson,'CS ON'));
    elseif m == Fcsoff
    haxRPE.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',Fcsoff,'CS OFF'));
    % elseif m == Fcsoff
    % haxRPE.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'US ON'));
    % elseif m == Fusend
    % haxRPE.Title=text(.5,.5,sprintf('FRAME: %.0f  [%s]',0,'US OFF'));
    end
    
    pause(.04)
end




%-----------------------------------------
cmax = max(max(max(mean(dfDiff(:,:,Fcsoff:Fusmid),3))));
cmin = min(min(min(mean(dfDiff(:,:,Fcsoff:Fusmid),3))));
cmax = cmax - abs(cmax/2);
cmin = cmin + abs(cmin/2);
haxRPE.CLim = [cmin cmax];

phIM.CData = mean(dfDiff(:,:,Fcsoff:Fusmid),3);

haxRPE.Title = text(0.5,0.5,...
    sprintf('Displaying mean difference after %.0f frame',Fcsoff));
%-----------------------------------------







%% GET DATA FOR RPE LINE PLOTS


for v = 1:size(dfDiff,3)

    dfRPE(:,:,v) = IMGSdf(:,:,v,RPEf) .* BW_filled;
    % dfRPE(:,:,nn) = dfDiff(:,:,nn) .* BW_filled;
    dRPE = dfRPE(:,:,v);
    dRPE = dRPE(:);
    RPEfacDat(v) = mean(dRPE(dRPE>0));

end

for v = 1:size(dfDiff,3)

    dfRPE(:,:,v) = IMGSdf(:,:,v,RPEc) .* BW_filled;
    % dfRPE(:,:,v) = dfDiff(:,:,v) .* BW_filled;
    dRPE = dfRPE(:,:,v);
    dRPE = dRPE(:);
    RPEcofDat(v) = mean(dRPE(dRPE>0));

end




%% PLOT RPE LINE PLOTS IN MAIN AXES

delete(findobj(GhaxGRIN.Children))

haxRPE.Title = text(0.5,0.5,sprintf('Found %.0f RPE ROIs',length(RPEROI)));
GhaxGRIN.ColorOrderIndex = 1;

phMainData = plot([RPEfacDat; RPEcofDat]','Parent',GhaxGRIN, 'LineWidth',2);



GhaxGRIN.ColorOrderIndex = 1; 
hmkrs = plot(GhaxGRIN, [RPEfacDat; RPEcofDat]', 'LineStyle', 'none',...
                    'Marker', '.','MarkerSize',45);
                

leg1 = legend(hmkrs,{TreatmentGroup{RPEf},TreatmentGroup{RPEc}});
set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
set(hmkrs,'Visible','off','HandleVisibility', 'off')                


if cmax > .1;
    GhaxGRIN.YLim = [0 cmax];
else
    GhaxGRIN.YLim = [0 .1];
end






%% PREPARE RPE DATA FOR OUTPUT TO MAT FILE

RPEinfo.RPEf = RPEf;
RPEinfo.RPEc = RPEc;
RPEinfo.TreatmentGroup = TreatmentGroup;
RPEinfo.Fcson  = Fcson;
RPEinfo.Fcsmid = Fcsmid;
RPEinfo.Fcsoff = Fcsoff;
RPEinfo.Fusmid = Fusmid;
RPEinfo.Fusend = Fusend;


%%
end






%-----------------------------------------------
%        MASK KERNEL FUNCTION FOR FIND RPE
%-----------------------------------------------
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

disp('SMOOTHING KERNEL PARAMETERS:')
fprintf('  SIZE OF MASK:   % s x % s \n', num2str(GNnum), num2str(GNnum));
fprintf('  STDEV OF SLOPE: % s \n', num2str(GNsd));
fprintf('  HIGHT OF PEAK:  % s \n', num2str(GNpk));
fprintf('  RESOLUTION:     % s \n\n', num2str(GNres));

end








%------------------------------------------------------------------------------
%        FIND RPE FUNCTION
%------------------------------------------------------------------------------
function plotRPEloaded(RPEDATANEW, RPEMASKNEW, RPEROINEW, RPEfacDatNEW, RPEcofDatNEW, RPEinfoNEW)


tabgp.SelectedTab = tabgp.Children(4);
pause(1)
    
colorlist = [.99 .00 .00; .00 .99 .00; .99 .88 .88; .11 .77 .77;
         .77 .77 .11; .77 .11 .77; .00 .00 .99; .22 .33 .44];    
     
     
RPEf = RPEinfoNEW.RPEf;
RPEc = RPEinfoNEW.RPEc;
TreatmentGroup = RPEinfoNEW.TreatmentGroup;
Fcson  = RPEinfoNEW.Fcson;
Fcsmid = RPEinfoNEW.Fcsmid;
Fcsoff = RPEinfoNEW.Fcsoff;
Fusmid = RPEinfoNEW.Fusmid;
Fusend = RPEinfoNEW.Fusend;     
    

for k = 1:length(RPEROINEW)
    boundary = RPEROINEW{k};
    plot(boundary(:,2), boundary(:,1),'Parent',haxRPE, 'Color', colorlist(2,:) , 'LineWidth', 2)
end


for m = 1:size(dfDiff,3)
    phIM.CData = dfDiff(:,:,m);
    %if m == Fcsoff; haxRPE.CData = on; end
    pause(.07)
end



%-----------------------------------------
% phIM.CData = IMGraw;
% phIM = imagesc(IMGraw,'Parent',haxRPE,'CDataMapping','scaled');
cmax = max(max(max(mean(dfDiff(:,:,Fcsoff:Fusmid),3))));
cmin = min(min(min(mean(dfDiff(:,:,Fcsoff:Fusmid),3))));
cmax = cmax - abs(cmax/2);
cmin = cmin + abs(cmin/2);
haxRPE.CLim = [cmin cmax];
%-----------------------------------------

phIM.CData = mean(dfDiff(:,:,Fcsoff:Fusmid),3);

for nn = 1:size(dfDiff,3)

    dfRPE(:,:,nn) = IMGSdf(:,:,nn,RPEf) .* RPEMASKNEW;
%     dfRPE(:,:,nn) = IMGSdf(:,:,nn,RPEf) .* BW_filled;
    dRPE = dfRPE(:,:,nn);
    dRPE = dRPE(:);
    RPEfacDatNEW(nn) = mean(dRPE(dRPE>0));

end

for nn = 1:size(dfDiff,3)

    dfRPE(:,:,nn) = IMGSdf(:,:,nn,RPEc) .* RPEMASKNEW;
%     dfRPE(:,:,nn) = IMGSdf(:,:,nn,RPEc) .* BW_filled;
    dRPE = dfRPE(:,:,nn);
    dRPE = dRPE(:);
    RPEcofDatNEW(nn) = mean(dRPE(dRPE>0));

end



cmax = max(max(max([RPEfacDatNEW; RPEcofDatNEW])));
cmin = min(min(min([RPEfacDatNEW; RPEcofDatNEW])));
cmax = cmax - abs(cmax/5);
cmin = cmin + abs(cmin/5);

delete(findobj(GhaxGRIN.Children))

RPEgroups = {TreatmentGroup{RPEf},TreatmentGroup{RPEc}};

phMainData = plot([RPEfacDatNEW; RPEcofDatNEW]','Parent',GhaxGRIN, 'LineWidth',2);
legend(GhaxGRIN,{TreatmentGroup{RPEf},TreatmentGroup{RPEc}})

if cmax > .1
    GhaxGRIN.YLim = [0 cmax];
else
    GhaxGRIN.YLim = [0 .1];
end


%%
end










%%
%------------------------------------------------------------------------------
%        DATA IO SAVE LOAD
%------------------------------------------------------------------------------


function exportROIs(varargin)
    
    checkLabels = {'Save RPEROI to variable named:' ...
                   'Save RPEMASK to variable named:' ...
                   'Save RPEfacDat to variable named:' ...
                   'Save RPEcofDat to variable named:' ...
                   'Save RPEinfo to variable named:'}; 
    varNames = {'RPEROI','RPEMASK','RPEfacDat','RPEcofDat','RPEinfo'}; 
    items = {RPEROI,RPEMASK,RPEfacDat,RPEcofDat,RPEinfo};
    export2wsdlg(checkLabels,varNames,items,...
                 'Save Variables to Workspace');
    
end


function saveROIs(varargin)
    
    % [file,path] = uiputfile('*.mat','Save ROIs As');
    
    RPEinfo.RPEgroups = RPEgroups;
    
    uisave({'RPEROI','RPEMASK','RPEfacDat','RPEcofDat','RPEinfo'},[RPEinfo.file 'RPEDATA']);
    
end

function RPEDATA = loadROIs(hObject, eventdata, RPEDATA)
    
    [filename, pathname, filterindex] = uigetfile( ...
        {'*.mat','MAT-files (*.mat)'}, ...
        'Pick a file', ...
        'MultiSelect', 'on');

    % uiopen('.mat')
    
    
    
    RPEDATA = load([pathname,filename]);
    
    [RPEROINEW] = deal(RPEDATA.RPEROI);
    [RPEMASKNEW] = deal(RPEDATA.RPEMASK);
    [RPEfacDatNEW] = deal(RPEDATA.RPEfacDat);
    [RPEcofDatNEW] = deal(RPEDATA.RPEcofDat);
    [RPEinfoNEW] = deal(RPEDATA.RPEinfo);
    
    
    plotRPEloaded(RPEDATANEW, RPEMASKNEW, RPEROINEW, RPEfacDatNEW, RPEcofDatNEW, RPEinfoNEW)
    
%     RPEDATA = {RPEROI , RPEfacDat , RPEcofDat};
    
end













%%
end