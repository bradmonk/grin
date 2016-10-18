function [varargout] = RPEfinder(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK)

%{
%----------------------------------------------------
%           MAIN GUI WINDOW
%----------------------------------------------------

% mainguih.CurrentCharacter = '+';
rpeguih = figure('Units', 'normalized','Position', [.05 .05 .9 .82], 'BusyAction',...
    'cancel', 'Name', 'RPEfinder', 'Tag', 'RPEfinder','Visible', 'Off'); %, ...
    %'KeyPressFcn', {@keypresszoom,1});
    
set(rpeguih, 'Visible', 'On');
    
%----------------------------------------------------
%           MAIN IMAGE AXES PANEL
%----------------------------------------------------

MAXpanelH = uipanel('Title','Viewer','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.01 0.01 0.45 0.80]); % 'Visible', 'Off',

haxMAIN = axes('Parent', MAXpanelH, 'NextPlot', 'Add',...
    'Position', [0.01 0.02 0.95 0.93], 'PlotBoxAspectRatio', [1 1 1],...
    'XColor','none','YColor','none');

mainsliderh = uicontrol('Parent', MAXpanelH, 'Units', 'normalized','Style','slider',...
	'Max',50,'Min',1,'Value',10,'SliderStep',[.1 .2],...
	'Position', [0.01 0.96 0.95 0.03], 'Callback', @mainslider);



%----------------------------------------------------
%           MEMO CONSOLE GUI WINDOW
%----------------------------------------------------

memopanelH = uipanel('Title','Memo Log ','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.01 0.82 0.45 0.17]); % 'Visible', 'Off',


memos = {' Welcome to OptoTrack', ' ',...
         ' Import video media to start', ' ', ...
         ' ', ' ', ...
         ' ', ' '};

memoboxH = uicontrol('Parent',memopanelH,'Style','listbox','Units','normalized',...
        'Max',8,'Min',0,'Value',8,'FontSize', 13,'FontName', 'FixedWidth',...
        'String',memos,'FontWeight', 'bold',...
        'Position',[.02 .02 .96 .96]);  



%----------------------------------------------------
%           MINI DATA AXES PANEL
%----------------------------------------------------

DATApanelH = uipanel('Title','Data Viewer','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.47 0.01 0.52 0.23]); % 'Visible', 'Off',

haxMINI = axes('Parent', DATApanelH, 'NextPlot', 'replacechildren',...
    'FontSize', 8,'Color','none',...
    'Position', [0.03 0.08 0.47 0.90]); 

haxMINIL = axes('Parent', DATApanelH, 'NextPlot', 'replacechildren',...
    'FontSize', 8,'Color','none',...
    'Position', [0.52 0.08 0.47 0.90]); 



%----------------------------------------------------
%           LIVE VIDEO TRACKING PANEL
%----------------------------------------------------
LivePanelH = uipanel('Title','Live Tracking','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.47 0.25 0.17 0.36]); % 'Visible', 'Off',


livetrackh = uicontrol('Parent', LivePanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.80 0.90 0.15], 'FontSize', 11, 'String', 'Live Tracking Test',...
    'Callback', @livetracktest); 


uicontrol('Parent', LivePanelH, 'Style', 'Text', 'Units', 'normalized', 'HorizontalAlignment','right',...
    'Position', [0.01 0.69 0.48 0.09], 'FontSize', 11,'String', 'Total Trials:');
LTtrials = uicontrol('Parent', LivePanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.55 0.70 0.35 0.09], 'FontSize', 11); 

uicontrol('Parent', LivePanelH, 'Style', 'Text', 'Units', 'normalized','HorizontalAlignment','right',...
    'Position', [0.01 0.59 0.48 0.09], 'FontSize', 11,'String', 'Frames per Trial:');
LTframespertrial = uicontrol('Parent', LivePanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.55 0.60 0.35 0.09], 'FontSize', 11); 

uicontrol('Parent', LivePanelH, 'Style', 'Text', 'Units', 'normalized', 'HorizontalAlignment','right',...
    'Position', [0.01 0.49 0.48 0.09], 'FontSize', 11,'String', 'Pixel Threshold:');
LTpixelthresh = uicontrol('Parent', LivePanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.55 0.50 0.35 0.09], 'FontSize', 11);

uicontrol('Parent', LivePanelH, 'Style', 'Text', 'Units', 'normalized', 'HorizontalAlignment','right',...
    'Position', [0.01 0.39 0.48 0.09], 'FontSize', 11,'String', 'Pixels to Average:');
LTnpixels = uicontrol('Parent', LivePanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.55 0.40 0.35 0.09], 'FontSize', 11);

uicontrol('Parent', LivePanelH, 'Style', 'Text', 'Units', 'normalized', 'HorizontalAlignment','right',...
    'Position', [0.01 0.29 0.48 0.09], 'FontSize', 11,'String', 'Head radius:');
LTheadrad = uicontrol('Parent', LivePanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.55 0.30 0.35 0.09], 'FontSize', 11);


set(LTtrials, 'String', int2str(1));
set(LTframespertrial, 'String', int2str(100));
set(LTpixelthresh, 'String', num2str(0.25));
set(LTnpixels, 'String', int2str(50));
set(LTheadrad, 'String', int2str(60));

trackheadH = uicontrol('Parent', LivePanelH,'Style','checkbox','Units','normalized',...
    'Position', [0.05 0.05 0.90 0.10] ,'String','Track Head', 'Value',1);



