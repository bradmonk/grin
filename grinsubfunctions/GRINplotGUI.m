function [] = GRINplotGUI()
% function [] = GRINplotGUI(IMG, GRINstruct, XLSdata, LICK, varargin)
%% GRINplotGUI.m



clc; close all; clear all; clear java;

global IMG GRINstruct XLSdata GRINtable LICK IMGraw

disp('Contents of workspace before loading file:'); whos

grinmat = '/Users/bradleymonk/Documents/MATLAB/myToolbox/LAB/grin/gcdata/gc33_031916g.mat';

disp('File contains the following vars:'); whos('-file',grinmat);

fprintf('Loading .mat file from... \n % s \n\n', grinmat); 
% if ~exist('IMG','var')
   
    load(grinmat)
    
    IMG = double(IMG);
    
    % IMG = IMG./10000;
    % max(max(max(max(IMG))))
    % min(min(min(min(IMG))))
    
% end

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


slideValYA = 0.15;
slideValYB = -0.15;
slideValXA = 100;
slideValXB = 0;
slideValIM = size(IMG,1);
CSUSvals = unique(GRINstruct.csus);






%----------------------------------------------------
%%     CREATE GRINplotGUI FIGURE WINDOW
%----------------------------------------------------
% close(graphguih)
% mainguih.CurrentCharacter = '+';
graphguih = figure('Units', 'normalized','Position', [.02 .1 .85 .65], 'BusyAction',...
    'cancel', 'Name', 'GRINplotGUI', 'Tag', 'graphguih','MenuBar', 'none'); 


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


plotLickDataH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.88 .90 .10], 'FontSize', 13, 'String', 'Plot Lick Data',...
    'Callback', @plotLickData, 'Enable','on');

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
%%    IMAGE VIEW PANEL
%----------------------------------------------------

IMGpanelH = uipanel('Parent', itabs,'Title','GRIN Image','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.01 0.01 0.98 0.97]); % 'Visible', 'Off',

haxIMG = axes('Parent', IMGpanelH, 'NextPlot', 'replacechildren',...
    'Position', [0.01 0.01 0.90 0.85], 'PlotBoxAspectRatio', [1 1 1], ...
    'XColor','none','YColor','none','YDir','reverse');

    haxIMG.XLim = [.5 slideValIM+.5];
    haxIMG.YLim = [.5 slideValIM+.5];

if all(IMG(1) == IMG(1:XLSdata.blockSize))

    IMG = IMG(1:XLSdata.blockSize:end,1:XLSdata.blockSize:end,:,:);
    IMGt = squeeze(reshape(IMG,numel(IMG(:,:,1)),[],size(IMG,3),size(IMG,4)));
    hIMG = imagesc(IMG(:,:,1,1) , 'Parent',haxIMG);
    slideValIM = size(IMG,1);
    XLSdata.blockSize = 1;

end

    % haxIMG.XLim = [0 slideValIM];
    % haxIMG.YLim = [0 slideValIM];
    
    axis(haxIMG,[.5 slideValIM+.5 .5 slideValIM+.5]);
    
    

IMGsliderH = uicontrol('Parent', IMGpanelH, 'Units', 'normalized','Style','slider',...
	'Max',size(IMG,3),'Min',1,'Value',1,'SliderStep',[1 1]./size(IMG,3),...
	'Position', [0.01 0.86 0.94 0.05], 'Callback', @IMGslider);


AXsliderH = uicontrol('Parent', IMGpanelH, 'Units', 'normalized','Style','slider',...
	'Max',size(IMG,1)*2,'Min',size(IMG,1)/2,'Value',size(IMG,1),...
    'SliderStep',[1 1]./(size(IMG,1)),...
	'Position', [0.93 0.02 0.05 0.80], 'Callback', @AXslider);




% IMAGE SIDER CALLBACK
function IMGslider(hObject, eventdata)

    slideVal = ceil(IMGsliderH.Value);

    hIMG = imagesc(IMG(:,:,slideVal) , 'Parent', haxIMG);
              pause(.05)

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


updateROIH = uicontrol('Parent', IMGpanelH, 'Units', 'normalized', ...
    'Position', [0.25 0.92 0.5 0.07], 'FontSize', 13, 'String', 'Update ROI',...
    'Callback', @updateROI);





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
    % keyboard
    
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

end






end
