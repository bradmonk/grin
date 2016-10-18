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
global IM colorord

slideValYA = 0.15;
slideValYB = -0.15;
slideValXA = 100;
slideValXB = 0;
slideValIM = size(IMG,1);
CSUSvals = unique(GRINstruct.csus);

% MATLAB Default Color Order
colorord = [0.0000    0.4470    0.7410
            0.8500    0.3250    0.0980
            0.9290    0.6940    0.1250
            0.4940    0.1840    0.5560
            0.4660    0.6740    0.1880
            0.3010    0.7450    0.9330
            0.6350    0.0780    0.1840];

IM = squeeze(IMGSraw(:,:,:,1));


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
btabs = uitab(tabgp,'Title','Graphics Options');
dtabs = uitab(tabgp,'Title','Data View');
itabs = uitab(tabgp,'Title','Image View');



%----------------------------------------------------
%%     GRAPHICS OPTIONS PANEL
%----------------------------------------------------

GIPpanelH = uipanel('Parent', btabs,'Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.02 0.25 0.45 0.73]); % 'Visible', 'Off',

findRPEcallbackH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.88 .90 .10], 'FontSize', 13, 'String', 'FIND RPE',...
    'Callback', @findRPEcallback, 'Enable','on');

% plotLickDataH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
%     'Position', [.05 0.88 .90 .10], 'FontSize', 13, 'String', 'Plot Lick Data',...
%     'Callback', @plotLickData, 'Enable','on');

chva = 1;

if size(CSUSvals,1) > 0
Gcheckbox1H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.71 .90 .05] ,'String',CSUSvals(1), 'Value',1,'Callback',{@plot_callback,1});
end
if size(CSUSvals,1) > 1
Gcheckbox2H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.61 .90 .05] ,'String',CSUSvals(2), 'Value',chva,'Callback',{@plot_callback,2});
end
if size(CSUSvals,1) > 2
Gcheckbox3H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.51 .90 .05] ,'String',CSUSvals(3), 'Value',chva,'Callback',{@plot_callback,3});
end
if size(CSUSvals,1) > 3
Gcheckbox4H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.41 .90 .05] ,'String',CSUSvals(4), 'Value',chva,'Callback',{@plot_callback,4});
end
if size(CSUSvals,1) > 4 
Gcheckbox5H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.31 .90 .05] ,'String',CSUSvals(5), 'Value',chva,'Callback',{@plot_callback,5});
end
if size(CSUSvals,1) > 5
Gcheckbox6H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.21 .90 .05] ,'String',CSUSvals(6), 'Value',chva,'Callback',{@plot_callback,6});
end
if size(CSUSvals,1) > 6
Gcheckbox7H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.11 .90 .05] ,'String',CSUSvals(7), 'Value',chva,'Callback',{@plot_callback,7});
end



% GCSUSpopupH = uicontrol('Parent', GIPpanelH,'Style', 'popup',...
%     'Units', 'normalized', 'String', {'CS','US'},...
%     'Position', [.05 .02 0.9 0.05],...
%     'Callback', @GCSUSpopup);

          
%----------------------------------------------------
%    CUSTOM FUNCTIONS PANEL
%----------------------------------------------------
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





%----------------------------------------------------
%    DATA EXPLORATION & API PANEL
%----------------------------------------------------
GexplorepanelH = uipanel('Parent', btabs,'Title','Data Exploration & API','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.25 0.45 0.34]); % 'Visible', 'Off',
              
GopenImageJH = uicontrol('Parent', GexplorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.73 0.95 0.20], 'FontSize', 13, 'String', 'Open stack in ImageJ ',...
    'Callback', @GopenImageJ, 'Enable','off');

GexploreAH = uicontrol('Parent', GexplorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.50 0.95 0.20], 'FontSize', 13, 'String', 'Explore Data A',...
    'Callback', @GexploreA, 'Enable','off');

GexploreBH = uicontrol('Parent', GexplorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.26 0.95 0.20], 'FontSize', 13, 'String', 'Explore Data B',...
    'Callback', @GexploreB, 'Enable','off');

GresetwsH = uicontrol('Parent', GexplorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.20], 'FontSize', 13, 'String', 'Reset Toolbox',...
    'Callback', @Gresetws);



%----------------------------------------------------
%    SAVE AND EXPORT DATA
%----------------------------------------------------
GexportpanelH = uipanel('Parent', btabs,'Title','I/O','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.02 0.45 0.20]); % 'Visible', 'Off',
              
GexportvarsH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.65 0.95 0.28], 'FontSize', 13, 'String', 'Export Vars to Workspace ',...
    'Callback', @Gexportvars, 'Enable','off');

