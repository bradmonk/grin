function plottiles(hp, reph, leg1, GRINstruct, varargin)
% disableButtons; pause(.02);

global GhaxGRIN GimgsliderYAH GimgsliderYBH GimgsliderXAH GimgsliderXBH
global slideValYA slideValYB slideValXA slideValXB
slideValYA = 0.15;
slideValYB = -0.15;
slideValXA = 100;
slideValXB = 0;
global GupdateGraphH Gcheckbox1H Gcheckbox2H Gcheckbox3H Gcheckbox4H
global Gcheckbox5H Gcheckbox6H Gcheckbox7H



    
    tv1 = hp;
    
    tv2 = [tv1.XData];
    tv3 = [tv1.YData];
    
    tv2 = fliplr(reshape(tv2,[],(size(tv1,1))));
    tv3 = fliplr(reshape(tv3,[],(size(tv1,1))));
    
    tv4 = [reph.XData];
    tv5 = [reph.YData];
    
    tv4 = reshape(tv4,[],2);
    tv5 = reshape(tv5,[],2);
    
    CSUSvals = unique(GRINstruct.csus);
    
    
%% -------- MAIN FIGURE WINDOW --------   
% close(graphguih)
% mainguih.CurrentCharacter = '+';
graphguih = figure('Units', 'normalized','Position', [.02 .1 .85 .65], 'BusyAction',...
    'cancel', 'Name', 'mainguih', 'Tag', 'graphguih'); 


GhaxGRIN = axes('Parent', graphguih, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.08 0.55 0.85]);
    GhaxGRIN.YLim = [-.15 .15];
    hold on;
    % 'XColor','none','YColor','none','YDir','reverse'
    % ,'XDir','reverse',... 'PlotBoxAspectRatio', [1 1 1],
    
% YslidertxtH = uicontrol('Parent', graphguih, 'Style', 'Text', 'Units', 'normalized',...
%     'Position', [0.26 0.95 0.13 0.03], 'FontSize', 11,...
%     'String', 'High  -   Y AXIS LIMITS  -   Low');
% XslidertxtH = uicontrol('Parent', graphguih, 'Style', 'Text', 'Units', 'normalized',...
%     'Position', [0.26 0.91 0.13 0.03], 'FontSize', 11,...
%     'String', 'High  -   X AXIS LIMITS  -   Low');

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
%           IMAGE PROCESSING PANEL
%----------------------------------------------------
GIPpanelH = uipanel('Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.65 0.25 0.15 0.73]); % 'Visible', 'Off',


% csustxt = unique(GRINstruct.csus);

GupdateGraphH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.88 .90 .10], 'FontSize', 13, 'String', 'Update Graph',...
    'Callback', @GupdateGraph);

if size(CSUSvals,1) > 0
Gcheckbox1H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.71 .90 .05] ,'String',CSUSvals(1), 'Value',1);
end
if size(CSUSvals,1) > 1
Gcheckbox2H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.61 .90 .05] ,'String',CSUSvals(2), 'Value',1);
end
if size(CSUSvals,1) > 2
Gcheckbox3H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.51 .90 .05] ,'String',CSUSvals(3), 'Value',1);
end
if size(CSUSvals,1) > 3
Gcheckbox4H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.41 .90 .05] ,'String',CSUSvals(4), 'Value',1);
end
if size(CSUSvals,1) > 4 
Gcheckbox5H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.31 .90 .05] ,'String',CSUSvals(5), 'Value',1);
end
if size(CSUSvals,1) > 5
Gcheckbox6H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.21 .90 .05] ,'String',CSUSvals(6), 'Value',1);
end
if size(CSUSvals,1) > 6
Gcheckbox7H = uicontrol('Parent', GIPpanelH,'Style','checkbox','Units','normalized',...
    'Position', [.05 0.11 .90 .05] ,'String',CSUSvals(7), 'Value',1);
end



GCSUSpopupH = uicontrol('Parent', GIPpanelH,'Style', 'popup',...
    'Units', 'normalized', 'String', {'CS','US'},...
    'Position', [.05 .02 0.9 0.05],...
    'Callback', @GCSUSpopup);


%%              
% keyboard
%----------------------------------------------------
%    CUSTOM FUNCTIONS PANEL
%----------------------------------------------------
GcustomfunpanelH = uipanel('Title','Custom Code & Data Exploration','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.81 0.64 0.18 0.34]); % 'Visible', 'Off',
              
GrunCustomAH = uicontrol('Parent', GcustomfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.73 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function A',...
    'Callback', @GrunCustomA);

GrunCustomBH = uicontrol('Parent', GcustomfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.50 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function B',...
    'Callback', @GrunCustomB);

GrunCustomCH = uicontrol('Parent', GcustomfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.26 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function C',...
    'Callback', @GrunCustomC);

GrunCustomDH = uicontrol('Parent', GcustomfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function D',...
    'Callback', @GrunCustomD);





%----------------------------------------------------
%    DATA EXPLORATION & API PANEL
%----------------------------------------------------
GexplorepanelH = uipanel('Title','Data Exploration & API','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.81 0.25 0.18 0.34]); % 'Visible', 'Off',
              
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
GexportpanelH = uipanel('Title','I/O','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.81 0.02 0.18 0.20]); % 'Visible', 'Off',
              
GexportvarsH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.65 0.95 0.28], 'FontSize', 13, 'String', 'Export Vars to Workspace ',...
    'Callback', @Gexportvars);

GsavedatasetH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.34 0.95 0.28], 'FontSize', 13, 'String', 'Save Dataset',...
    'Callback', @Gsavedataset);

GloadmatdataH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.28], 'FontSize', 13, 'String', 'Load .mat Dataset',...
    'Callback', @Gloadmatdata);

    
    

    hp = plot(tv2, tv3 , 'LineWidth',2);
    
    leg1 = legend(hp,unique(GRINstruct.csus));
	set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
    
    
    reph = plot(tv4, tv5 , 'Color',[.5 .5 .5]);
    
    
    
    
    
    
    

    



%----------------------------------------------------
%        IMAGE SIDER CALLBACK
%----------------------------------------------------
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
%        UPDATE GRAPH CALLBACK
%----------------------------------------------------
function GupdateGraph(boxidselecth, eventdata)
disableButtons; pause(.02);
conon
        

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


    
disp('PROCESSING COMPLETED - ALL SELECTED FUNCTIONS FINISHED RUNNING!')
conoff
enableButtons        
end


end