%----------------------------------------------------
%           IMPORTED VIDEO PROCESSING PANEL
%----------------------------------------------------
IPpanelH = uipanel('Title','Video Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.47 0.62 0.17 0.36]); % 'Visible', 'Off',


getvidh = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.80 0.90 0.15], 'FontSize', 11, 'String', 'Import Video',...
    'Callback', @getvid); 

getframesh = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.60 0.90 0.15], 'FontSize', 11, 'String', 'Get Frames',...
    'Callback', @getframes); 

runtrackingh = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.40 0.90 0.15], 'FontSize', 11, 'String', 'Perform Tracking',...
    'Callback', @runtracking); 

runcustomh = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.20 0.90 0.15], 'FontSize', 11, 'String', 'Custom Function',...
    'Callback', @runcustom); 




%----------------------------------------------------
%          GUI PANEL 4
%----------------------------------------------------
GUIpanel4H = uipanel('Title','GUI PANEL 4','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.65 0.25 0.17 0.36]); % 'Visible', 'Off',

camclearH = uicontrol('Parent', GUIpanel4H, 'Units', 'normalized', ...
    'Position', [0.05 0.05 0.90 0.15], 'FontSize', 11, 'String', 'Clear Camera',...
    'Callback', @camclear); 


gethistogramH = uicontrol('Parent', GUIpanel4H, 'Units', 'normalized', ...
    'Position', [0.05 0.25 0.90 0.15], 'FontSize', 11, 'String', 'Get Pixel Histogram',...
    'Callback', @gethistogram);


testpixthreshH = uicontrol('Parent', GUIpanel4H, 'Units', 'normalized', ...
    'Position', [0.05 0.45 0.50 0.15], 'FontSize', 11, 'String', 'Test Pixel Thresh',...
    'Callback', @testpixthresh); 

uicontrol('Parent', GUIpanel4H, 'Style', 'Text', 'Units', 'normalized', 'HorizontalAlignment','right',...
    'Position', [0.57 0.53 0.35 0.09], 'FontSize', 10,'String', 'Test Threshold');
testThreshH = uicontrol('Parent', GUIpanel4H, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.58 0.46 0.35 0.09], 'FontSize', 11);

set(testThreshH, 'String', num2str(0.50));




%----------------------------------------------------
%           GUI PANEL 5
%----------------------------------------------------
GUIpanel5H = uipanel('Title','GUI PANEL 5','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.65 0.62 0.17 0.36]); % 'Visible', 'Off',




%----------------------------------------------------
%          GUI PANEL 6
%----------------------------------------------------
GUIpanel6H = uipanel('Title','GUI PANEL 6','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.83 0.25 0.16 0.36]); % 'Visible', 'Off',




%----------------------------------------------------
%           GUI PANEL 7
%----------------------------------------------------
GUIpanel7H = uipanel('Title','GUI PANEL 7','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.83 0.62 0.16 0.36]); % 'Visible', 'Off',




%}
%%

size(IMG)
size(IMGSraw)

fh0=figure('Units','normalized','OuterPosition',[.02 .1 .85 .6],'Color','w','MenuBar','none');

subplot(1,2,1);
imagesc(squeeze(mean(squeeze(mean(IMG,4)),3)))
axis image;  pause(.1)
axis normal; pause(.1)

subplot(1,2,2);
imagesc(squeeze(mean(squeeze(mean(IMGSraw,4)),3)))
axis image;  pause(.1)
axis normal; pause(.1)

XLSdata
GRINtable
GRINstruct

GRINstruct.file


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

%%

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


%%
Mask = GRINkernel(.8, 9, .14, .1, 1);



clear USFHa USFH_Zscore USFHzcrit USFHzout USFHz ZrawDiff

USFH = mean(rawDiff(:,:,Fcsoff:Fusmid),3);
IMGc = convn( USFH, Mask,'same');

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





%%
%{
rawDiffminmax = [min(min(min(rawDiff))) max(max(max(rawDiff)))];
dfDiffminmax = [min(min(min(dfDiff))) max(max(max(dfDiff)))];

rD = zeros(size(rawDiff(:,:,1)));
rD(1:2) = rawDiffminmax ./2;

fD = zeros(size(dfDiff(:,:,1)));
fD(1:2) = dfDiffminmax ./2;


fh1=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
hax1 = axes('Position',[.001 .001 .999 .999],'Color','none'); 
title(['Examining X. (ID: ', GRINstruct.file ')'])
hold on;

axes(hax1)
ph1 = imagesc(IMGraw,'Parent',hax1,...
'CDataMapping','scaled');
axis image;  pause(.01)
axis normal; pause(1)

IMGSrawMean = squeeze(mean(IMGSraw,4));
for nn = 1:size(IMGSrawMean,3)    
    ph1.CData = IMGSrawMean(:,:,nn);
    pause(.05)
end

for nn = 1:size(rawDiff,3)    
    ph1.CData = rawDiff(:,:,nn) .* ZrawD + rD;
    pause(.05)
end

for nn = 1:size(dfDiff,3)    
    ph1.CData = dfDiff(:,:,nn) .* ZdfD + fD;
    pause(.05)
end
%}


%%

fh1=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
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


colorlist = [.99 .00 .00;
             .00 .99 .00;
             .99 .88 .88;
             .11 .77 .77;
             .77 .77 .11;
             .77 .11 .77;
             .00 .00 .99;
             .22 .33 .44];


% BW = im2bw(ZdfD.*1.0, graythresh(ZdfD.*1.0));
BW = im2bw(ZdfDiff, graythresh(ZdfDiff));

BW_filled = imfill(BW,'holes');

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















varargout = {B};
end
%% EOF