GsavedatasetH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.34 0.95 0.28], 'FontSize', 13, 'String', 'Save Dataset',...
    'Callback', @Gsavedataset, 'Enable','off');

GloadmatdataH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.28], 'FontSize', 13, 'String', 'Load .mat Dataset',...
    'Callback', @Gloadmatdata, 'Enable','off');





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


bg = uibuttongroup('Parent', IMGpanelH,'Visible','off','Units', 'normalized',...
                  'Position',[0.31 0.86 0.60 0.13],...
                  'SelectionChangedFcn',@bselection);
              
% Create three radio buttons in the button group.
if size(CSUSvals,1) > 0
CSUSr1 = uicontrol(bg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(1),...
                  'Position',[.01 .52 .32 .45],...
                  'BackgroundColor',colorord(1,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 1
CSUSr2 = uicontrol(bg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(2),...
                  'Position',[.34 .52 .32 .45],...
                  'BackgroundColor',colorord(2,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 2
CSUSr3 = uicontrol(bg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(3),...
                  'Position',[.67 .52 .32 .45],...
                  'BackgroundColor',colorord(3,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 3
CSUSr4 = uicontrol(bg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(4),...
                  'Position',[.01 .01 .32 .45],...
                  'BackgroundColor',colorord(4,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 4              
CSUSr5 = uicontrol(bg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(5),...
                  'Position',[.34 .01 .32 .45],...
                  'BackgroundColor',colorord(5,:),...
                  'HandleVisibility','off');
end
if size(CSUSvals,1) > 5
CSUSr6 = uicontrol(bg,'Style','radiobutton','Units', 'normalized',...
                  'String',CSUSvals(6),...
                  'Position',[.67 .01 .32 .45],...
                  'BackgroundColor',colorord(6,:),...
                  'HandleVisibility','off');
end              
 
% Make the uibuttongroup visible after creating child objects. 
bg.Visible = 'on';



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


fh0=figure('Units','normalized','OuterPosition',[.02 .1 .85 .6],'Color','w','MenuBar','none');

subplot(1,2,1);
imagesc(squeeze(mean(squeeze(mean(IMG,4)),3)))
axis image;  pause(.1)
axis normal; pause(.1)

subplot(1,2,2);
imagesc(squeeze(mean(squeeze(mean(IMGSraw,4)),3)))
axis image;  pause(.1)
axis normal; pause(.1)


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
    whitenoisenoshock(nn) = strcmp(TreatmentGroup{nn},'white noise no shock');
    whitenoiseshock(nn) = strcmp(TreatmentGroup{nn},'white noise shock');
    tonesucrose(nn) = strcmp(TreatmentGroup{nn},'tone sucrose');
    tonenosucrose(nn) = strcmp(TreatmentGroup{nn},'tone no sucrose');
    whitenoisesucrose(nn) = strcmp(TreatmentGroup{nn},'white noise sucrose');
    whitenoisenosucrose(nn) = strcmp(TreatmentGroup{nn},'white noise no sucrose');
end



BaselineFrames = [];
Baseline = [];
Baseline_meanAcrossTrials = {};
Baseline_mean = [];
BaselineMeanPerTrial = [];
Baseline_TrialsMean = [];

for nn = 1:size(GRINstruct.tf,2)

    IMGSdf(:,:,:,nn) = squeeze(mean(IMG(:,:,:,GRINstruct.tf(:,nn)),4));
    % IMGSdf is the same as IMGSraw but for dF/F instead of raw: [220   220   100  3]
        
end

% if any(whitenoisenoshock) && any(whitenoiseshock)
% 
%     IDwhitenoisenoshock = find(whitenoisenoshock);
%     IDwhitenoiseshock = find(whitenoiseshock);
%         
%     SignalDiff = IMGSraw(:,:,:,IDwhitenoisenoshock) - IMGSraw(:,:,:,IDwhitenoiseshock);
% 
% end


if (any(tonesucrose) && any(tonenosucrose)) || (any(whitenoisesucrose) && any(whitenoisenosucrose))
    
    if (any(tonesucrose) && any(tonenosucrose))
        IDtonenosucrose = find(tonenosucrose);
        IDtonesucrose = find(tonesucrose);
    end
    if (any(whitenoisesucrose) && any(whitenoisenosucrose))
        IDtonenosucrose = find(whitenoisenosucrose);
        IDtonesucrose = find(whitenoisesucrose);
    end
    
    
    rawDiff = IMGSraw(:,:,:,IDtonenosucrose) - IMGSraw(:,:,:,IDtonesucrose);
    
    dfDiff = IMGSdf(:,:,:,IDtonenosucrose) - IMGSdf(:,:,:,IDtonesucrose);
    
    
    % rawDiff = IMGSraw(:,:,:,IDtonesucrose) - IMGSraw(:,:,:,IDtonenosucrose);
    
    % dfDiff = IMGSdf(:,:,:,IDtonesucrose) - IMGSdf(:,:,:,IDtonenosucrose);
    
end



fh1=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
hax1 = axes('Position',[.001 .001 .999 .999],'Color','none'); 
title(['Examining X. (ID: ', GRINstruct.file ')'])
hold on;

axes(hax1)
ph1 = imagesc(IMGraw,'Parent',hax1,'CDataMapping','scaled');
axis image;  pause(.1)
axis normal; pause(.1)

IMGSrawMean = squeeze(mean(IMGSraw,4));
for nn = 1:size(IMGSrawMean,3)    
    ph1.CData = IMGSrawMean(:,:,nn);
    pause(.05)
end

for nn = 1:size(rawDiff,3)    
    ph1.CData = rawDiff(:,:,nn);
    pause(.05)
end

for nn = 1:size(dfDiff,3)    
    ph1.CData = dfDiff(:,:,nn);
    pause(.05)
end



Mask = GRINkernel(.8, 9, .14, .1, 1);



clear USFHa USFH_Zscore USFHzcrit USFHzout USFHz ZrawDiff

USFH = mean(rawDiff(:,:,Fcsoff:Fusmid),3);
IMGc = convn( USFH, Mask,'same');
% IMGc = USFH;

rda = reshape(rawDiff(:,:,Fcsoff:Fusmid),size(rawDiff,1),[],1);

USFHa = rda(:);
USFH_Zscore = zscore(USFHa);
USFHzcrit = min(USFHa(USFH_Zscore>5));
USFHzout = min(USFHa(USFH_Zscore>9));
USFHz = IMGc; if isempty(USFHzout); USFHzout = max(USFHa); end;
USFHz(USFHz<USFHzcrit | USFHz>USFHzout) = 0;
ZrawDiff = USFHz;



clear USFHa USFH_Zscore USFHzcrit USFHzout USFHz ZdfDiff

USFH = mean(dfDiff(:,:,Fcsoff:Fusmid),3);
IMGc = convn( USFH, Mask,'same');
% IMGc = USFH;

rda = reshape(dfDiff(:,:,Fcsoff:Fusmid),size(rawDiff,1),[],1);

USFHa = rda(:);
USFH_Zscore = zscore(USFHa);
USFHzcrit = min(USFHa(USFH_Zscore>5));
USFHzout = min(USFHa(USFH_Zscore>9));
USFHz = IMGc; if isempty(USFHzout); USFHzout = max(USFHa); end;
USFHz(USFHz<USFHzcrit | USFHz>USFHzout) = 0;
ZdfDiff = USFHz;


% clear USFHa USFH_Zscore USFHzcrit USFHzout USFHz ZrawDiff
% 
% USFH = mean(rawDiff(:,:,Fcsoff:Fusmid),3);
% IMGc = convn( USFH, Mask,'same');
% 
% USFHa = IMGc(:);
% USFH_Zscore = zscore(USFHa);
% USFHzcrit = min(USFHa(USFH_Zscore>1));
% USFHzout = min(USFHa(USFH_Zscore>4));
% USFHz = IMGc; if isempty(USFHzout); USFHzout = max(USFHa); end;
% USFHz(USFHz<USFHzcrit | USFHz>USFHzout) = 0;
% ZrawDiff = USFHz;


% clear USFHa USFH_Zscore USFHzcrit USFHzout USFHz ZdfDiff
% 
% USFH = mean(dfDiff(:,:,Fcsoff:Fusmid),3);
% IMGc = convn( USFH, Mask,'same');
% 
% USFHa = IMGc(:);
% USFH_Zscore = zscore(USFHa);
% USFHzcrit = min(USFHa(USFH_Zscore>1));
% USFHzout = min(USFHa(USFH_Zscore>4));
% USFHz = IMGc; if isempty(USFHzout); USFHzout = max(USFHa); end;
% USFHz(USFHz<USFHzcrit | USFHz>USFHzout) = 0;
% ZdfDiff = USFHz;


ZrawD = ZrawDiff > 0;

ZdfD = ZdfDiff > 0;




fh0=figure('Units','normalized','OuterPosition',[.02 .1 .85 .6],'Color','w','MenuBar','none');

subplot(1,2,1)
imagesc(ZrawD)
axis image;  pause(.1)
axis normal; pause(.1)

subplot(1,2,2)
imagesc(ZdfD)
axis image;  pause(.1)
axis normal; pause(.1)







colorlist = [.99 .00 .00; .00 .99 .00; .99 .88 .88; .11 .77 .77;
             .77 .77 .11; .77 .11 .77; .00 .00 .99; .22 .33 .44];


% BW = im2bw(ZdfD.*1.0, graythresh(ZdfD.*1.0));
BW = im2bw(ZdfDiff, graythresh(ZdfDiff));

BWc = convn( BW, Mask,'same');
BWc = convn( BWc, Mask,'same');

BW = im2bw(BWc, graythresh(BWc));

BW_filled = imfill(BW,'holes');



fh55=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
subplot(2,2,1)
imagesc(ZdfDiff)
subplot(2,2,2)
imagesc(BW)
subplot(2,2,3)
imagesc(BW)
subplot(2,2,4)
imagesc(BW_filled)

pause(2)






fh11=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
% title(['Examining X. (ID: ', GRINstruct.file ')'])

hax1 = axes('Position',[.001 .001 .999 .999],'Color','none'); 
hax1.XLim = [1 size(dfDiff,1)];
hax1.YLim = [1 size(dfDiff,1)];
hold on;

hax2 = axes('Position',[.001 .001 .999 .999],'Color','none'); 
hax2.XLim = [1 size(dfDiff,1)];
hax2.YLim = [1 size(dfDiff,1)];
hold on;

hax3 = axes('Position',[.001 .001 .1 .1],'Color','none'); 
hax1.XLim = [1 size(dfDiff,1)];
hax1.YLim = [1 size(dfDiff,1)];
axis off; hold on;
on = ones(size(dfDiff,1)); on(1) = 0;
off = zeros(size(dfDiff,1)); off(1) = 1;

axes(hax1)
ph1 = imagesc(dfDiff(:,:,1),'Parent',hax1,'CDataMapping','scaled');





[B,L] = bwboundaries(BW,'noholes');


clear TooSmall
for mm = 1:size(B,1)

    TooSmall(mm) = length(B{mm}) < 15;

end


B(TooSmall) = [];
axes(hax2)
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2), boundary(:,1), 'Color', colorlist(1,:) , 'LineWidth', 2)
end

axes(hax3)
ph3 = imagesc(off,'Parent',hax3);

for nn = 1:size(rawDiff,3)
    ph1.CData = dfDiff(:,:,nn);
    
    if nn == Fcsoff
        ph3.CData = on;
    end
    
    pause(.07)
end

ph1.CData = mean(dfDiff(:,:,Fcsoff:Fusmid),3);


%%



% IMGSraw(:,:,:,IDtonenosucrose)
% IMGSraw(:,:,:,IDtonesucrose)
% IMGSdf(:,:,:,IDtonenosucrose)
% IMGSdf(:,:,:,IDtonesucrose)
% 
% size(IMGSdf)
% size(IMGSdf(:,:,nn,IDtonenosucrose))


for nn = 1:size(dfDiff,3)

    dfRPE(:,:,nn) = IMGSdf(:,:,nn,IDtonenosucrose) .* BW_filled;
    % dfRPE(:,:,nn) = dfDiff(:,:,nn) .* BW_filled;
    dRPE = dfRPE(:,:,nn);
    dRPE = dRPE(:);
    tnsRPE(nn) = mean(dRPE(dRPE>0));

end

for nn = 1:size(dfDiff,3)

    dfRPE(:,:,nn) = IMGSdf(:,:,nn,IDtonesucrose) .* BW_filled;
    % dfRPE(:,:,nn) = dfDiff(:,:,nn) .* BW_filled;
    dRPE = dfRPE(:,:,nn);
    dRPE = dRPE(:);
    tsRPE(nn) = mean(dRPE(dRPE>0));

end


figure
plot([tnsRPE; tsRPE]')
legend({'tone no sucrose','tone sucrose'})


% fh1=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
% % title(['Examining X. (ID: ', GRINstruct.file ')'])
% 
% hax1 = axes('Position',[.001 .001 .999 .999],'Color','none'); 
% hax1.XLim = [1 size(dfRPE,1)];
% hax1.YLim = [1 size(dfRPE,1)];
% hold on;
% 
% axes(hax1)
% ph1 = imagesc(dfRPE(:,:,1),'Parent',hax1,'CDataMapping','scaled');
% 
% for nn = 1:size(rawDiff,3)
%     ph1.CData = dfRPE(:,:,nn);
%     pause(.1)
% end


% for nn = 1:size(GRINstruct.tf,2)
% 
% annotation(fh1,'textbox',...
% 'Position',legpos{nn},...
% 'Color',colorlist(nn,:),...
% 'FontWeight','bold',...
% 'String',TreatmentGroup(nn),...
% 'FontSize',14,...
% 'FitBoxToText','on',...
% 'EdgeColor',colorlist(nn,:),...
% 'FaceAlpha',.7,...
% 'Margin',3,...
% 'LineWidth',2,...
% 'VerticalAlignment','bottom',...
% 'BackgroundColor',[1 1 1]);
% 
% end

%%
end















































end
