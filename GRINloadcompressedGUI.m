function [] = GRINloadcompressedGUI(varargin)
%% GRINtoolboxGUI.m - GRIN LENS IMAGING TOOLBOX
%{
% 
% Syntax
% -----------------------------------------------------
%     GRINtoolboxGUI()
% 
% 
% Description
% -----------------------------------------------------
% 
%     GRINtoolboxGUI() is run with no arguments passed in. The user
%     will be prompted to select a directory which contains the image data
%     tif stack along with the corresponding xls file.
%     
% 
% Useage Definitions
% -----------------------------------------------------
% 
%     GRINtoolboxGUI()
%         launches a GUI to process image stack data from GRIN lens
%         experiments
%  
% 
% 
% Example
% -----------------------------------------------------
% 
%     TBD
% 
% 
% See Also
% -----------------------------------------------------
% >> web('http://bradleymonk.com/grintoolbox')
% >> web('http://imagej.net/Miji')
% >> web('http://bigwww.epfl.ch/sage/soft/mij/')
% 
% 
% Attribution
% -----------------------------------------------------
% % Created by: Bradley Monk
% % email: brad.monk@gmail.com
% % website: bradleymonk.com
% % 2016.07.04
%}
%----------------------------------------------------
clc; close all; clear all; clear java;
disp('WELCOME TO THE GRIN LENS IMAGING TOOLBOX')

% clearvars -except varargin
% set(0,'HideUndocumented','off')
% [str,maxsize] = computer;
% if strcmp(str,'MACI64')
%     disp(' '); disp('Purging RAM'); 
%     system('sudo purge'); 
% end


global thisfilepath
thisfile = 'GRINtoolboxGUI.m';
thisfilepath = fileparts(which(thisfile));
cd(thisfilepath);

fprintf('\n\n Current working path set to: \n % s \n', thisfilepath)

    
    pathdir0 = thisfilepath;
    pathdir1 = [thisfilepath filesep 'grinsubfunctions'];
    pathdir2 = [thisfilepath filesep 'grincustomfunctions'];
    
    gpath = [pathdir0 pathsep pathdir1 pathsep pathdir2];
    
    addpath(gpath)

fprintf('\n\n Added folders to path: \n % s \n % s \n % s \n % s \n\n',...
        pathdir0,pathdir1,pathdir2)
    
    
%% MANUALLY SET PER-SESSION PATH PARAMETERS IF WANTED (OPTIONAL)

global imgfilename imgpathname xlsfilename xlspathname lickfilename lickpathname
global imgfullpath xlsfullpath lickfullpath

%% ESTABLISH GLOBALS AND SET STARTING VALUES

global mainguih imgLogo

global IMG INFO GRINtable XLSD LICK 
global IMGred IMGr IMGC IMGIM
global xlsN xlsT xlsR
global lickN LICKraw
global IMGraw IMGSraw IM
global memes conboxH
global NormType

global frame_period framesUncomp CS_type US_type delaytoCS CS_length compressFrms
global total_trials framesPerTrial secPerFrame framesPerSec secondsPerTrial 
global total_frames CS_lengthFrames IMhist tiledatX tiledatY RHposCheck

IMhist.smoothed   = 0;
IMhist.cropped    = 0;
IMhist.tiled      = 0;
IMhist.reshaped   = 0;
IMhist.aligned    = 0;
IMhist.normalized = 0;
IMhist.rawIM      = [];
IMhist.minIM      = [];
IMhist.maxIM      = [];
IMhist.aveIM      = [];

IMGred = [];
IMGr   = [];

NormType = 'dF';



global cropAmount IMGfactors blockSize previewNframes customFunOrder 
cropAmount = 18;
IMGfactors = 1;
blockSize = 22;
previewNframes = 25;
customFunOrder = 1;

global stimtype stimnum CSUSvals
% CSxUS:1  CS:2  US:3
stimnum = 1;
stimtype = 'CS'; 
CSUSvals = {'CS','US'};


global CSonset CSoffset USonset USoffset CSUSonoff
global CSonsetDelay baselineTime CSonsetFrame CSoffsetFrame
CSonsetDelay = 10;
baselineTime = 10;
CSonsetFrame = 25;
CSoffsetFrame = 35;


global smoothHeight smoothWidth smoothSD smoothRes
smoothHeight = .8;
smoothWidth = 9;
smoothSD = .14;
smoothRes = .1;


global AlignVals
AlignVals.P1x = [];
AlignVals.P1y = [];
AlignVals.P2x = [];
AlignVals.P2y = [];
AlignVals.P3x = [];
AlignVals.P3y = [];
AlignVals.P4x = [];
AlignVals.P4y = [];


 
global muIMGS phGRIN previewStacknum toggrid axGRID
global IMGcMax IMGcMaxInd IMGcMin IMGcMinInd
muIMGS = [];
previewStacknum = 25;
toggrid = 0;

global confile confilefullpath
confile = 'gcconsole.txt';
% diary(confile)
disp('GRIN CONSOLE LOGGING ON.')
% diary off
confilefullpath = which(confile,'-all');
% delete(confile)


% -----------------------------------------------------------------
%%     INITIATE GUI HANDLES AND CREATE SUBMENU GUI FIGURE
% -----------------------------------------------------------------
% INITIAL SUBMENU GUI SETUP (GRIN TOOLBOX ~ MOTION CORRECTION)
%{
% initmenuh = figure('Units','normalized','OuterPosition',[.25 .4 .4 .2], ...
%     'BusyAction', 'cancel','Menubar', 'none',...
%     'Name', 'GRIN analysis', 'Tag', 'GRIN analysis');
% 
% grinlenstoolboxh = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.03 .05 .47 .9],...
%     'String', 'Start GRIN lens toolbox', 'FontSize', 16, 'Tag', 'Start GRIN lens toolbox',...
%     'Callback', @grinlenstoolbox);
% 
% motioncorrectionh = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.52 .51 .45 .44],...
%     'String', 'Perform motion correction', 'FontSize', 14, 'Tag', 'Perform motion correction',...
%     'Callback', @motioncorrection);
% 
% 
% formatXLSH = uicontrol('Parent', initmenuh, 'Units','normalized', 'Position', [.52 .05 .45 .44],...
%     'String', 'Multiformat XLS sheets', 'FontSize', 14, 'Tag', 'Multiformat XLS sheets',...
%     'Callback', @formatXLS);
%}


%########################################################################
%%              MAIN GRIN ANALYSIS GUI WINDOW SETUP 
%########################################################################

% mainguih.CurrentCharacter = '+';
mainguih = figure('Units', 'normalized','Position', [.05 .08 .90 .78], 'BusyAction',...
    'cancel', 'Name', 'GRIN TOOLBOX', 'Tag', 'mainguih','Visible', 'Off'); 
     % 'KeyPressFcn', {@keypresszoom,1}, 'CloseRequestFcn',{@mainGUIclosereq}
     % intimagewhtb = uitoolbar(mainguih);


% -------- MAIN FIGURE WINDOW --------
haxGRIN = axes('Parent', mainguih, 'NextPlot', 'replacechildren',...
    'Position', [0.01 0.01 0.40 0.85], 'PlotBoxAspectRatio', [1 1 1], ...
    'XColor','none','YColor','none','YDir','reverse'); 
    % ,'XDir','reverse',...
    
% -------- IMPORT IMAGE STACK & EXCEL DATA BUTTON --------
importimgstackH = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.01 0.90 0.40 0.08], 'FontSize', 14, ...
    'String', 'Import Image Stack & Excel Data', ...
    'Callback', @importimgstack);



imgsliderH = uicontrol('Parent', mainguih, 'Units', 'normalized','Style','slider',...
	'Max',100,'Min',1,'Value',1,'SliderStep',[0.01 0.10],...
	'Position', [0.01 0.86 0.40 0.02], 'Callback', @imgslider);








%----------------------------------------------------
%           MEMO CONSOLE GUI WINDOW
%----------------------------------------------------

memopanelH = uipanel('Parent', mainguih,'Title','Memo Log ','FontSize',10,...
    'BackgroundColor',[1 1 1],...
    'Position', [0.43 0.76 0.55 0.23]); % 'Visible', 'Off',


memes = {' ',' ',' ', ' ',' ',' ',' ', ...
         'Welcome to the GRIN TOOLBOX', 'GUI is loading...'};

conboxH = uicontrol('Parent',memopanelH,'Style','listbox','Units','normalized',...
        'Max',9,'Min',0,'Value',9,'FontSize', 13,'FontName', 'FixedWidth',...
        'String',memes,'FontWeight', 'bold',...
        'Position',[.0 .0 1 1]);  
    

% memocon(['Factor set to: ' callbackdata.NewValue.String])







%----------------------------------------------------
%           IMAGE PROCESSING PANEL
%----------------------------------------------------
IPpanelH = uipanel('Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.43 0.23 0.35 0.52]); % 'Visible', 'Off',



runallIPH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.88 0.95 0.12], 'FontSize', 13, 'String', 'Run All Selected Processes',...
    'Callback', @runallIP, 'Enable','off'); 

HposCheck.A  = [.02  .76  .05  .05];
HposCheck.B  = [.02  .64  .05  .05];
HposCheck.C  = [.02  .52  .05  .05];
HposCheck.D  = [.02  .40  .05  .05];
HposCheck.E  = [.02  .28  .05  .05];
HposCheck.F  = [.02  .16  .05  .05];
HposCheck.G  = [.02  .04  .05  .05];

HposButton.A = [.08  .73  .60  .11];
HposButton.B = [.08  .61  .60  .11];
HposButton.C = [.08  .49  .60  .11];
HposButton.D = [.08  .37  .60  .11];
HposButton.E = [.08  .25  .60  .11];
HposButton.F = [.08  .13  .60  .11];
HposButton.G = [.08  .01  .60  .11];

HposTxt.A    = [.71  .83  .27  .04];
HposTxt.B    = [.71  .70  .27  .04];
HposTxt.C    = [.71  .57  .27  .04];
HposTxt.D    = [.71  .44  .27  .04];
HposTxt.E    = [.71  .34  .27  .04];
HposTxt.F    = [.71  .21  .27  .04];
HposTxt.G    = [.71  .082 .27  .04];

HposEdit.A   = [.71  .76  .27  .07];
HposEdit.B   = [.70  .63  .28  .07];
HposEdit.C   = [.71  .50  .27  .07];
HposEdit.D   = [.71  .39  .27  .08];
HposEdit.E   = [.71  .27  .27  .07];
HposEdit.F   = [.70  .14  .28  .07];
HposEdit.G   = [.70  .002 .27  .08];

checkbox1H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.A ,'String','', 'Value',1);
checkbox2H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.B ,'String','', 'Value',1);
checkbox3H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.C ,'String','', 'Value',1);
checkbox4H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.D ,'String','', 'Value',1);
checkbox5H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.E ,'String','', 'Value',1);
checkbox6H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.F ,'String','', 'Value',1);
checkbox7H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.G ,'String','', 'Value',1);


smoothimgH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.A, 'FontSize', 12, 'String', 'Smooth Images',...
    'Callback', @smoothimg, 'Enable','off'); 
smoothimgtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.A, 'FontSize', 10,'String', 'Smooth Amount (std)');
smoothimgnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.A, 'FontSize', 11); 



cropimgH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.B, 'FontSize', 12, 'String', 'Crop Images',...
    'Callback', @cropimg, 'Enable','off'); 
cropimgtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.B, 'FontSize', 10,'String', 'Crop Amount (pxl)');
cropimgnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.B, 'FontSize', 11); 



imgblocksH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.C, 'FontSize', 12, 'String', 'Tile Images',...
    'Callback', @imgblocks, 'Enable','off'); 
imgblockstxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.C, 'FontSize', 10,'String', 'Tile Size (pxl)');
imgblockspopupH = uicontrol('Parent', IPpanelH,'Style', 'popup',...
    'Units', 'normalized', 'String', {'20','2','1'},...
    'Position', HposEdit.C,...
    'Callback', @imgblockspopup);


reshapeDataH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.D, 'FontSize', 12, 'String', 'Reshape stack by trial (4D) ',...
    'Callback', @reshapeData, 'Enable','off'); 
unshapeDataH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposEdit.D, 'FontSize', 10, 'String', 'Undo reshape (3D) ',...
    'Callback', @unshapeData, 'Enable','off'); 



alignCSFramesH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.E, 'FontSize', 12, 'String', 'Align frames by CS onset',...
    'Callback', @alignCSframes, 'Enable','off');
alignCSFramestxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.E, 'FontSize', 10,'String', 'Delay to CS onset (s)');
alignCSFramesnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.E, 'FontSize', 11); 



dFoverFH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.F, 'FontSize', 12, 'String', 'Normalize Dataset',...
    'Callback', @dFoverF, 'Enable','off'); 
dFoverFtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.F, 'FontSize', 10,'String', 'Baseline time (s)');
dFoverFnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.F, 'FontSize', 11);


NormTypeH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.G, 'FontSize', 10,'String', 'Normalization Type');
NormTypePopupH = uicontrol('Parent', IPpanelH,'Style', 'popup',...
    'Units', 'normalized', 'String', {'dF','Zscore','Dprime'},...
    'Position', HposEdit.G,...
    'Callback', @NormTypePopup, 'Enable','on');


timepointMeansH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.G, 'FontSize', 12, 'String', 'Compute trial means ',...
    'Callback', @timepointMeans, 'Enable','off');              
% CSUSpopupH = uicontrol('Parent', IPpanelH,'Style', 'popup',...
%     'Units', 'normalized', 'String', {'CS','US'},...
%     'Position', HposEdit.G,...
%     'Callback', @CSUSpopup, 'Enable','off');



              

%----------------------------------------------------
%           DATA GRAPHS AND FIGURES PANEL
%----------------------------------------------------
graphspanelH = uipanel('Title','Graphs and Figures','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.43 0.01 0.35 0.20]); % 'Visible', 'Off',
              



plotTileStatsH = uicontrol('Parent', graphspanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.66 0.31 0.28], 'FontSize', 12, 'String', 'Plot Tile Data',...
    'Callback', @plotTileStats, 'Enable','off'); 

plotGUIH = uicontrol('Parent', graphspanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.34 0.31 0.28], 'FontSize', 12, 'String', 'Open Plot GUI',...
    'Callback', @plotGUI, 'Enable','off');

plotGroupMeansH = uicontrol('Parent', graphspanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.31 0.28], 'FontSize', 12, 'String', 'Plot Group Means',...
    'Callback', @plotGroupMeans, 'Enable','off');

viewGridOverlayH = uicontrol('Parent', graphspanelH, 'Units', 'normalized', ...
    'Position', [0.35 0.66 0.31 0.28], 'FontSize', 12, 'String', 'View Grid Overlay',...
    'Callback', @viewGridOverlay, 'Enable','off');

viewTrialTimingsH = uicontrol('Parent', graphspanelH, 'Units', 'normalized', ...
    'Position', [0.35 0.34 0.31 0.28], 'FontSize', 12, 'String', 'View Trial Timings',...
    'Callback', @viewTrialTimings, 'Enable','off');

previewStackH = uicontrol('Parent', graphspanelH, 'Units', 'normalized', ...
    'Position', [0.35 0.03 0.38 0.28], 'FontSize', 12, 'String', 'Preview Image Stack',...
    'Callback', @previewStack, 'Enable','off');
previewStacktxtH = uicontrol('Parent', graphspanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.74 0.29 0.15 0.11], 'FontSize', 10,'String', 'Frames');
previewStacknumH = uicontrol('Parent', graphspanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.74 0.07 0.15 0.20], 'FontSize', 12);
% previewStackcbH = uicontrol('Parent', graphspanelH,'Style','checkbox','Units','normalized',...
%     'Position', [.62 0.12 .14 .14] ,'String','Postprocessing Previews', 'Value',1);


getROIstatsH = uicontrol('Parent', graphspanelH, 'Units', 'normalized', ...
    'Position', [0.67 0.45 0.31 0.50], 'FontSize', 12, 'String', 'ROI TOOLBOX',...
    'Callback', @openROITOOLBOX, 'Enable','off');



% %----------------------------------------------------
% %    CUSTOM FUNCTIONS PANEL
% %----------------------------------------------------
% customfunpanelH = uipanel('Title','Custom Code & Data Exploration','FontSize',10,...
%     'BackgroundColor',[.95 .95 .95],...
%     'Position', [0.80 0.49 0.18 0.26]); % 'Visible', 'Off',
              
% runCustomAH = uicontrol('Parent', customfunpanelH, 'Units', 'normalized', ...
%     'Position', [0.03 0.73 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function A',...
%     'Callback', @runCustomA);

% runCustomBH = uicontrol('Parent', customfunpanelH, 'Units', 'normalized', ...
%     'Position', [0.03 0.50 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function B',...
%     'Callback', @runCustomB);

% runCustomCH = uicontrol('Parent', customfunpanelH, 'Units', 'normalized', ...
%     'Position', [0.03 0.26 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function C',...
%     'Callback', @runCustomC);

% runCustomDH = uicontrol('Parent', customfunpanelH, 'Units', 'normalized', ...
%     'Position', [0.03 0.03 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function D',...
%     'Callback', @redChannelSubtraction);


%----------------------------------------------------
%    ALIGN & NORMALIZE PANEL
%----------------------------------------------------
alignfunpanelH = uipanel('Title','Align & Normalize','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.80 0.49 0.18 0.26]); % 'Visible', 'Off',


getAlignH = uicontrol('Parent', alignfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.80 0.45 0.17], 'FontSize', 13, 'String', 'Get Align',...
    'Callback', @getAlign, 'Enable','off');

setAlignH = uicontrol('Parent', alignfunpanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.80 0.45 0.17], 'FontSize', 13, 'String', 'Set Align',...
    'Callback', @setAlign, 'Enable','off');


imgAlignXTxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.12 0.70 0.35 0.09], 'FontSize', 10,'String', 'X');

imgAlignYTxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.57 0.70 0.35 0.09], 'FontSize', 10,'String', 'Y');


imgAlignP1TxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.59 0.13 0.10], 'FontSize', 10,'String', 'P1: ');

imgAlignP2TxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.46 0.13 0.10], 'FontSize', 10,'String', 'P2: ');

imgAlignP3TxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.33 0.13 0.10], 'FontSize', 10,'String', 'P3: ');

imgAlignP4TxtH = uicontrol('Parent', alignfunpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.20 0.13 0.10], 'FontSize', 10,'String', 'P4: ');




imgAlignP1Xh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.18 0.59 0.28 0.11], 'FontSize', 10);

imgAlignP1Yh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.62 0.59 0.28 0.11], 'FontSize', 10);


imgAlignP2Xh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.18 0.46 0.28 0.11], 'FontSize', 10);

imgAlignP2Yh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.62 0.46 0.28 0.11], 'FontSize', 10);


imgAlignP3Xh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.18 0.33 0.28 0.11], 'FontSize', 10);

imgAlignP3Yh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.62 0.33 0.28 0.11], 'FontSize', 10);


imgAlignP4Xh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.18 0.20 0.28 0.11], 'FontSize', 10);

imgAlignP4Yh = uicontrol('Parent', alignfunpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.62 0.20 0.28 0.11], 'FontSize', 10);







redChImportH = uicontrol('Parent', alignfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.02 0.45 0.17], 'FontSize', 11, 'String', 'Import Red Ch.',...
    'Callback', @redChImport, 'Enable','off');

redChanNormalizeH = uicontrol('Parent', alignfunpanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.02 0.45 0.17], 'FontSize', 11, 'String', 'Red Ch. Norm.',...
    'Callback', @redChanNormalize, 'Enable','off');





%----------------------------------------------------
%    DATA EXPLORATION & API PANEL
%----------------------------------------------------
explorepanelH = uipanel('Title','Data Exploration & API','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.80 0.23 0.18 0.24]); % 'Visible', 'Off',

openImageJH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.75 0.45 0.20], 'FontSize', 12, 'String', 'Open in ImageJ ',...
    'Callback', @openImageJ, 'Enable','off');

img3dH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.75 0.45 0.20], 'FontSize', 12, 'String', '3D Views',...
    'Callback', @img3d, 'Enable','off');

normLickH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.50 0.45 0.20], 'FontSize', 12, 'String', 'Normalize Lick',...
    'Callback', @normLick, 'Enable','off');

plotLickH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.50 0.45 0.20], 'FontSize', 12, 'String', 'Plot Lick',...
    'Callback', @plotLick, 'Enable','off');

runPCAh = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.25 0.45 0.20], 'FontSize', 12, 'String', 'PCA',...
    'Callback', @runPCA, 'Enable','off');

tempfun2H = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.25 0.45 0.20], 'FontSize', 12, 'String', 'TBD',...
    'Callback', @tempfun2, 'Enable','off');

visualexplorerH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.01 0.45 0.20], 'FontSize', 12, 'String', 'Explorer',...
    'Callback', @visualexplorer, 'Enable','off');

resetwsH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.53 0.01 0.45 0.20], 'FontSize', 12, 'String', 'Reset Toolbox',...
    'Callback', @resetws);





%----------------------------------------------------
%    SAVE AND EXPORT DATA
%----------------------------------------------------
exportpanelH = uipanel('Title','I/O','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.80 0.01 0.18 0.20]); % 'Visible', 'Off',
              
exportvarsH = uicontrol('Parent', exportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.65 0.95 0.28], 'FontSize', 13, 'String', 'Export Vars to Workspace ',...
    'Callback', @exportvars);

savedatasetH = uicontrol('Parent', exportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.34 0.46 0.28], 'FontSize', 11, 'String', 'Save Data',...
    'Callback', @savedataset);

compnsaveH = uicontrol('Parent', exportpanelH, 'Units', 'normalized', ...
    'Position', [0.52 0.34 0.46 0.28], 'FontSize', 11, 'String', 'Compress Save',...
    'Callback', @compnsave);

loadmatdataH = uicontrol('Parent', exportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.28], 'FontSize', 13, 'String', 'Load .mat Dataset',...
    'Callback', @loadmatdata);



% enableButtons


pause(.1)

grinlenstoolbox()

% memocon('Ready!')



% -----------------------------------------------------------------------------
%%                     GUI TOOLBOX FUNCTIONS
% -----------------------------------------------------------------------------



%----------------------------------------------------
%   INITIAL GRIN TOOLBOX FUNCTION TO POPULATE GUI
%----------------------------------------------------
function grinlenstoolbox(hObject, eventdata)

    % set(initmenuh, 'Visible', 'Off');
    % set(mainguih, 'Visible', 'On');
    
    %----------------------------------------------------
    %           SET USER-EDITABLE GUI VALUES
    %----------------------------------------------------
    imgLogo = imread('grinlogo.png');
    set(haxGRIN, 'XLim', [1 size(imgLogo,2)], 'YLim', [1 size(imgLogo,1)]);
    set(smoothimgnumH, 'String', num2str(smoothSD));
    set(cropimgnumH, 'String', num2str(cropAmount));
    set(alignCSFramesnumH, 'String', num2str(CSonsetDelay));
    set(dFoverFnumH, 'String', num2str(baselineTime));
    set(previewStacknumH, 'String', num2str(previewStacknum));
    
    % set(imgblocksnumH, 'String', num2str(blockSize));
    % Set radiobuttons
    % stimtypeh.SelectedObject = stimtypeh1; 
    % stimtype = stimtypeh.SelectedObject.String;
    %----------------------------------------------------
    
    
    
    
    %----------------------------------------------------
    %                   DRAW IMAGE
    %----------------------------------------------------

        axes(haxGRIN)
        colormap(haxGRIN,parula)
    phGRIN = imagesc(imgLogo , 'Parent', haxGRIN);
        pause(.1)

memocon('Ready to Import Image Stack!')
end



%----------------------------------------------------
%        IMPORT IMAGE STACK MAIN FUNCTION
%----------------------------------------------------
function importimgstack(hObject, eventdata)
% diary on
memocon('GRIN LENS IMAGING TOOLBOX - ACQUIRING DATASET')


  %------------------- IMPORT DATA DIALOGUES --------------------

  %--- IMPORT TIF IMAGE STACK
  
    % PATH TO IMAGE STACK WAS ALREADY SET MANUALLY ABOVE
    if numel(imgfilename) > 1
        
        memocon('image stack path was set manually')
            
    % PATH TO IMAGE STACK WAS NOT SET - GET IT NOW    
    else
        [imgfilename, imgpathname] = uigetfile({'*.tif*'},...
        'Select image stack to import', thisfilepath);   
    
        imgfullpath = [imgpathname imgfilename];
    end
    

  %--- IMPORT MAIN XLS DATA OF EXPERIMENT PARAMETERS    
    % tv1=[];tv2=[];tv3=[];tv4=[];tv5=[];
    
    
    
    [IMGfpPath,IMGfpFile,IMGfpExt] = fileparts(imgfullpath);

    if numel(IMGfpFile)<14
        xlsFiles = dir([imgpathname, IMGfpFile(1:11) '*.xls*']);
    else
        xlsFiles = dir([imgpathname, IMGfpFile(1:14) '*.xls*']);
    end
    
    % IF THERE WAS A SINGLE MATCH, BINGO!
    if numel(xlsFiles) == 1

        choice = questdlg({'Matching xls file found.', 'Would you like to import:',...
                           xlsFiles.name}, ...
                           'Import XLS file', ...
                           'Yes','No (import manually)','Yes');
        switch choice
            case 'Yes'
                % memocon([choice ' importing xls data...'])
                xlsfilename = xlsFiles.name;
                xlspathname = imgpathname;
                xlsfullpath = [xlspathname xlsfilename];
            case 'No (import manually)'
                [xlsfilename, xlspathname] = uigetfile({'*.xls*'},...
                'Select Excel file associated with the TIF stack', imgpathname);
                xlsfullpath = [xlspathname xlsfilename];
        end


    % THERE WERE MULTIPLE MATCHING FILES
    elseif numel(xlsFiles) > 1 

            [s,v] = listdlg('PromptString','Select main xls file:',...
            'SelectionMode','single',...
            'ListString',{xlsFiles.name},...
            'ListSize',[200 120], 'fus', 10, 'ffs', 12);

            if v == 1 % USER PRESSED 'OK'
                    xlsfilename = xlsFiles(s).name;
                    xlspathname = imgpathname;
                    xlsfullpath = [xlspathname xlsfilename];
            else % USER PRESSED 'CANCEL' - ALLOW MANUAL SELECTION
                    [xlsfilename, xlspathname] = uigetfile({'*.xls*'},...
                    'Select Excel file associated with the TIF stack',...
                    imgpathname);
                    xlsfullpath = [xlspathname xlsfilename];
            end


    % NOTHING MATCHED - ALLOW MANUAL SELECTION    
    else
        memocon(' ');
        memocon('No matching xls files were found in the same dir as the tif stack');
        memocon('Manually select the Excel datasheet of imaging parameters');
        [xlsfilename, xlspathname] = uigetfile({'*.xls*'},...
                'Select Excel file associated with the TIF stack', imgpathname);
        xlsfullpath = [xlspathname xlsfilename];
    end
    

    
    
    
    
    
  %--- IMPORT LICK.XLS DATA
  
  % DETERMINE IF LICK.XLS FILE EXISTS IN SAME DIR AS XLS DATA
  
    [XLSfpPath,XLSfpFile,XLSfpExt] = fileparts(xlsfullpath);

    if numel(XLSfpFile)<14
        lickxlsFiles = dir([xlspathname, XLSfpFile(1:11) '*_lick.xls*']);
    else
        lickxlsFiles = dir([xlspathname, XLSfpFile(1:14) '*_lick.xls*']);
    end
        
    if numel(lickxlsFiles) > 0

        doimportlicking = questdlg({'LICK DATA was found near the tif stack;',...
        ' want to import LICK DATA?'}, ...
            'Lick data import','Yes','No','Yes');

    else

        doimportlicking = questdlg({'NO LICK DATA was found near the tif stack;',...
        ' want to manually find and import LICK DATA?'}, ...
            'Lick data import','Yes','No','No');

    end
  
    
  switch doimportlicking
	case 'Yes'
    
    % PATH TO LICK.XLS DATA WAS ALREADY SET MANUALLY ABOVE
    if numel(lickfilename) > 1
        
        memocon('xls data path was set manually')
        
    % PATH TO LICK.XLS DATA WAS NOT SET MANUALLY - GET IT NOW
    else
    
        lickxlsFiles = dir([xlspathname, XLSfpFile(1:14) '*_lick.xls*']);

        % IF THERE WAS A SINGLE MATCH, BINGO!
        if numel(lickxlsFiles) == 1

            choice = questdlg({'Matching xls licking file found.',...
                               'Would you like to import:',...
                               lickxlsFiles.name}, ...
                               'Import XLS file', ...
                               'Yes','No (import manually)','No','Yes');
            switch choice
                case 'Yes'
                    lickfilename = lickxlsFiles.name;
                    lickpathname = imgpathname;
                    lickfullpath = [lickpathname lickfilename];
                case 'No (import manually)'
                    [lickfilename, lickpathname] = uigetfile({'*.xls*'},...
                    'Select Excel file of licking data', imgpathname);
                    lickfullpath = [lickpathname lickfilename];
                case 'No'
                    lickfilename = [];
                    lickpathname = [];
                    lickfullpath = [];
            end
        
            
        % THERE WERE MULTIPLE MATCHING FILES
        elseif numel(lickxlsFiles) > 1 
                    
                [s,v] = listdlg('PromptString','Select xls licking file:',...
                'SelectionMode','single',...
                'ListString',{lickxlsFiles.name});
            
                if v == 1 % USER PRESSED 'OK'
                        lickfilename = lickxlsFiles(s).name;
                        lickpathname = imgpathname;
                        lickfullpath = [lickpathname lickfilename];
                else % USER PRESSED 'CANCEL' - ALLOW MANUAL SELECTION
                        [lickfilename, lickpathname] = uigetfile({'*.xls*'},...
                        'Select Excel file of licking data', imgpathname);
                        lickfullpath = [lickpathname lickfilename];
                end
                

        % NOTHING MATCHED - ALLOW MANUAL SELECTION    
        else
            memocon(' ');
            memocon('No matching licking files were found tif stack dir');
            memocon('Manually select the Excel licking datasheet');
            [lickfilename, lickpathname] = uigetfile({'*.xls*'},...
                    'Select Excel file of licking data', imgpathname);
            lickfullpath = [lickpathname lickfilename];
        end
    
    end
    
  case 'No'
    lickfilename = [];
    lickpathname = [];
    lickfullpath = [];
  end
      
  %---------------------------------------------------------------------
    
  
  
  
    memocon(sprintf('GRIN DATASET: % s ', imgfilename));
    fprintf('\n\n GRIN DATASET: % s \n\n', imgfilename);
    pause(.1)
    
    
    % ------------- IMG STACK IMPORT CODE -----------
    memocon(sprintf('Importing tif stack from: % s', [imgpathname , imgfilename]));
    fprintf('\n Importing tif stack from...\n % s \n', [imgpathname , imgfilename]);

    FileTif=[imgpathname , imgfilename];
    InfoImage=imfinfo(FileTif);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    
    if NumberImages < 2

        IMG = imread(FileTif);

        IMG = double(IMG);

    else
    
        IMG = zeros(nImage,mImage,NumberImages,'double');

        TifLink = Tiff(FileTif, 'r');
        for i=1:NumberImages
           TifLink.setDirectory(i);
           IMG(:,:,i)=TifLink.read();
        end
        TifLink.close();
    
    end
    
    memocon('Image stack sucessfully imported!') 
    
    axes(haxGRIN)
    colormap(haxGRIN,parula)
    phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);
              pause(1)
    
    IMGraw = IMG(:,:,1);
    % imgslider.Max = size(IMG);
    % imgsliderH.SliderStep = [1 size(IMG)]
    
    % keyboard
    % tv1 = [];
    
    if size(IMG,1) < 100
        set(cropimgnumH, 'String', num2str(2));
        set(haxGRIN, 'XLim', [1 size(IMG,2)+40], 'YLim', [1 size(IMG,1)+40]);
    elseif (size(IMG,1) < 140) && (size(IMG,1) >= 100)
        set(cropimgnumH, 'String', num2str(4));
        set(haxGRIN, 'XLim', [1 size(IMG,2)+30], 'YLim', [1 size(IMG,1)+30]);
    elseif size(IMG,1) < 180 && (size(IMG,1) >= 140)
        set(cropimgnumH, 'String', num2str(8));
        set(haxGRIN, 'XLim', [1 size(IMG,2)+20], 'YLim', [1 size(IMG,1)+20]);
    elseif size(IMG,1) < 220 && (size(IMG,1) >= 180)
        set(cropimgnumH, 'String', num2str(12));
        set(haxGRIN, 'XLim', [1 size(IMG,2)+10], 'YLim', [1 size(IMG,1)+10]);
    else
        set(cropimgnumH, 'String', num2str(18));
        set(haxGRIN, 'XLim', [1 size(IMG,2)], 'YLim', [1 size(IMG,1)]);
    end
    
    

              
    % ------------- XLS IMPORT CODE -----------
    memocon(sprintf('Importing xls info from: % s', [xlspathname , xlsfilename]));
    fprintf('\n Importing xls info from...\n % s \n', [xlspathname , xlsfilename]);

    [xlsN,xlsT,xlsR] = xlsread([xlspathname , xlsfilename]);
    
    if size(xlsN,1) == size(xlsR,1)
        xlsN(1,:) = [];
    end

    disp(' '); 
    disp('Preview of raw xls import...')
    disp(xlsR(1:5,1:7))

    frame_period    = xlsN(1,1);
    framesUncomp    = xlsN(1,2);
    CS_type         = xlsT(2:end,3);
    US_type         = xlsT(2:end,4);
    delaytoCS       = xlsN(:,5);
    CS_length       = xlsN(1,6);
    compressFrms    = xlsN(1,7);

    total_trials    = size(xlsN,1);                     % total number of trials
    framesPerTrial  = framesUncomp / compressFrms;      % frames per trial
    secPerFrame     = frame_period * compressFrms;      % seconds per frame
    framesPerSec    = 1 / secPerFrame;                  % frames per second
    secondsPerTrial = framesPerTrial * secPerFrame;     % seconds per trial
    total_frames    = total_trials * framesPerTrial;    % total collected frames
    CS_lengthFrames = round(CS_length .* framesPerSec); % CS length in frames

    
    
    fprintf('\n\n In this dataset there are...')
    fprintf('\n    total trials: %10.1f  ', total_trials)
    fprintf('\n    frames per trial: %7.1f  ', framesPerTrial)
    fprintf('\n    seconds per frame: %8.5f  ', secPerFrame)
    fprintf('\n    frames per second: %8.5f  ', framesPerSec)
    fprintf('\n    seconds per trial: %8.4f  \n\n', secondsPerTrial)  
    
    
    % CREATE ID FOR EACH UNIQUE CS+US COMBO AND DETERMINE ROW 
    [INFO, GRINtable] = gettrialtypes(total_trials, CS_type, US_type, framesPerTrial);

    INFO.file  = imgfilename;
    INFO.path  = [imgpathname imgfilename];

    disp('INFO contains the following structural arrays:')
    disp('{  Example usage: INFO.tf(:,1)  }')
    disp(INFO)

    disp('GRINtable includes the following columns:')
    disp(GRINtable(1:10,:))

    CSonsetDelay = min(delaytoCS);
    set(alignCSFramesnumH, 'String', num2str(CSonsetDelay));
    baselineTime = CSonsetDelay;
    set(dFoverFnumH, 'String', num2str(baselineTime));
        
     CSUSvals = unique(INFO.csus);
     % set(CSUSpopupH, 'String', CSUSvals);
     
     CSonsetFrame = round(CSonsetDelay .* framesPerSec);
     CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);
     
    XLSD.frame_period    = frame_period;
    XLSD.framesUncomp    = framesUncomp;
    XLSD.CS_type         = CS_type;
    XLSD.US_type         = US_type;
    XLSD.delaytoCS       = delaytoCS;
    XLSD.CS_length       = CS_length;
    XLSD.compressFrms    = compressFrms;
    XLSD.total_trials    = total_trials;
    XLSD.framesPerTrial  = framesPerTrial;
    XLSD.secPerFrame     = secPerFrame;
    XLSD.framesPerSec    = framesPerSec;
    XLSD.secondsPerTrial = secondsPerTrial;
    XLSD.total_frames    = total_frames;
    XLSD.CS_lengthFrames = CS_lengthFrames;
    XLSD.CSonsetDelay    = CSonsetDelay;
    XLSD.CSonsetFrame    = CSonsetFrame;
    XLSD.CSoffsetFrame   = CSoffsetFrame;
    XLSD.baselineTime    = baselineTime;
    XLSD.CSUSvals        = CSUSvals;
    XLSD.blockSize       = blockSize;
    XLSD.cropAmount      = cropAmount;
    XLSD.sizeIMG         = size(IMG);
    
    
    % GET TREATMENT GROUP STRINGS
    fid=[];
    for nn = 1:size(INFO.tf,2)
        fid(nn) = find(INFO.id==nn,1); 
    end
    INFO.TreatmentGroups = INFO.csus(fid);
     
    
    
    
    
    if XLSD.total_frames == size(IMG,3)
        memocon('GOOD: XLSD.total_frames == size(IMG,3)')
    else
        memocon('WARNING: XLSD.total_frames ~= size(IMG,3)')
        warning('WARNING: XLSD.total_frames ~= size(IMG,3)')
    end
    
    if numel(xlsT{2,8}) > 5
        memocon(sprintf('XLSD reports 2 channels: %s',xlsT{2,8}),'WARNING',4)
        
        Isz = size(reshape(IMG,size(IMG,1),size(IMG,2),[],XLSD.total_trials));
        
        if Isz(3) == XLSD.framesPerTrial && Isz(4) == XLSD.total_trials
            memocon('When IMG stack is reshaped it matches XLS data')
            memocon('IMG matches XLS for frames per trial & total trials')
            memocon(sprintf('Frames per trial: %s',num2str(Isz(3))))
            memocon(sprintf('Total trials: %s',num2str(Isz(4))))
        else
            memocon('When IMG stack is reshaped it DOES NOT matches XLS data')
            memocon('IMG ~= XLS for frames per trial & total trials')
            memocon('RESETTING TOOLBOX IN 5 SECONDS','ERROR',6)
            resetws
        end
        
    end
    
    
    memocon('XLS experiment parameters successfully imported!')
    
    % ------------- LICK DATA IMPORT CODE -----------
    if numel(lickfilename) > 2;
        
        memocon('Importing lick data...')
        
        [lickN,~,~] = xlsread([lickpathname , lickfilename]);

        if (size(lickN,2) ~= total_trials) 
            warning(['\n Number of colums in % s \n does not match number ',...
            'of trials in % s \n (toolbox may crash during analysis). \n'],...
            lickfilename, xlsfilename)
        end
        
        
        
        
        LICK = lickN';
        
        LICKs = [];
        for nn = 1:size(XLSD.CSUSvals,1)

            LICKs(nn,:) = mean(LICK(INFO.tf(:,nn),:),1);

        end


        ndx = round(linspace(1,size(LICKs,2),size(INFO.frames,2)+1));
        %ndx = round(linspace(1,size(INFO.frames,2),size(INFO.id,1)+1));

        LICKmu = zeros(size(INFO.tf,2),size(ndx,2)-1);

        for nn = 1:size(INFO.tf,2)
            for tt = 2:size(ndx,2)

            LICKmu(nn,tt-1) = mean(mean(LICK(INFO.tf(:,nn),ndx(tt-1):ndx(tt)),2));

            end
        end
        
        LICK = LICKmu;
        
        clear lickN LICKmu

        % LICK = reshape(lickN,floor(size(lickN,1) / framesPerTrial),[], size(lickN,2));
        % LICK = squeeze(sum(LICK,1));
        plotLickH.Enable = 'on';
        normLickH.Enable = 'on';
        memocon(sprintf('Lick data imported and reshaped to size: % s',num2str(size(LICK))))
    end
     
     

    % IMPORT ALIGNMENT VALUES FROM EXCEL SHEET
    try

        xlsA = xlsread([xlspathname , xlsfilename],'ALIGN');

        memocon('Imported pre-existing aligment values fomr ALIGN excel sheet');

        
        AlignVals.P1x = xlsA(1,1);
        AlignVals.P1y = xlsA(1,2);
        AlignVals.P2x = xlsA(2,1);
        AlignVals.P2y = xlsA(2,2);
        
        AlignVals.P3x = xlsA(3,1);
        AlignVals.P3y = xlsA(3,2);
        AlignVals.P4x = xlsA(4,1);
        AlignVals.P4y = xlsA(4,2);        
        
        imgAlignP1Xh.String = num2str(AlignVals.P1x);
        imgAlignP1Yh.String = num2str(AlignVals.P1y);
        imgAlignP2Xh.String = num2str(AlignVals.P2x);
        imgAlignP2Yh.String = num2str(AlignVals.P2y);        
        
        imgAlignP3Xh.String = num2str(AlignVals.P3x);
        imgAlignP3Yh.String = num2str(AlignVals.P3y);
        imgAlignP4Xh.String = num2str(AlignVals.P4x);
        imgAlignP4Yh.String = num2str(AlignVals.P4y);
        

    catch ME

        memocon(ME.message)
        
        imgAlignP1Xh.String = num2str(0);
        imgAlignP1Yh.String = num2str(0);
        imgAlignP2Xh.String = num2str(0);
        imgAlignP2Yh.String = num2str(0);
        
        imgAlignP3Xh.String = num2str(0);
        imgAlignP3Yh.String = num2str(0);
        imgAlignP4Xh.String = num2str(0);
        imgAlignP4Yh.String = num2str(0);

    end 
     
     
     
     % VISUALIZE AND ANNOTATE
     memocon(sprintf('Imported image stack size: % s ', num2str(size(IMG))));
     
  IMG = IMG(:,:,1:total_frames);

    memocon(sprintf('Size after xls-informed adjustment: % s ', num2str(size(IMG))));

    update_IMGfactors()
    
    
    
enableButtons
redChImportH.Enable = 'on';
memocon('Image stack and xls data import completed!')
% diary(confile)
diary off
end






%----------------------------------------------------
%        LOAD .mat DATA
%----------------------------------------------------
function loadmatdata(hObject, eventdata)
% disableButtons; pause(.02);

[filename, pathname] = uigetfile( {'*.mat'},'Select a .mat datafile');
memocon('Loading data from .mat file, please wait...'); pause(.02);    


    LODIN = load([pathname, filename]);
    
    
    [IMG] = deal(LODIN.IMGC);
    [INFO] = deal(LODIN.INFO);
    [XLSD] = deal(LODIN.XLSD);
    [LICK] = deal(LODIN.LICK);
    
    % clear LODIN

    IMGIM = IMG;
    IMG = double(IMG);

    muIMGS  = mean(mean(IMG,4),3);
    IM = muIMGS;




    memocon('Image stack sucessfully imported!') 
    
    previewIM( IM )

    previewStack(.15)


% LINEAR TRANSFORM PIXEL RANGE
%{
%     if isa(IMG, 'single') || isa(IMG, 'double')
% 
%         memocon('loading single precision dataset...')
%         IM = IMG;
%         IMG = double(IM);
%         
%     elseif isa(IMG, 'uint16')
%         
%         memocon('loading uint16-compressed dataset...')
%         IM = IMG;
%         IMG = double(IM);
%         lintrans = @(x,a,b,c,d) (c.*(1-(x-a)./(b-a)) + d.*((x-a)./(b-a)));
%         IMG = lintrans(IMG,min(min(min(min(IMG)))),max(max(max(max(IMG)))),IMhist.minIM,IMhist.maxIM);
%         
%     end
%}
    
    




    clc;
    %memocon('Dataset loaded with the following history...')
    %memocon(IMhist)
    memocon('Experimental parameters...')
    memocon(XLSD.CSUSvals)
    memocon('Image stack sizes...')
    memocon(['size(IMG) :  '     num2str(size(IMG))])
    %memocon(['size(muIMGS) :  '  num2str(size(muIMGS))])
    %memocon(['size(IMGSraw) :  ' num2str(size(IMGSraw))])

memocon('Dataset fully loaded, GRIN Toolbox is Ready!')
enableButtons
end












%% ------------------------- previewStack ------------------------------


%----------------------------------------------------
%        previewStack
%----------------------------------------------------
function previewStack(varargin)
disableButtons; pause(.02);


if nargin > 0
    ccut = varargin{1};
else
    ccut = .1;
end


if nargin > 1
    IMGi = varargin{2};
else
    IMGi = IMG;
end





    % memocon('PREVIEWING IMAGE STACK')
    
    totframes = size(IMGi,3);
    
    previewStacknum = str2num(previewStacknumH.String);

    
    if totframes >= previewStacknum
    

        IMGi = IMGi(:,:,1:previewStacknum);
    
    
        [IMGcMax, IMGcMaxInd] = max(IMGi(:));
        [IMGcMin, IMGcMinInd] = min(IMGi(:));    
        
        axes(haxGRIN)
        phGRIN = imagesc(IMGi(:,:,1),'Parent',haxGRIN,'CDataMapping','scaled');

        [cmax, ~] = max(IMGi(:));
        [cmin, ~] = min(IMGi(:));
        memocon(['cmin :  ' num2str(cmin)])
        memocon(['cmax :  ' num2str(cmax)])
        crange = cmax - cmin;
        cmid = median([cmax,cmin]);
        IMAX = cmax - ((cmax-cmid)*ccut);
        IMIN = cmin + ((cmid-cmin)*ccut);
        if IMAX > IMIN
        haxGRIN.CLim = [IMIN IMAX];
        end


        for nn = 1:previewStacknum
            phGRIN.CData = IMGi(:,:,nn);
            pause(.04)
        end

    
    else
       memocon('Not enough images in 3rd dim to preview that many frames')         
    end

enableButtons        
% memocon('Preview completed!')
end



%----------------------------------------------------
%        previewIMGSTACK
%----------------------------------------------------
function previewIMGSTACK(IMGSTACK)
disableButtons; pause(.02);

    % memocon('PREVIEWING IMAGE STACK')
    
    totframes = size(IMGSTACK,3);
    
    previewStacknum = str2num(previewStacknumH.String);

    
    if totframes >= previewStacknum
    
        IMGi = IMGSTACK(:,:,1:previewStacknum);
    
    
        [IMGcMax, IMGcMaxInd] = max(IMGSTACK(:));
        [IMGcMin, IMGcMinInd] = min(IMGSTACK(:));    
        % [I,J,tmp1] = ind2sub(size(IMG),cb1)
        % IMG(I,J,tmp1)

        axes(haxGRIN)
        phGRIN = imagesc(IMGi(:,:,1),'Parent',haxGRIN,'CDataMapping','scaled');
        cmax = max(max(max(IMGi)));
        cmin = min(min(min(IMGi)));
        memocon(['cmin :  ' num2str(cmin)])
        memocon(['cmax :  ' num2str(cmax)])
        cmax = cmax - abs(cmax/3);
        cmin = cmin + abs(cmin/3);
        haxGRIN.CLim = [cmin cmax];

        for nn = 1:previewStacknum

            phGRIN.CData = IMGi(:,:,nn);

            pause(.04)
        end
    
    

        % VISUALIZE AND ANNOTATE
        % fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        % fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGt)));
        % GRINcompare(IMG, IMGt, previewNframes)
        % mainguih.HandleVisibility = 'off';
        % close all;
        % mainguih.HandleVisibility = 'on';
    
    
    else
        
       memocon('Not enough images in 3rd dim to preview that many frames') 
        
    end

        
enableButtons        
% memocon('Preview completed!')
end


%----------------------------------------------------
%        previewIM
%----------------------------------------------------
function previewIM(I,varargin)

if nargin == 2
    ccut = varargin{1};
else
    ccut = .1;
end



    axes(haxGRIN)
    colormap(haxGRIN,parula)
    phGRIN = imagesc(I,'Parent', haxGRIN);
    axis tight; pause(.1)


    [cmax, ~] = max(I(:));
    [cmin, ~] = min(I(:));
    cmid = median([cmax,cmin]);
    IMAX = cmax - ((cmax-cmid)*ccut);
    IMIN = cmin + ((cmid-cmin)*ccut);
    if IMAX > IMIN
    haxGRIN.CLim = [IMIN IMAX];
    end






% disableButtons; pause(.02);
% 
%     % memocon('PREVIEWING IMAGE STACK')
%     
%     totframes = size(IMG,3);
%     
%     previewStacknum = str2num(previewStacknumH.String);
% 
%     
%     if totframes >= previewStacknum
%     
%         IMGi = IMG(:,:,1:previewStacknum);
%     
%     
%         [IMGcMax, IMGcMaxInd] = max(IMG(:));
%         [IMGcMin, IMGcMinInd] = min(IMG(:));    
%         % [I,J,tmp1] = ind2sub(size(IMG),cb1)
%         % IMG(I,J,tmp1)
%         
%         axes(haxGRIN)
%         phGRIN = imagesc(IMGi(:,:,1),'Parent',haxGRIN,'CDataMapping','scaled');
%         Imax = max(max(max(IMGi)));
%         Imin = min(min(min(IMGi)));
%         memocon(['cmin :  ' num2str(cmin)])
%         memocon(['cmax :  ' num2str(cmax)])
%         cmax = Imax - (Imax-Imin)/12;
%         cmin = Imin + (Imax-Imin)/12;
%         
%         if cmax > cmin
%             haxGRIN.CLim = [cmin cmax];
%         end
% 
%         for nn = 1:previewStacknum
% 
%             phGRIN.CData = IMGi(:,:,nn);
% 
%             pause(.01)
%         end
%     
%     
% 
%         % VISUALIZE AND ANNOTATE
%         % fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
%         % fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGt)));
%         % GRINcompare(IMG, IMGt, previewNframes)
%         % mainguih.HandleVisibility = 'off';
%         % close all;
%         % mainguih.HandleVisibility = 'on';
%     
%     
%     else
%         
%        memocon('Not enough images in 3rd dim to preview that many frames') 
%         
%     end
% 
%         
% enableButtons        
% % memocon('Preview completed!')
end















%% ------------------------- IMAGE PROCESSING ------------------------------



%----------------------------------------------------
%        SMOOTH IMAGES
%----------------------------------------------------
function smoothimg(hObject, eventdata)    
disableButtons; 
smoothimgH.FontWeight = 'bold';
pause(.02);




    % PERFORM IMAGE SMOOTHING
    memocon(' '); memocon('PERFORMING IMAGE SMOOTHING')

    
    smoothSD = str2num(smoothimgnumH.String);
    % smoothHeight = .8;
    % smoothWidth = 9;
    % smoothSD = .16;
    % smoothRes = .1;
    

    % GRINmask([PEAK HEIGHT] [WIDTH] [SLOPE SD] [RESOLUTION] [doPLOT])
    % Mask = GRINkernel(.8, 9, .14, .1, 1);
    Mask = GRINkernel(smoothHeight, smoothWidth, smoothSD, smoothRes, 1);
    pause(.2)

    
        
    mbh = waitbar(.5,'Performing convolution smoothing, please wait...');

    IMGc = convn( IMG, Mask,'same');
    
    waitbar(.8); close(mbh);

        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size:  % s \n\n', num2str(size(IMGc)));
        % GRINcompare(IMG, IMGc, previewNframes)
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGc;
    
        previewStack

        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        XLSD.sizeIMG = size(IMG);

        
        
IMhist.smoothed = 1;        
smoothimgH.FontWeight = 'normal';
pause(.02);
enableButtons        
memocon('Image smoothing completed!')
end






%----------------------------------------------------
%        CROP IMAGES
%----------------------------------------------------
function cropimg(hObject, eventdata)
disableButtons; 
cropimgH.FontWeight = 'bold';
pause(.02);

    % TRIM EDGES FROM IMAGE
    memocon(' '); memocon('TRIMMING EDGES FROM IMAGE')
    
    
    cropAmount = str2num(cropimgnumH.String);

    IMGt = IMG((cropAmount+1):(end-cropAmount) , (cropAmount+1):(end-cropAmount) , :);

        % VISUALIZE AND ANNOTATE        
        st1 = {'rows(y)';'cols(x)';'frames'};
        sp1 = sprintf('\n  % 34.10s % s % s  \n', st1{1:3});
        sp2 = sprintf('\n Imported image was size: %6.0f %8.0f %8.0f  \n', size(IMG));
        sp3 = sprintf('\n Trimmed image is size: %8.0f %8.0f %8.0f  \n', size(IMGt));
        disp([sp1 sp2 sp3])
        st1 = {'rows(y)';'cols(x)';'frames'};
        sp1 = sprintf('% 32.10s % s % s', st1{1:3});
        sp2 = sprintf('Imported image size: %6.0f %8.0f %8.0f', size(IMG));
        sp3 = sprintf('Trimmed image size: %8.0f %8.0f %8.0f', size(IMGt));
        disp([sp1 sp2 sp3])        
        
        % fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        % fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGt)));
        % GRINcompare(IMG, IMGt, previewNframes)
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGt;
    
    IMGraw = IMGt(:,:,1);
    
    reshapeData
    
    for nn = 1:size(INFO.tf,2)
        
        IMGSraw(:,:,:,nn) = squeeze(mean(IMG(:,:,:,INFO.tf(:,nn)),4));
    
    end
    
    % IMGSraw = IMG(:,:,[1, XLSD.CSonsetFrame, XLSD.CSoffsetFrame, size(IMG,3)],:);
    IMG = IMGt;
    XLSD.sizeIMG = size(IMG);
    % unshapeData
    
    
        previewStack
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        update_IMGfactors()
        
        XLSD.cropAmount = cropAmount;
        XLSD.sizeIMG = size(IMG);
        
        
        
IMhist.cropped = 1;
cropimgH.FontWeight = 'normal';
pause(.02);
enableButtons        
memocon('Crop Images completed!')
end






%----------------------------------------------------
%        CREATE IMAGE TILES BLOCKS
%----------------------------------------------------
function imgblocks(hObject, eventdata)
disableButtons; 
imgblocksH.FontWeight = 'bold';
pause(.02);


    % CREATE IMAGES TILES PER ROBERT'S SPEC
    memocon('SEGMENTING IMGAGES INTO TILES')

    
        update_IMGfactors()
    blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
        fprintf('\n\n Tile Size: % s \n\n', num2str(blockSize));
        memocon(sprintf('Tile Size: % s ', num2str(blockSize)));

    IMGb = zeros(size(IMG));
    sz = size(IMG,3);
    
    %-------------------------
    tv1 = 1:blockSize:size(IMG,1);
    tv2 = 0:blockSize:size(IMG,1);
    tv2(1) = [];
    
    progresstimer('Segmenting images into blocks...')
    for nn = 1:sz
      for cc = 1:numel(tv1)
        for rr = 1:numel(tv1)

          mbloc = IMG( tv1(rr):tv2(rr), tv1(cc):tv2(cc) , nn );
          mu = mean(mbloc(:));
        
          IMGb( tv1(rr):tv2(rr), tv1(cc):tv2(cc) , nn ) = mu;
        
        end
      end
    if ~mod(nn,100); progresstimer(nn/sz); end    
    end
    %-------------------------
    
    
    
    
% PREVIOUS IMPLEMENTATION OF THE LOOP ABOVE USING blockproc()
%     fun = @(block_struct) mean(block_struct.data(:)) * ones(size(block_struct.data)); 
%     progresstimer('Segmenting images into blocks...')
%     % hwb = waitbar(0,'Segmenting image into tiles...');
%     for nn = 1:sz
% 
%         IMGb(:,:,nn) = blockproc(IMG(:,:,nn),[blockSize blockSize],fun);
%         
%         if ~mod(nn,100)
%             % waitbar(nn/sz)
%             progresstimer(nn/sz)
%         end
%     
%     end
    
        % close(hwb)
        % VISUALIZE AND ANNOTATE
        
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGb)));
        memocon(sprintf('IMG matrix previous size: % s ', num2str(size(IMG))));
        memocon(sprintf('IMG matrix current size: % s ', num2str(size(IMGb))));
        
        % GRINcompare(IMG, IMGb, previewNframes)
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGb;
    
        previewStack
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        
        XLSD.blockSize = blockSize;
        XLSD.sizeIMG = size(IMG);
        

        
IMhist.tiled = 1;
imgblocksH.FontWeight = 'normal';
pause(.02);
enableButtons
memocon('Block-Segment Images completed!')        
end





%--------------------------------------------
%        IMGBLOCKS POPUP MENU CALLBACK
%--------------------------------------------
function imgblockspopup(hObject, eventdata)
        
    blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
    
    fprintf('\n\n New tile size: % s \n\n', num2str(blockSize));
    memocon(sprintf('New tile size: % s ', num2str(blockSize)));
    
    % imgblockspopupH.String
    % imgblockspopupH.Value

end



%--------------------------------------------
%  GET FACTORS DIVIDE EVENLY INTO size(IMG,1)
%--------------------------------------------
function update_IMGfactors()
    
    szIMG = size(IMG,1);
        
    s=1:szIMG;
    
    IMGfactors = s(rem(szIMG,s)==0);
    
    imgblockspopupH.String = IMGfactors;
    
    
    
    if ~mod(szIMG,10)        
        
        imgblockspopupH.Value = find(IMGfactors==(szIMG/10));
        blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
    
%     if any(IMGfactors == 22)
%         
%         imgblockspopupH.Value = find(IMGfactors==22);
%         blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
        
    elseif numel(IMGfactors) > 2

        imgblockspopupH.Value = round(numel(IMGfactors)/2)+1;
        blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
        
    else
        
        imgblockspopupH.Value = ceil(numel(IMGfactors)/2);
        blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
    
    end
    

    % fprintf('\n\n New tile size: % s \n\n', num2str(blockSize));

end







%----------------------------------------------------
%        RESHAPE DATA BY TRIALS
%----------------------------------------------------
function reshapeData(hObject, eventdata)
disableButtons; 
reshapeDataH.FontWeight = 'bold';
pause(.02);


    % RESHAPE IMAGE STACK INTO SIZE: YPIXELS by XPIXELS in NFRAMES per NTRIALS
    memocon(' '); memocon('Reshaping dataset to 4D');
    
    IMGrs = reshape(IMG,size(IMG,1),size(IMG,2),framesPerTrial,[]);
        
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGrs)));
        memocon(sprintf('IMG matrix previous size: % s ', num2str(size(IMG))));
        memocon(sprintf('IMG matrix current size: % s ', num2str(size(IMGrs))));
    
    IMG = IMGrs;
        
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        
        XLSD.sizeIMG = size(IMG);

IMhist.reshaped = 1;
reshapeDataH.FontWeight = 'normal';
pause(.02);
enableButtons
memocon('Reshape stack by trial completed!')
end






%----------------------------------------------------
%        UNDO RESHAPE DATA
%----------------------------------------------------
function unshapeData(hObject, eventdata)
disableButtons; pause(.02);

    % RESHAPE IMAGE STACK INTO SIZE: YPIXELS by XPIXELS in NTOTALFRAMES
    memocon(' '); memocon('Converting back to 3D stack'); 
    
    IMGr = reshape(IMG,size(IMG,1),size(IMG,2),[]);
        
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGr)));
    
    IMG = IMGr;
        
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);
        
        XLSD.sizeIMG = size(IMG);

IMhist.reshaped = 0;
enableButtons
memocon('Undo reshape completed!')
end






%----------------------------------------------------
%        ALIGN CS FRAMES BY CS ONSET
%----------------------------------------------------
function alignCSframes(hObject, eventdata)
% disableButtons;
alignCSFramesH.FontWeight = 'bold';
pause(.02);




    % MAKE DELAY TO CS EQUAL TO t SECONDS FOR ALL TRIALS
    fprintf('\n\n MAKING CS DELAY EQUAL TO [ % s  ]SECONDS FOR ALL TRIALS'...
        , alignCSFramesnumH.String);
    memocon(sprintf('Setting CS delay to %s seconds for all trials',...
        alignCSFramesnumH.String));

    % Make all CS onsets this many seconds from trial start
    CSonsetDelay = str2num(alignCSFramesnumH.String);
    CSonsetFrame = round(CSonsetDelay .* framesPerSec);
    CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);


    EqualizeCSdelay  = round((delaytoCS-CSonsetDelay) .* framesPerSec);

    IMGe = IMG;
    for nn = 1:size(IMG,4)

        IMGe(:,:,:,nn) = circshift( IMGe(:,:,:,nn) , -EqualizeCSdelay(nn) ,3);

    end
    
    
    
    % DETERMINE FIRST AND LAST FRAME FOR CS / US FOR EACH TRIAL
    CSonset   = round(CSonsetDelay .* framesPerSec);               % CS first frame in trial
    CSoffset  = round((CSonsetDelay+CS_length) .* framesPerSec);   % CS last frame in trial
    USonset   = round((CSonsetDelay+CS_length+1) .* framesPerSec); % US first frame in trial
    USoffset  = round((CSonsetDelay+CS_length+2) .* framesPerSec); % US last frame in trial
    CSUSonoff = [CSonset CSoffset USonset USoffset];
    
    INFO.CSUSonoff = CSUSonoff;
    
    fprintf(['\n\n (in frames)...\n   CSon: % 6.1d \n   CSoff: % 5.1d ',...
             '\n   USon: % 6.1d \n   USoff: % 5.1d '],CSUSonoff);
    
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGe)));
    
    IMG = IMGe;
    
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        XLSD.CSonsetFrame = CSonsetFrame;
        XLSD.CSoffsetFrame = CSoffsetFrame;


IMhist.aligned = 1;
alignCSFramesH.FontWeight = 'normal';
pause(.02);
enableButtons
memocon('Align frames by CS onset completed!')
end





%----------------------------------------------------
%        deltaF OVER F
%----------------------------------------------------
function dFoverF(hObject, eventdata)
disableButtons; 
dFoverFH.FontWeight = 'bold';
pause(.02);

% IMG = IMGIM;


    baselineTime   =  XLSD.baselineTime;
    framesPerSec   =  XLSD.framesPerSec;
    CSonsetFrame   =  XLSD.CSonsetFrame;
    framesPerTrial =  XLSD.framesPerTrial;


    disp(size(IMG))

    IMG3D = reshape(IMG,size(IMG,1),size(IMG,2),[]);      disp(size(IMG3D))

    muIMG = mean(IMG3D(:,:,1:CSonsetFrame,:),3);          disp(size(muIMG))

    IMbase = repmat(muIMG,1,1,size(IMG3D,3),1);          disp(size(IMbase))

    IMGdf = (IMG3D - IMbase) ./ IMbase;                   disp(size(IMGdf))
    
    IMG4D = reshape(IMGdf,size(IMGdf,1),size(IMGdf,2),framesPerTrial,[]);
    disp(size(IMG4D))


    IMG = IMG4D;

    previewStack(.1,IMG)
    axes(haxGRIN)
    previewIM(  mean(mean(IMG,4),3)  ,.2)


    %size(mean(IMG,4))
    %size(mean(IMG,3))
    %size( mean(mean(IMG,4),3)  )

    





% dF/F  vs  Zscore  vs  Dprime
%-----------------------------------
%{
if strcmp(NormType,'dF')
    
    memocon(' '); memocon('Computing dF/F for all frames...')
    muIMG = mean(IMG(:,:,1:CSonsetFrame,:),3);
    im = repmat(muIMG,1,1,size(IMG,3),1);
    IMGf = (IMG - im) ./ im;    
    IMG = IMGf;
    
elseif strcmp(NormType,'Zscore')
    
    zIMG = std(IMG(:,:,1:CSonsetFrame,:), 0,3);
    zm = repmat(zIMG,1,1,size(IMG,3),1);
    muIMG = mean(IMG(:,:,1:CSonsetFrame,:),3);
    im = repmat(muIMG,1,1,size(IMG,3),1);
    IMGz = (IMG - im) ./ zm;
    IMG = IMGz;
    
elseif strcmp(NormType,'Dprime')
    
    muIMG = mean(IMG(:,:,1:CSonsetFrame,:),3);
    im = repmat(muIMG,1,1,size(IMG,3),1);
    IMGd = (IMG - im) ./ ((IMG + im)./2);
    IMG = IMGd;

end
%}

        


IMhist.normalized = 1;
dFoverFH.FontWeight = 'normal';
pause(.02);
enableButtons
memocon('dF/F computation completed!')
end



%----------------------------------------------------
%        Z normalize
%----------------------------------------------------
function Znormalize(hObject, eventdata)
disableButtons; 
ZnormalizeH.FontWeight = 'bold';
pause(.02);



    % COMPUTE Z FOR ALL FRAMES
    memocon(' '); memocon('Performing Z-score normalization for all frames...')
    

        zIMG = std(IMG(:,:,1:round(baselineTime*framesPerSec),:),3);
        zm = repmat(zIMG,1,1,size(IMG,3),1);
        
        muIMG = mean(IMG(:,:,1:round(baselineTime*framesPerSec),:),3);
        im = repmat(muIMG,1,1,size(IMG,3),1);
        
        IMGz = (IMG - im) ./ zm;
        
        % IMGf = (IMG - im) ./ im;

    
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGz)));
        % GRINcompare(IMG, IMGf, previewNframes, [.98 1.05], [8 2])
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGz;
    
        previewStack
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        

IMhist.normalized = 1;
ZnormalizeH.FontWeight = 'normal';
pause(.02);
enableButtons
memocon('Z-score normalization completed!')
end





%----------------------------------------------------
%        GET TIMEPOINT MEANS
%----------------------------------------------------
function timepointMeans(hObject, eventdata)
disableButtons; 
timepointMeansH.FontWeight = 'bold';
pause(.02);
    
    memocon(' '); memocon('Computing trial means...'); 
    
    % AVERAGE ACROSS SAME TIMEPOINTS
    nCSUS = size(INFO.tf,2);
    szIMG = size(IMG);
    
    % Check that input is 4D
    if numel(szIMG) ~= 4
        ms = {'Stack must be 4D to compute timepoint means',...
              ['Stack is currently: ' num2str(szIMG)]};
        msgbox(ms, 'invalid stack size','custom',imgLogo(80:140,60:120,:));
        return
    end
    
    
    
    % Perform averaging for each (nCSUS) unique trial type
    % This will create a matrix 'muIMGS' of size [h,w,f,nCSUS]
    muIMGS = zeros(szIMG(1), szIMG(2), szIMG(3), nCSUS);
    for tt = 1:nCSUS
        im = IMG(:,:,:,INFO.tf(:,tt));
        muIMGS(:,:,:,tt) = squeeze(mean(im,4));
    end
    
    

        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix retains size: % s ', num2str(size(IMG)));
        fprintf('\n muIMGS matrix is now size: % s \n\n', num2str(size(muIMGS)));

        % previewIMGSTACK(muIMGS)
        previewStack(.1,muIMGS)
        

timepointMeansH.FontWeight = 'normal';
pause(.02);
enableButtons        
memocon('Compute same-timepoint means completed!')
end





%----------------------------------------------------
%        RUN ALL IMAGE PROCESSING FUNCTIONS
%----------------------------------------------------
function runallIP(hObject, eventdata)
disableButtons; pause(.02);
conon
        

    if checkbox1H.Value
        smoothimg
    end
    
    if checkbox2H.Value
        cropimg
    end
    
    if checkbox3H.Value
        imgblocks
    end

    if checkbox4H.Value
        reshapeData
    end

    if checkbox5H.Value
        alignCSframes
    end

    if checkbox6H.Value
        dFoverF
    end

    if checkbox7H.Value
        timepointMeans
    end
    
    XLSD.sizeIMG = size(IMG);

    disp('memocon(''XLSD'') >>')
    disp(XLSD)

memocon('ALL PROCESSING COMPLETED!')
conoff
enableButtons        
end









%% ------------------------- PLOTS FIGURES GRAPHS ------------------------------


%----------------------------------------------------
%        GET ROI STATISTICS
%----------------------------------------------------
function openROITOOLBOX(hObject, eventdata)
% disableButtons; pause(.02);


    if size(muIMGS,1) < 1
       
        msgbox('DATA HAS NOT BEEN PROCESSED'); 
        
        enableButtons
        
        return
        
    end
    
    memocon('Opening ROI TOOLBOX')
    
    % mainguih.HandleVisibility = 'off';
    % close all;
    % set(mainguih, 'Visible', 'Off');
    
    graphguih = ROITOOLBOXGUI(IMG, INFO, GRINtable, XLSD, IMGraw, IMGSraw, muIMGS, LICK);
    
    
    
%     waitfor(graphguih)
%     mainguih.HandleVisibility = 'off';
%     close all;
%     mainguih.HandleVisibility = 'on';
    
%     close all;
%     mainguih.HandleVisibility = 'on';
%     set(mainguih, 'Visible', 'On');
    
enableButtons
% memocon('Compute ROI statistics!')
end












%----------------------------------------------------
%        GET ROI STATISTICS
%----------------------------------------------------
function getROIstats(hObject, eventdata)
disableButtons; pause(.02);


    if size(muIMGS,1) < 1
       
        msgbox('DATA HAS NOT BEEN PROCESSED'); 
        
        enableButtons
        
        return
        
    end

    
    % PREVIEW AN ROI FOR A SINGLE CSUS AVERAGED OVER TRIALS
    memocon(' '); memocon('GETTING ROI STATISTICS'); 

    fh1=figure('Units','normalized','OuterPosition',[.40 .22 .59 .75],'Color','w');
    hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[]);

    ih1 = imagesc(muIMGS(:,:,1,1));

    memocon('Use mouse to trace around a region of interest on the figure.')
    hROI = imfreehand(hax1);   
    ROIpos = hROI.getPosition;
    ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));


    ROImask = hROI.createMask(ih1);
    
    ROI_INTENSITY = muIMGS(:,:,1,1) .* ROImask;
    figure; imagesc(ROI_INTENSITY); colorbar;




    % Here we are computing the average intensity for the selected ROI
    % N.B. here it is assumed that a pixel value (actually dF/F value)
    % has virtually a zero probability of equaling exactly zero; this
    % allows us to multiply the mask T/F matrix by the image matrix
    % and disclude from the average all pixels that equal exactly zero
    
    ROImu = zeros(size(muIMGS,4),size(muIMGS,3));
    for mm = 1:size(muIMGS,4)
        for nn = 1:size(muIMGS,3)
        
        ROI_INTENSITY = muIMGS(:,:,nn,mm) .* ROImask;
        ROImu(mm,nn) = mean(ROI_INTENSITY(ROI_INTENSITY ~= 0));

        end
    end

    CSUSplot(ROImu', INFO);
    % CSUSplot(ROImu', INFO, CSUSonoff);
    % previewstack(squeeze(muIMGS(:,:,:,1)), CSUSonoff, ROImu)
    
    
    
    
enableButtons
memocon('Compute ROI statistics completed!')
end





%----------------------------------------------------
%        PLOT TILE STATS DATA
%----------------------------------------------------
function plotTileStats(hObject, eventdata)
% disableButtons; pause(.02);
clc

    memocon(' '); memocon('PLOTTING TILE STATS DATA (PLEASE WAIT)...'); 
    

% % Perform averaging for each (nCSUS) unique trial type
% % This will create a matrix 'muIMGS' of size [h,w,f,nCSUS]
%
%     muIMGS = zeros(szIMG(1), szIMG(2), szIMG(3), nCSUS);
%     for tt = 1:nCSUS
%         im = IMG(:,:,:,INFO.tf(:,tt));
%         muIMGS(:,:,:,tt) = squeeze(mean(im,4));
%     end
%



    CSUSonoff = INFO.CSUSonoff;

    %blockSize = str2num(string(imgblockspopupH.String(imgblockspopupH.Value,:)));
    blockSize = XLSD.blocksize;


    size(muIMGS)

    pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);

    pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    CSids = unique(INFO.csus);
    

    size(pxl)
    size(pixels)
    
    %-------------------------- MULTI-TILE FIGURE --------------------------

    fh10=figure('Units','normalized','OuterPosition',[.02 .02 .90 .90],'Color','w');
    
    set(fh10,'ButtonDownFcn',@(~,~)memocon('figure'),...
   'HitTest','off')
    
    
    
    aXlocs =  (0:(size(pxl,1))) .* (1/(size(pxl,1)));
    aXlocs(end) = [];
    aYlocs =  (0:(size(pxl,2))) .* (1/(size(pxl,2)));
    aYlocs(end) = [];
    aXlocs = aXlocs+.005;
    aYlocs = aYlocs+.005;
    [aX,aY] = meshgrid(aXlocs,aYlocs);
    
    if strcmp(NormType,'dF')
        
        YL = [-.15 .15];

    elseif strcmp(NormType,'Zscore')
        
        YL = [-2 4];
        
    elseif strcmp(NormType,'Dprime')
        
        YL = [-.15 .15];
        
    else
        YL = 'auto';
    end
    

    % PLOT ALL THE TILES ON A SINGLE FIGURE WINDOW. THIS PLOTS THE FIRST
    % AXIS IN THE BOTTOM LEFT CORNER AND FIRST FILLS UPWARD THEN RIGHTWARD
    for ii = 1:size(pixels,1)

        axh{ii} = axes('Position',[aX(ii) aY(ii) (1/(size(pxl,1)+1)) (1/(size(pxl,2)+1))],...
        'Color','none','Tag',num2str(ii)); 
        % axis off;
        hold on;
    
        % h = squeeze(pixels(ii,:,:));
        tiledatX{ii} = 1:size(pixels,2);
        tiledatY{ii} = squeeze(pixels(ii,:,:));
        
        pha{ii} = plot( 1:size(pixels,2) , squeeze(pixels(ii,:,:)));
        % set(gca,'YLim',YL)
        ylim(YL)
        cYlim = get(gca,'YLim');
        line([CSUSonoff(1) CSUSonoff(1)],cYlim,'Color',[.8 .8 .8])
        line([CSUSonoff(2) CSUSonoff(2)],cYlim,'Color',[.8 .8 .8])
        
        
        set(axh{ii},'ButtonDownFcn',@(~,~)disp(gca),...
        'HitTest','on')
        
    end
        pause(.05)
    
    % INCREASE LINE WIDTH CHENYU
    for ii = 1:size(pha,2)
        for jj = 1:size(pha{ii},1)
            pha{ii}(jj).LineWidth = 3;
        end
    end
    
    
    %keyboard
    % REMOVE AXES CLUTTER
    %axh{ii}
    
    
    
    
    
    legpos = {  [0.01,0.95,0.15,0.033], ...
                [0.01,0.92,0.15,0.033], ...
                [0.01,0.89,0.15,0.033], ...
                [0.01,0.86,0.15,0.033], ...
                [0.01,0.83,0.15,0.033], ...
                [0.01,0.80,0.15,0.033], ...
                };
    
    pc = {pha{1}.Color};
    pt = CSids;
    
    for nn = 1:size(pixels,3)
        
    annotation(fh10,'textbox',...
    'Position',legpos{nn},...
    'Color',pc{nn},...
    'FontWeight','bold',...
    'String',pt(nn),...
    'FontSize',12,...
    'FitBoxToText','on',...
    'EdgeColor',pc{nn},...
    'FaceAlpha',.8,...
    'Margin',3,...
    'LineWidth',1,...
    'VerticalAlignment','bottom',...
    'BackgroundColor',[1 1 1]);
    
    end
    
    annotation(fh10,'textbox',...
    'Position',[.85 .975 .15 .04],...
    'Color',[0 0 0],...
    'FontWeight','bold',...
    'String','RIGHT-CLICK ANY GRAPH TO EXPAND',...
    'FontSize',10,...
    'FitBoxToText','on',...
    'EdgeColor','none',...
    'FaceAlpha',.7,...
    'Margin',3,...
    'LineWidth',2,...
    'VerticalAlignment','bottom',...
    'BackgroundColor',[1 1 1]);


    annotation(fh10,'textbox',...
    'Position',[.01 .975 .15 .04],...
    'Color',[0 0 0],...
    'FontWeight','bold',...
    'String',INFO.file,...
    'FontSize',12,...
    'FitBoxToText','on',...
    'EdgeColor','none',...
    'FaceAlpha',.7,...
    'Margin',3,...
    'LineWidth',2,...
    'VerticalAlignment','bottom',...
    'Interpreter','none',...
    'BackgroundColor',[1 1 1]);
    
    
    % haxN = axes('Position',[.001 .001 .99 .99],'Color','none');
    % axis off; hold on;
    pause(.2)
    %-------------------------------------------------------------------------
    

    hcmenu = uicontextmenu;

    item1 = uimenu(hcmenu,'Label','OPEN IN ADVANCED PLOT GUI','Callback',@plottile);

    haxe = findall(fh10,'Type','axes');

         % Attach the context menu to each axes
    for aa = 1:length(haxe)
        set(haxe(aa),'uicontextmenu',hcmenu)
    end   
        

    
    
    
    
    
    gridbutton = uicontrol(fh10,'Units','normalized',...
                  'Position',[.01 .01 .1 .05],...
                  'String','Toggle Grid',...
                  'Tag','gridbutton',...
                  'Callback',@toggleGridOverlay);
    
    
    savetilesH = uicontrol(fh10,'Units','normalized',...
                  'Position',[.90 .01 .1 .05],...
                  'String','Save Tile Data',...
                  'Tag','gridbutton',...
                  'Callback',@savetilesfun);    
    
    
    
%     % Add 'doprint' checkbox before implementing this code
%     print(fh10,'-dpng','-r300','tilefig')
%     
%     hFig = figure('Toolbar','none',...
%               'Menubar','none');
%     hIm = imshow('tilefig.png');
%     hSP = imscrollpanel(hFig,hIm);
%     set(hSP,'Units','normalized',...
%         'Position',[0 .1 1 .9])        
        
        
enableButtons
memocon('PLOTTING TILE STATS DATA COMPLETED!')

end





%----------------------------------------------------
%        PLOT TILE CALLBACK - LAUNCH TILEplotGUI.m
%----------------------------------------------------
function plottile(hObject, eventdata)
% disableButtons; pause(.02);

    axdat = gca;
    
    axesdata = axdat.Children;
    
    TILEplotGUI(axesdata, INFO, XLSD, LICK)
 
end





%----------------------------------------------------
%        PLOT TILE CALLBACK - LAUNCH TILEplotGUI.m
%----------------------------------------------------
function savetilesfun(hObject, eventdata)
% disableButtons; pause(.02);


    % tiledatX
    
    for nn = 1:length(tiledatY)
        maxT(nn) = max(max(tiledatY{nn}));
    end
    
    TILE = tiledatY;
    
    uisave({'TILE','INFO','XLSD'},...
           ['TILE_' INFO.file(1:end-4)]);
 
end





%----------------------------------------------------
%        RUN PCA
%----------------------------------------------------
function runPCA(hObject, eventdata)
% disableButtons; pause(.02);


t1=[];
t2=[];
t3=[];
t4=[];


hb = round(blockSize / 2);

PIM = IMG( hb:blockSize:end, hb:blockSize:end, : , : );

size(PIM)


CSp = squeeze(PIM(:,:,:,INFO.tf(:,2)));

CSm = squeeze(PIM(:,:,:,INFO.tf(:,1)));


size(CSp)
size(CSm)


CSp = CSp(3:7,3:7,:,:);
CSm = CSm(3:7,3:7,:,:);

szCSp = size(CSp)
szCSm = size(CSm)


CSP = squeeze(reshape(CSp,[],1,szCSp(3),szCSp(4)));
CSM = squeeze(reshape(CSm,[],1,szCSm(3),szCSm(4)));

size(CSP)
size(CSM)

CSplus  = CSP;
CSminus = CSM;

% save('GRINDATA.mat','CSplus','CSminus')

keyboard

size(CSP)
size(CSM)


figure
imagesc(CSM(:,:,1))

keyboard

%%
X = [];
Y = [];

Y = rand(10,100) .* .01;

figure
plot(Y')

X = X - mean(X);


covMX = 1/(n-1) * sum((X - mean(X)) * (X - mean(X))');






%%

INFO.TreatmentGroups{1}
size(CSm)

INFO.TreatmentGroups{2}
size(CSp)





% PCAdata = permute(CSM,[3 1 2]);
PCAdata = CSM;

size(PCAdata)


MaxComponents = 10;
opt = statset('pca');
opt.MaxIter = 5000;

[PCAScof,PCAval,PCAlat,PCAtsq,PCAexp,PCAmu] = pca( PCAdata ,...
    'Options',opt,'NumComponents',MaxComponents);



disp(PCAexp)


figure
plot(PCAScof(:,1:2))
hold on

figure
plot(PCAval)

x = repmat((1:size(PCAScof,1))',1,2);

scatter( x(:)  ,  PCAScof(:) )



clc
sum(PCASexp(:))

% format shortG
% PCASval(1:5 , :)












% [PCAScof,PCASval,PCAlat,PCAtsq,PCASexp,PCAmu] = pca(...
%     PCAdata,'Options',opt,'Algorithm','svd','NumComponents',Ncomps,'Centered',false);

% PCAStopcof = PCAScof(1,:);
% PCAScentered = PCASval*PCAScof';
% PCAStsredu = mahal(PCASval,PCASval);
% PCAStsqdiscard = PCASts - PCAStsredu;


% size(PIM)
% size(IMG)
% size(muIMGS)
% INFO.tf
% XLSD
% blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
% pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);
% pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
% CSids = unique(INFO.csus);
% for ii = 1:size(pixels,1)
%     tiledatX{ii} = 1:size(pixels,2);
%     tiledatY{ii} = squeeze(pixels(ii,:,:));
%     pha{ii} = squeeze(pixels(ii,:,:));
% end
% ii = 48;
% PCAdata = squeeze(pixels(ii,:,:))';





enableButtons        
memocon('Run custom function completed!')
end







%----------------------------------------------------
%    ADVANCED PLOTTING GUI - LAUNCH GRINplotGUI.m
%----------------------------------------------------
function plotGUI(hObject, eventdata)
% disableButtons; pause(.02);

    if size(muIMGS,1) < 1
       
        msgbox('DATA HAS NOT BEEN PROCESSED'); 
        
        enableButtons
        
        return
        
    end
    
    GRINplotGUI(IMG, INFO, XLSD, LICK, IMGSraw)
 
end




%----------------------------------------------------
%        VIEW GRID OVERLAY
%----------------------------------------------------
function viewGridOverlay(hObject, eventdata)
% disableButtons; pause(.02);



    
    %-------------------------- IMGraw FIGURE GRID --------------------------
    
    blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
    
    fprintf('\n\n Grid size is% d pixels \n\n', blockSize)

    if length(muIMGS) < 1
        
        pxl = zeros(size(IMG,1) / blockSize);
        
    else
    
        pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);
        pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    end
    
    
    aXlocs =  (0:(size(pxl,1))) .* (1/(size(pxl,1)));
    aXlocs(end) = [];
    aYlocs =  (0:(size(pxl,2))) .* (1/(size(pxl,2)));
    aYlocs(end) = [];
    aXlocs = aXlocs+.005;
    aYlocs = aYlocs+.005;
    [aX,aY] = meshgrid(aXlocs,aYlocs);
    YL=[-.15 .15];
    
    
    hFig = figure('Units','normalized','OuterPosition',[.1 .1 .5 .8],'Color','w','MenuBar','none','Name','GRINGRID');
    axR = axes;
    phR = imagesc(IMGraw);
    grid on
    axR.YTick = [0:blockSize:size(IMGraw,1)];
    axR.XTick = [0:blockSize:size(IMGraw,1)];
    % axR.YTickLabel = 1:30;
    
    axR.GridAlpha = .8;
    axR.GridColor = [0.99 0.1 0.1];
    
        tv1 = 1:size(IMGraw,1);
        
        pause(.2)
        
        
        % NUMBERING IS TECHNICALLY INCORRECT SINCE BELOW AXIS #1 STARTS IN THE
        % BOTTOM LEFT CORNER AND GOES UP, AND HERE IT STARTS IN THE TOP
        % LEFT CORNER AND GOES DOWN. NOT SURE THAT IT MATTERS...
        for ii = 1:size(pxl,1)^2
            
            tv2 = [  aX(ii)*size(IMGraw,1)   aY(ii)*size(IMGraw,1)+2 ...
                    (1/(size(pxl,1)+1))     (1/(size(pxl,2)+1))];

            text(tv2(1),tv2(2),num2str(tv1(ii)),'Color','r','Parent',axR);
    
        end
        
     pause(.1)
    %-------------------------------------------------------------------------


%{

mjf = get(hFig, 'JavaFrame');
jWindow = mjf.fHG2Client.getWindow;
mjc = jWindow.getContentPane;
mjr = jWindow.getRootPane;
figTitle = jWindow.getTitle;
jFrame = javaObjectEDT(javax.swing.JFrame(figTitle));
jFrame.setUndecorated(true);
jFrame.setLocation(mjc.getLocationOnScreen);
jFrame.setSize(mjc.getSize);
jFrame.setContentPane(mjc);
jFrame.setVisible(true);


MUtilities.setFigureFade(gcf, 0.2)
 
hFig.Visible = 'off';
    
    
% jFrame.setVisible(false)





%------------------------------------

% Create a simple Matlab figure (visible, but outside monitor area)
t = 0 : 0.01 : 10;
hFig = figure('Name','Plot example', 'ToolBar','none', 'MenuBar','none');
hLine = plot(t, cos(t));
hButton = uicontrol('String','Close', 'Position',[307,0,45,16]);
 
% Ensure that everything is rendered, otherwise the following will fail
drawnow;
 
% Get the underlying Java JFrame reference handle
mjf = get(handle(hFig), 'JavaFrame');
jWindow = mjf.fHG2Client.getWindow;  % or: mjf.getAxisComponent.getTopLevelAncestor
 
% Get the content pane's handle
mjc = jWindow.getContentPane;
mjr = jWindow.getRootPane;  % used for the offset below
 
% Create a new pure-Java undecorated JFrame
figTitle = jWindow.getTitle;
jFrame = javaObjectEDT(javax.swing.JFrame(figTitle));
jFrame.setUndecorated(true);
 
% Move the JFrame's on-screen location just on top of the original
jFrame.setLocation(mjc.getLocationOnScreen);
 
% Set the JFrame's size to the Matlab figure's content size
%jFrame.setSize(mjc.getSize);  % slightly incorrect by root-pane's offset
jFrame.setSize(mjc.getWidth+mjr.getX, mjc.getHeight+mjr.getY);
 
% Reparent (move) the contents from the Matlab JFrame to the new JFrame
jFrame.setContentPane(mjc);
 
% Make the new JFrame visible
jFrame.setVisible(true);


MUtilities.setFigureFade(gcf, 0.5)
 
hFig.Visible = 'off';

%}


enableButtons
memocon('GRID OVERLAY HAS BEEN GENERATED.')
end







%----------------------------------------------------
%        TOGGLE GRID OVERLAY
%----------------------------------------------------
function toggleGridOverlay(hObject, eventdata)
% disableButtons; pause(.02);


    if toggrid == 1
        if isvalid(axGRID)
            try
            delete(axGRID.Children)
            delete(axGRID)
            catch
            toggrid = 0;
            end
        end
            toggrid = 0;
        return
    end
    toggrid = 1;
    
    %-------------------------- IMGraw FIGURE GRID --------------------------
    
    blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));
    
    fprintf('\n\n Grid size is% d pixels \n\n', blockSize)

    if length(muIMGS) < 1
        
        pxl = zeros(size(IMG,1) / blockSize);
        
    else
    
        pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);
        pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    end
    
    
    aXlocs =  (0:(size(pxl,1))) .* (1/(size(pxl,1)));
    aXlocs(end) = [];
    aYlocs =  (0:(size(pxl,2))) .* (1/(size(pxl,2)));
    aYlocs(end) = [];
    aXlocs = aXlocs+.005;
    aYlocs = aYlocs+.005;
    [aX,aY] = meshgrid(aXlocs,aYlocs);
    YL=[-.15 .15];
    
    
    
    %-------------------------------------------------------------------------

    axGRID = axes('Position',[.001 .001 .999 .999],'Color','none'); hold on;

    phR = imagesc(IMGraw,'Parent',axGRID,...
          'CDataMapping','scaled','AlphaData',0.6);
        axis image;  pause(.01)
        axis normal; pause(.01)
    
    
        axGRID.YTick = [0:blockSize:size(IMGraw,1)];
        axGRID.XTick = [0:blockSize:size(IMGraw,1)];
        
        axGRID.GridAlpha = .8;
        axGRID.GridColor = [0.99 0.1 0.1];
    

    
        tv1 = 1:size(IMGraw,1);
        
        pause(.2)
        
        
        % PLOT GRID IN A SINGLE FIGURE WINDOW TO OVERLAY ONTO TILE DATA
        % TO MATCH TILE AXES ORDERING, GRID NUMBERING STARTS IN THE BOTTOM LEFT 
        % CORNER OF THE FIGURE AND FIRST FILLS UPWARD THEN RIGHTWARD
        for ii = 1:size(pxl,1)^2
            
            tv2 = [  aX(ii)*size(IMGraw,1)   aY(ii)*size(IMGraw,1)+2 ...
                    (1/(size(pxl,1)+1))     (1/(size(pxl,2)+1))];

            text(tv2(1),tv2(2),num2str(tv1(ii)),'Color','r','Parent',axGRID);
    
        end
        
     pause(.1)
    %-------------------------------------------------------------------------

%     
%         keyboard
%     axGRID.YDir = 'reverse';
%     axis ij; axis xy;


enableButtons
memocon('GRID OVERLAY HAS BEEN GENERATED.')
end








%----------------------------------------------------
%        PLOT GROUP MEANS (CI ENVELOPE PLOT)
%----------------------------------------------------
function plotGroupMeans(hObject, eventdata)
% disableButtons; pause(.02);


%{
%     CSids = unique(INFO.csus);
%     
%     size(IMG)
%     meanIMG = squeeze(mean(IMG(:,:,CSUSonoff(1),INFO.tf(:,4)),4));
%     size(meanIMG)
%     
%         % Perform averaging for each (nCSUS) unique trial type
%     % This will create a matrix 'muIMGS' of size [h,w,f,nCSUS]
%     
%     muIMGS = zeros(szIMG(1), szIMG(2), szIMG(3), nCSUS);
%     for tt = 1:nCSUS
%         im = IMG(:,:,:,INFO.tf(:,tt));
%         muIMGS(:,:,:,tt) = squeeze(mean(im,4));
%     end
    


fh33=figure('Units','normalized','OuterPosition',[.1 .1 .7 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .55 .40 .40],'Color','none'); axis off; hold on;
hax2 = axes('Position',[.55 .55 .40 .40],'Color','none'); axis off; hold on;
hax3 = axes('Position',[.05 .05 .40 .40],'Color','none'); axis off; hold on;
hax4 = axes('Position',[.55 .05 .40 .40],'Color','none'); axis off; hold on;


meanIMG1 = squeeze(mean(IMG(:,:,CSUSonoff(1),INFO.tf(:,4)),4));
meanIMG2 = squeeze(mean(IMG(:,:,CSUSonoff(2),INFO.tf(:,4)),4));
meanIMG3 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,4)),4));
meanIMG4 = squeeze(mean(IMG(:,:,CSUSonoff(4),INFO.tf(:,4)),4));

axes(hax1)
imagesc(meanIMG1)
axes(hax2)
imagesc(meanIMG2)
axes(hax3)
imagesc(meanIMG3)
axes(hax4)
imagesc(meanIMG4)



fh34=figure('Units','normalized','OuterPosition',[.1 .1 .7 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .55 .40 .40],'Color','none'); axis off; hold on;
hax2 = axes('Position',[.55 .55 .40 .40],'Color','none'); axis off; hold on;
hax3 = axes('Position',[.05 .05 .40 .40],'Color','none'); axis off; hold on;
hax4 = axes('Position',[.55 .05 .40 .40],'Color','none'); axis off; hold on;

meanIMG1 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,1)),4));
meanIMG2 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,2)),4));
meanIMG3 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,3)),4));
meanIMG4 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,4)),4));

axes(hax1)
imagesc(meanIMG1)
axes(hax2)
imagesc(meanIMG2)
axes(hax3)
imagesc(meanIMG3)
axes(hax4)
imagesc(meanIMG4)

%}


    if size(muIMGS,1) < 1
       
        msgbox('Group means have not yet been calculated'); 
        
        return
        
    end

    memocon(' '); memocon('PLOTTING GROUP MEANS (PLEASE WAIT)...'); 
        
    fh1=figure('Units','normalized','OuterPosition',[.08 .08 .8 .8],'Color','w');
    hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax1.YLim = [-.15 .15];
    hax2 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax2.YLim = [-.15 .15];
    axis off; hold on;
    hax3 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax3.YLim = [-.15 .15];
    axis off; hold on;
    hax4 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax4.YLim = [-.15 .15];
    axis off; hold on;
    hax5 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax5.YLim = [-.15 .15];
    axis off; hold on;
    hax6 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax6.YLim = [-.15 .15];
    axis off; hold on;
    hax0 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax0.YLim = [-.15 .15];
    axis off; hold on;
    allhax = {hax1, hax2, hax3, hax4, hax5, hax6};
    colorz = {  [.99 .01 .01], ...
                [.01 .99 .01], ...
                [.01 .01 .99], ...
                [.99 .01 .99], ...
                [.99 .99 .01], ...
                [.01 .99 .99], ...
                };
    legpos = {  [0.75,0.85,0.15,0.06], ...
                [0.75,0.80,0.15,0.06], ...
                [0.75,0.75,0.15,0.06], ...
                [0.75,0.70,0.15,0.06], ...
                [0.75,0.65,0.15,0.06], ...
                [0.75,0.60,0.15,0.06], ...
                };

    
            

    blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));

    pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);

    pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    CSids = unique(INFO.csus);
    
    
    
    
    %-------------------------- CI ENVELOPE FIGURE --------------------------
    for nn = 1:size(pixels,3)
    
    pixCS = pixels(:,:,nn);
	
	Mu = mean(pixCS,1);
    Sd = std(pixCS,0,1);
    Se = Sd./sqrt(numel(Mu));
	y_Mu = Mu';
    x_Mu = (1:numel(Mu))';
    % e_Mu = Se';
    e_Mu = Sd';
	xx_Mu = 1:0.1:max(x_Mu);
	yy_Mu = spline(x_Mu,y_Mu,xx_Mu);
    ee_Mu = spline(x_Mu,e_Mu,xx_Mu);
    
    axes(allhax{nn})
    [ph1, po1] = envlineplot(xx_Mu',yy_Mu', ee_Mu','cmap',colorz{nn},...
                            'alpha','transparency', 0.6);
    hp1{nn} = plot(xx_Mu,yy_Mu,'Color',colorz{nn});
    pause(.2)
    
    % lh1{nn} = legend(allhax{nn},CSids(nn),'Position',legpos{nn},'Box','off');
    
    end
    
    text(1, -.12, ['CS ON/OFF US ON/OFF:  ', num2str(CSUSonoff)])
    
    leg1 = legend([hp1{:}],CSids);
	set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
    
        
    for mm = 1:4
    text(CSUSonoff(mm),allhax{nn}.YLim(1),{'\downarrow'},...
        'HorizontalAlignment','center','VerticalAlignment','bottom',...
        'FontSize',20,'FontWeight','bold')
    end
    line([CSUSonoff(1) CSUSonoff(1)],[allhax{nn}.YLim(1) allhax{nn}.YLim(2)])
    line([CSUSonoff(2) CSUSonoff(2)],[allhax{nn}.YLim(1) allhax{nn}.YLim(2)])
    pause(.1)
    %-------------------------------------------------------------------------
    
    
    
    
    
    
    
    
        
enableButtons
memocon('PLOTTING GROUP MEANS COMPLETED!')
end





%----------------------------------------------------
% VISUALIZE TRIAL BLOCKS AND CS / US ONSET / OFFSET
%----------------------------------------------------
function viewTrialTimings(hObject, eventdata)
    
    
    if length(delaytoCS) < 2
       
        msgbox('DATA HAS NOT BEEN IMPORTED'); 
        
        return
        
    end
    
trials = zeros(total_trials,round(secondsPerTrial));


for nn = 1:total_trials
    
    trials(nn,delaytoCS(nn):delaytoCS(nn)+10) = INFO.id(nn);
    
end

cm = [ 1  1  1
      .95 .05 .05
      .90 .75 .15
      .95 .05 .95
      .05 .95 .05
      .05 .75 .95
      .05 .05 .95
      .45 .45 .25
      ];

fh1=figure('Units','normalized','OuterPosition',[.1 .08 .8 .85],'Color','w');
hax1 = axes('Position',[.15 .05 .82 .92],'Color','none');
hax2 = axes('Position',[.15 .05 .82 .92],'Color','none','NextPlot','add');
axis off; hold on;

axes(hax1)
ih = imagesc(trials);
colormap(cm)
grid on
hax1.YTick = [.5:1:total_trials-.5];
hax1.YTickLabel = 1:total_trials;
hax1.XLabel.String = 'Time (seconds)';

hax1.YTickLabel = INFO.csus;
% hax1.YTickLabelRotation = 30;


% tv1 = [];
% tv2 = [];
% tv3 = [];
% tv4 = [];
% 
% tv1 = {'\color[rgb]{.95,.05,.05}'};
% tv1 = {'\color[rgb]{.90 .75 .15}'};
% tv1 = {'\color[rgb]{.95 .05 .95}'};
% tv1 = {'\color[rgb]{.9,.1,.1}'};
% tv1 = {'\color[rgb]{.9,.1,.1}'};
% tv1 = {'\color[rgb]{.9,.1,.1}'};
% 
% keyboard
% 
% tv2 = repmat(tv1,total_trials,1);
% 
% for nn=1:total_trials
% tv3{nn} = strcat(tv2{nn}, INFO.csus{nn});
% end
% 
% 
% hax1.YTickLabel = tv3{nn};
% 
% 
% % annotation(fh1,'textbox',...
% %     'Position',[.1 .1 .3 .3],...
% %     'String',tv3{nn},...
% %     'BackgroundColor',[1 1 1]);


end





%----------------------------------------------------
%        PLOT GROUP MEANS (CI ENVELOPE PLOT)
%----------------------------------------------------
function viewSameFrames(hObject, eventdata)
% disableButtons; pause(.02);


%     CSids = unique(INFO.csus);
%     
%     size(IMG)
%     meanIMG = squeeze(mean(IMG(:,:,CSUSonoff(1),INFO.tf(:,4)),4));
%     size(meanIMG)
%     
%         % Perform averaging for each (nCSUS) unique trial type
%     % This will create a matrix 'muIMGS' of size [h,w,f,nCSUS]
%     
%     muIMGS = zeros(szIMG(1), szIMG(2), szIMG(3), nCSUS);
%     for tt = 1:nCSUS
%         im = IMG(:,:,:,INFO.tf(:,tt));
%         muIMGS(:,:,:,tt) = squeeze(mean(im,4));
%     end
    


fh33=figure('Units','normalized','OuterPosition',[.1 .1 .7 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .55 .40 .40],'Color','none'); axis off; hold on;
hax2 = axes('Position',[.55 .55 .40 .40],'Color','none'); axis off; hold on;
hax3 = axes('Position',[.05 .05 .40 .40],'Color','none'); axis off; hold on;
hax4 = axes('Position',[.55 .05 .40 .40],'Color','none'); axis off; hold on;


meanIMG1 = squeeze(mean(IMG(:,:,CSUSonoff(1),INFO.tf(:,4)),4));
meanIMG2 = squeeze(mean(IMG(:,:,CSUSonoff(2),INFO.tf(:,4)),4));
meanIMG3 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,4)),4));
meanIMG4 = squeeze(mean(IMG(:,:,CSUSonoff(4),INFO.tf(:,4)),4));

axes(hax1)
imagesc(meanIMG1)
axes(hax2)
imagesc(meanIMG2)
axes(hax3)
imagesc(meanIMG3)
axes(hax4)
imagesc(meanIMG4)



fh34=figure('Units','normalized','OuterPosition',[.1 .1 .7 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .55 .40 .40],'Color','none'); axis off; hold on;
hax2 = axes('Position',[.55 .55 .40 .40],'Color','none'); axis off; hold on;
hax3 = axes('Position',[.05 .05 .40 .40],'Color','none'); axis off; hold on;
hax4 = axes('Position',[.55 .05 .40 .40],'Color','none'); axis off; hold on;

meanIMG1 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,1)),4));
meanIMG2 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,2)),4));
meanIMG3 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,3)),4));
meanIMG4 = squeeze(mean(IMG(:,:,CSUSonoff(3),INFO.tf(:,4)),4));

axes(hax1)
imagesc(meanIMG1)
axes(hax2)
imagesc(meanIMG2)
axes(hax3)
imagesc(meanIMG3)
axes(hax4)
imagesc(meanIMG4)




    line([CSUSonoff(1) CSUSonoff(1)],[allhax{nn}.YLim(1) allhax{nn}.YLim(2)])
    line([CSUSonoff(2) CSUSonoff(2)],[allhax{nn}.YLim(1) allhax{nn}.YLim(2)])
    pause(.1)
    %-------------------------------------------------------------------------
    

enableButtons
memocon('PLOTTING GROUP MEANS COMPLETED!')
end











%----------------------------------------------------
%        RUN CUSTOM FUNCTION
%----------------------------------------------------
function runCustomA(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION A!')
    
    [IMG] = stevesRedNormFun(IMG);

    [varargin] = grincustomA(IMG, INFO, GRINtable, XLSD, IMGraw, muIMGS, LICK);

enableButtons        
memocon('Run custom function completed!')
end

function runCustomB(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION B!')

    [varargin] = grincustomB(IMG, INFO, GRINtable, XLSD, IMGraw, muIMGS, LICK);

    
enableButtons        
memocon('Run custom function completed!')
end

function runCustomC(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION C!')

    [varargin] = grincustomC(IMG, INFO, GRINtable, XLSD, IMGraw, muIMGS, LICK);

    
enableButtons        
memocon('Run custom function completed!')
end

function runCustomD(hObject, eventdata)
% disableButtons; pause(.02);
    
    mainguih.HandleVisibility = 'off';
    close all;
    mainguih.HandleVisibility = 'on';
        
    memocon('RUNNING CUSTOM FUNCTION D!')

    % grincustomD(IMG, INFO, GRINtable, XLSD, IMGraw, IMGSraw, muIMGS, LICK);
    
    [Boundaries] = reverseSelectROI(IMG, INFO, GRINtable, XLSD, IMGraw, IMGSraw, muIMGS, LICK);
    
    
    
enableButtons        
memocon('Run custom function completed!')
end











%----------------------------------------------------
%        GET ALIGN
%----------------------------------------------------
function getAlign(hObject, eventdata)
% disableButtons; 
getAlignH.FontWeight = 'bold';
pause(.02);

%{
xlsA = [];
AlignSheetExists = 0;
try
    
   xlsA = xlsread([xlspathname , xlsfilename],'ALIGN');
   
   AlignSheetExists = 1;
   
   memocon('Imported pre-existing aligment values fomr ALIGN excel sheet');
   
catch ME
    
    memocon(ME.message)
    
end 





if isempty(xlsA)

    if AlignSheetExists && isempty(xlsA)
        memocon('ALIGN excel sheet exists, but is empty');
    end
    if ~AlignSheetExists
        memocon('ALIGN excel sheet does not exist');
    end


%     memocon(' ');
%     memocon('SMOOTHING AND CROPPING IMAGES...');
%     if checkbox1H.Value
%         smoothimg
%     end
%     if checkbox2H.Value
%         cropimg
%     end

    memocon('OPENING IMG ALIGNMENT POPOUT...');
    memocon('SELECT TWO (2) ALIGNMENT POINTS');


    % CREATE IMG WINDOW POPOUT

    IMGi = IMG(:,:,1:previewStacknum);

    fhIMA=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
    haxIMA = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);
    % hold on;

    axes(haxIMA)
    phG = imagesc(IMGi(:,:,1),'Parent',haxIMA,'CDataMapping','scaled');
    [cmax, cmaxi] = max(IMGi(:));
    [cmin, cmini] = min(IMGi(:));
    cmax = cmax - abs(cmax/4);
    cmin = cmin + abs(cmin/4);
    haxIMA.CLim = [cmin cmax];
    axes(haxIMA)
    pause(.01)



    % SELECT TWO ROI POINTS
    hAP1 = impoint;
    hAP2 = impoint;

    AP1pos = hAP1.getPosition;
    AP2pos = hAP2.getPosition;

    imellipse(haxIMA, [AP1pos-5 10 10]); pause(.1);
    imellipse(haxIMA, [AP2pos-5 10 10]); pause(.1);

    pause(.5);
    close(fhIMA)

    memocon('  ');
    memocon('ALIGNMENT POINTS');
    memocon(sprintf('P1(X,Y): \t    %.2f \t    %.2f',AP1pos));
    memocon(sprintf('P2(X,Y): \t    %.2f \t    %.2f',AP2pos));

end
%}




    memocon('OPENING IMG ALIGNMENT POPOUT...');
    memocon('SELECT TWO (2) ALIGNMENT POINTS');


    % CREATE IMG WINDOW POPOUT

    IMGi = IMG(:,:,1:previewStacknum);

    fhIMA=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
    haxIMA = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);
    % hold on;

    axes(haxIMA)
    phG = imagesc(IMGi(:,:,1),'Parent',haxIMA,'CDataMapping','scaled');
    [cmax, cmaxi] = max(IMGi(:));
    [cmin, cmini] = min(IMGi(:));
    cmax = cmax - abs(cmax/4);
    cmin = cmin + abs(cmin/4);
    haxIMA.CLim = [cmin cmax];
    axes(haxIMA)
    pause(.01)



    % SELECT TWO ROI POINTS
    hAP1 = impoint;
    hAP2 = impoint;

    AP1pos = hAP1.getPosition;
    AP2pos = hAP2.getPosition;

    imellipse(haxIMA, [AP1pos-5 10 10]); pause(.1);
    imellipse(haxIMA, [AP2pos-5 10 10]); pause(.1);

    pause(.5);
    close(fhIMA)

    memocon('  ');
    memocon('ALIGNMENT POINTS');
    memocon(sprintf('P1(X,Y): \t    %.2f \t    %.2f',AP1pos));
    memocon(sprintf('P2(X,Y): \t    %.2f \t    %.2f',AP2pos));




AlignVals.P1x = AP1pos(1);
AlignVals.P1y = AP1pos(2);
AlignVals.P2x = AP2pos(1);
AlignVals.P2y = AP2pos(2);

imgAlignP1Xh.String = num2str(AlignVals.P1x);
imgAlignP1Yh.String = num2str(AlignVals.P1y);
imgAlignP2Xh.String = num2str(AlignVals.P2x);
imgAlignP2Yh.String = num2str(AlignVals.P2y);        
% imgAlignP3Xh.String = num2str(AlignVals.P3x);
% imgAlignP3Yh.String = num2str(AlignVals.P3y);
% imgAlignP4Xh.String = num2str(AlignVals.P4x);
% imgAlignP4Yh.String = num2str(AlignVals.P4y);



getAlignH.FontWeight = 'normal';
pause(.02);
enableButtons; pause(.02);
memocon('GET alignment completed.')
end





%----------------------------------------------------
%        SET ALIGN
%----------------------------------------------------
function setAlign(hObject, eventdata)
% disableButtons; 
setAlignH.FontWeight = 'bold';
pause(.02);



AlignVals.P1x = str2num(imgAlignP1Xh.String);
AlignVals.P1y = str2num(imgAlignP1Yh.String);
AlignVals.P2x = str2num(imgAlignP2Xh.String);
AlignVals.P2y = str2num(imgAlignP2Yh.String);
AlignVals.P3x = str2num(imgAlignP3Xh.String);
AlignVals.P3y = str2num(imgAlignP3Yh.String);
AlignVals.P4x = str2num(imgAlignP4Xh.String);
AlignVals.P4y = str2num(imgAlignP4Yh.String);



P1x = AlignVals.P1x;
P1y = AlignVals.P1y;
P2x = AlignVals.P2x;
P2y = AlignVals.P2y;
P3x = AlignVals.P3x;
P3y = AlignVals.P3y;
P4x = AlignVals.P4x;
P4y = AlignVals.P4y;


tX = P3x - P1x;
tY = P3y - P1y;

[IM,~] = imtranslate(IMG,[tX, tY],'FillValues',mean(IMG(:)),'OutputView','same');

IMG = IM;
previewStack



% P1x = P1x + tX;    % after translation P1x moves to P3x
% P1y = P1y + tY;    % after translation P1y moves to P3y
% P2x = P2x + tX;    % after translation P2x does not move to P4x
% P2y = P2y + tY;    % after translation P2y does not move to P4y
% 
% 
% % Make X and Y origins equal zero
% 
% Xa = P2x - P1x; 
% Ya = P2y - P1y; 
% 
% RotA = rad2deg(atan2(Ya,Xa));
% 
% 
% Xb = P4x - P3x;
% Yb = P4y - P3y;
% 
% RotB = rad2deg(atan2(Yb,Xb));
% 
% RotAng = RotB - RotA;
% 
% IM = imrotate(IMG,RotAng,'bilinear','crop'); % Make output image B the same size as the input image A, cropping the rotated image to fit
% 
% IMG = IM;
% previewStack




% fixed = IMG(:,:,1);
% moving = IMG(:,:,500);
% imshowpair(fixed, moving,'Scaling','joint')
% [optimizer, metric] = imregconfig('multimodal');
% optimizer.InitialRadius = 0.009;
% optimizer.Epsilon = 1.5e-4;
% optimizer.GrowthFactor = 1.01;
% optimizer.MaximumIterations = 300;
% movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
% imshowpair(fixed, movingRegistered,'Scaling','joint')




setAlignH.FontWeight = 'normal';
pause(.02);
enableButtons; pause(.02);
memocon('SET alignment completed.')
end






%----------------------------------------------------
%        red Channel IMPORT
%----------------------------------------------------
function redChImport(hObject, eventdata)
pause(.02);

    pathfull = [INFO.path(1:end-5) 'r.tif'];
    [VpPath,VpFile,VpExt] = fileparts(pathfull);
    rcFile = dir(pathfull);

    if numel(rcFile.name) > 1
        
        memocon(' ');
        memocon('Red channel stack found; attempting to import...');
                
    else
        
        memocon(' ');
        memocon('No red channel stack found named:');
        memocon(['  ' VpFile VpExt]);
        memocon(' '); memocon('Select a red channel tif stack...')

        [pathfile, pathdir, ~] = uigetfile({'*.tif*; *.TIF*'}, 'Select file.');
        pathfull = [pathdir pathfile];

    end



    % IMPORT RED CHANNEL IMAGE 
    InfoImage=imfinfo(pathfull);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
        
    IMGred = zeros(nImage,mImage,NumberImages,'double');

    TifLink = Tiff(pathfull, 'r');
    for i=1:NumberImages
       TifLink.setDirectory(i);
       IMGred(:,:,i)=TifLink.read();
    end
    TifLink.close();
    

    if (size(IMG,3) * size(IMG,4)) == size(IMGred,3)
        memocon('GOOD: size(greenStack) == size(redStack)')
    else
        memocon(' ');memocon(' ');memocon(' ');memocon(' ');
        memocon('******  WARNING: size(greenStack) ~= size(redStack)  *****')
        warning('WARNING: size(greenStack) ~= size(redStack)')
        memocon('******    ABORTING RED CHANNEL STACK IMPORT    ******')
        memocon(' ');memocon(' ');memocon(' ');
        return
    end

      
        % VISUALIZE AND ANNOTATE

        SPF1 = sprintf('Green Channel dims: % s ', num2str(size(IMG))  );
        SPF2 = sprintf('Red   Channel dims: % s ', num2str(size(IMGred)) );
       
        memocon(' '); memocon(SPF1); memocon(SPF2);
        
        % GRINcompare(IMG, IMGf, previewNframes, [.98 1.05], [8 2])
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
        
        memocon(' ');
        pause(.5)
        memocon('red Stack Preview'); previewIMGSTACK(IMGred)
        pause(.5)
        memocon('green Stack Preview'); previewStack
        pause(.5)
        memocon('red Stack Preview'); previewIMGSTACK(IMGred)
        pause(.5)
        memocon('green Stack Preview'); previewStack
        pause(.5)
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);


pause(.02);
redChanNormalizeH.Enable = 'on';
enableButtons
memocon('Red channel import completed!')
end





%----------------------------------------------------
%        red Channel NORMALIZATION
%----------------------------------------------------
function redChanNormalize(hObject, eventdata)
% disableButtons;
pause(.02);




RHposCheck.A  = [.02  .76  .05  .05];
RHposCheck.B  = [.02  .64  .05  .05];
RHposCheck.C  = [.02  .52  .05  .05];
RHposCheck.D  = [.02  .40  .05  .05];
RHposCheck.E  = [.02  .28  .05  .05];
RHposCheck.F  = [.02  .16  .05  .05];
RHposCheck.G  = [.02  .04  .05  .05];
RHposTexts.A  = [.12  .72  .45  .08];
RHposTexts.B  = [.12  .60  .45  .08];
RHposTexts.C  = [.12  .48  .45  .08];
RHposTexts.D  = [.12  .36  .45  .08];
RHposTexts.E  = [.12  .24  .45  .08];
RHposTexts.F  = [.12  .12  .45  .08];
RHposTexts.G  = [.22  .85  .65  .08];



REDpopupH = figure('Units', 'normalized','Position', [.25 .12 .30 .80], 'BusyAction',...
    'cancel', 'Name', 'GRIN TOOLBOX', 'Tag', 'REDpopupH','Visible', 'On'); 

REDpanelH = uipanel('Title','Process Red Channel Stack','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],'Position', [0.08 0.20 0.90 0.77]);

Rcheckbox1H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.A ,'String','', 'Value',1);
Rcheckbox2H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.B ,'String','', 'Value',1);
Rcheckbox3H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.C ,'String','', 'Value',1);
Rcheckbox4H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.D ,'String','', 'Value',1);
Rcheckbox5H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.E ,'String','', 'Value',1);
Rcheckbox6H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.F ,'String','', 'Value',1);

uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.A, 'FontSize', 14,'String', 'Smooth');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.B, 'FontSize', 14,'String', 'Crop');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.C, 'FontSize', 14,'String', 'Tile');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.D, 'FontSize', 14,'String', 'Reshape');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.E, 'FontSize', 14,'String', 'Align to CS');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.F, 'FontSize', 14,'String', 'Normalize');
% uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
%     'Position', RHposTexts.G, 'FontSize', 14,'String', 'CLOSE THIS WINDOW TO CONTINUE');


REDcontinueH = uicontrol('Parent', REDpopupH, 'Units', 'normalized', ...
    'Position', [.1 .05 .8 .12], 'FontSize', 12, 'String', 'Continue',...
    'Callback', @REDcontinue, 'Enable','on');

uiwait
REDpopupH.Visible = 'Off';

    
    %----------------------------------------------------
    %        SMOOTH RED CHAN IMAGES
    %----------------------------------------------------  
    if Rcheckbox1H.Value
        memocon(' '); memocon('PERFORMING RED CH IMAGE SMOOTHING')
        IMGr = [];

        smoothSD = str2num(smoothimgnumH.String);
        Mask = GRINkernel(smoothHeight, smoothWidth, smoothSD, smoothRes, 1);
        pause(.2)
        mbh = waitbar(.5,'Performing convolution smoothing, please wait...');

        IMGr = convn( IMGred, Mask,'same');

        waitbar(.8); close(mbh);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Image smoothing completed!')    
    end
    
    
    %----------------------------------------------------
    %        CROP RED CHANNEL IMAGES
    %----------------------------------------------------
    if Rcheckbox2H.Value
        memocon(' '); memocon('TRIMMING EDGES FROM IMAGE')
        IMGr = [];

        cropAmount = str2num(cropimgnumH.String);

        IMGr = IMGred((cropAmount+1):(end-cropAmount) , (cropAmount+1):(end-cropAmount) , :);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Crop Images completed!')
    end

    
    %----------------------------------------------------
    %        CREATE IMAGE TILES BLOCKS
    %----------------------------------------------------
    if Rcheckbox3H.Value
        memocon('SEGMENTING IMGAGES INTO TILES')
        IMGr = [];

        blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));

        IMGr = zeros(size(IMGred));
        sz = size(IMGred,3);

        %-------------------------
        tv1 = 1:blockSize:size(IMGred,1);
        tv2 = 0:blockSize:size(IMGred,1);
        tv2(1) = [];

        progresstimer('Segmenting images into blocks...')
        for nn = 1:sz
          for cc = 1:numel(tv1)
            for rr = 1:numel(tv1)

              mbloc = IMGred( tv1(rr):tv2(rr), tv1(cc):tv2(cc) , nn );
              mu = mean(mbloc(:));

              IMGr( tv1(rr):tv2(rr), tv1(cc):tv2(cc) , nn ) = mu;

            end
          end
        if ~mod(nn,100); progresstimer(nn/sz); end    
        end
        %-------------------------


        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Block-Segment Images completed!')        
    end

    
    
    %----------------------------------------------------
    %        RESHAPE DATA BY TRIALS
    %----------------------------------------------------
    if Rcheckbox4H.Value
        memocon(' '); memocon('Reshaping dataset to 4D');
        IMGr = [];

        IMGr = reshape(IMGred,size(IMGred,1),size(IMGred,2),framesPerTrial,[]);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Reshape stack by trial completed!')
    end

    
    
    %----------------------------------------------------
    %        ALIGN CS FRAMES BY CS ONSET
    %----------------------------------------------------
    if Rcheckbox5H.Value
        memocon(sprintf('Setting CS delay to %s seconds for all trials',alignCSFramesnumH.String));
        IMGr = [];

        % Make all CS onsets this many seconds from trial start
        CSonsetDelay = str2num(alignCSFramesnumH.String);
        CSonsetFrame = round(CSonsetDelay .* framesPerSec);
        CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);


        EqualizeCSdelay  = round((delaytoCS-CSonsetDelay) .* framesPerSec);

        IMGr = IMGred;
        for nn = 1:size(IMGr,4)

            IMGr(:,:,:,nn) = circshift( IMGr(:,:,:,nn) , -EqualizeCSdelay(nn) ,3);

        end

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Align frames by CS onset completed!')
    end
    
    
    %----------------------------------------------------
    %        deltaF OVER F
    %----------------------------------------------------
    if Rcheckbox6H.Value
        memocon(' '); memocon('Computing dF/F for all frames...')
        IMGr = [];

        IMGr = mean(IMGred(:,:,1:round(baselineTime*framesPerSec),:),3);

        im = repmat(IMGr,1,1,size(IMGred,3),1);

        IMGf = (IMGred - im) ./ im;

        IMGred = IMGf;

        previewIMGSTACK(IMGred)
        memocon('dF/F computation completed!')
    end
    
    
    %----------------------------------------------------
    %        RED CHANNEL SUBTRACTION NORMALIZATION
    %----------------------------------------------------
    
    szGimg = size(IMG);
    szRimg = size(IMGred);
    
    disp('Green Stack Dims:')
    disp(szGimg)
    disp('Red Stack Dims:')
    disp(szRimg)
    
    
    if all(szGimg == szRimg)
    
        prompt = {'Enter normalization equation:'};
        dlgout = inputdlg(prompt,'Equation Input',1,{'IMG = IMG - IMGred;'});    

        eval(char(dlgout));

        previewIMGSTACK(IMG)

    else
       
        warning('Green and Red IMG stacks are not the same size.')
        warning('Cannot perform normalization.')
        
    end





        
pause(.02);
enableButtons        
memocon('RED CHANNEL NORMALIZATION COMPLETED')
end






%----------------------------------------------------
%        RED CHANNEL CONTINUE BUTTON CALLBACK
%----------------------------------------------------
function REDcontinue(hObject, eventdata)    

    uiresume
    
end















%----------------------------------------------------
%        EXPORT DATA TO BASE WORKSPACE
%----------------------------------------------------
function exportvars(hObject, eventdata)
% disableButtons; pause(.02);

    if size(GRINtable,1) > 1
        checkLabels = {'Save IMG to variable named:' ...
                   'Save INFO to variable named:' ...
                   'Save GRINtable to variable named:' ...
                   'Save XLSD to variable named:' ...
                   'Save IMGraw to variable named:'...
                   'Save IMGSraw to variable named:'...
                   'Save muIMGS to variable named:'...
                   'Save LICK to variable named:'}; 
        varNames = {'IMG','INFO','GRINtable','XLSD','IMGraw','IMGSraw','muIMGS','LICK'}; 
        items = {IMG,INFO,GRINtable,XLSD,IMGraw,IMGSraw,muIMGS,LICK};
        export2wsdlg(checkLabels,varNames,items,...
                     'Save Variables to Workspace');

        memocon('Main VARS exported to base workspace')
    else
        memocon('no variables available to export')
    end
    
enableButtons        
end




%----------------------------------------------------
%        SAVE DATA TO .MAT FILE
%----------------------------------------------------
function savedataset(hObject, eventdata)
% disableButtons; pause(.02);

    if size(IMG,3) > 1
        
        

        
        
        
        [filen,pathn] = uiputfile([INFO.file(1:end-4),'.mat'],'Save Vars to Workspace');
            
        if isequal(filen,0) || isequal(pathn,0)
           memocon('User selected Cancel')
        else
           memocon(['User selected ',fullfile(pathn,filen)])
        end
        
        % IMGint16 = uint16(IMG);
        % IMG = single(IMG);
                
        memocon('Saving data to .mat file, please wait...')
        save(fullfile(pathn,filen),'IMG','INFO','GRINtable','XLSD',...
            'LICK','IMGraw','muIMGS','IMGSraw','-v7.3')
        % save(fullfile(pathn,filen),'IMGint16','INFO','GRINtable','-v7.3')
        memocon('Dataset saved!')
        
        % whos('-file','newstruct.mat')
        % m = matfile(filename,'Writable',isWritable)
        % save(filename,variables,'-append')
        
%         switch comchoice
%             case 'Yes'
%                 memocon('YOU ARE NOW USING COMPRESSED IMG DATA')
%                 memocon('IF YOU WANT TO WORK WITH UNCOMPRESSED DATA, RELAUNCH TOOLBOX')
%                 IMG = int16(IMG./10000);
%             case 'No'
%                 memocon('CONTINUE USING UNCOMPRESSED IMG DATA')
%         end        

    else
        memocon('No data to save')
    end
    
enableButtons        
end




%----------------------------------------------------
%        COMPRESS AND SAVE
%----------------------------------------------------
function compnsave(hObject, eventdata)

    if size(IMG,3) < 1
        memocon('No data to save')
        return
    end

    comchoice = questdlg('Save compressed dataset?', ...
        'Compress IMG Stack', ...
        'Single','uint16','Nevermind','Single');

    switch comchoice
        case 'Single'
            memocon('DETERMING OPTIMAL DATA COMPRESSION METHOD...')
            doCompress = 1;
        case 'uint16'
            memocon('DETERMING OPTIMAL DATA COMPRESSION METHOD...')
            doCompress = 2;            
        case 'Nevermind'
            memocon('RETURNING TO GUI')
            doCompress = 0;
            return
    end 

    
    
    
    
    
    if doCompress == 1
    
        IM = IMG;
        IMhist.rawIM = IMG(:,:,1,1);
        IMhist.minIM = min(min(min(min(IMG))));
        IMhist.maxIM = max(max(max(max(IMG))));
        IMhist.aveIM = mean(mean(mean(mean(IMG))));

        
        IMG = im2single( IMG  );
        IMGSraw = im2single( IMGSraw  );
        muIMGS  = im2single( muIMGS  );

        [filen,pathn] = uiputfile([INFO.file(1:end-4),'.mat'],'Save Vars to Workspace');
        if isequal(filen,0) || isequal(pathn,0)
           memocon('Data Save Cancelled'); return
        end; memocon('Saving data to .mat file, please wait...')

        disableButtons; pause(.02);

        save(fullfile(pathn,filen),'IMG','INFO','GRINtable','XLSD',...
                                   'muIMGS','IMGSraw','LICK','IMhist','-v7.3')

        memocon('Dataset saved!')

        IMG = IM;
        IM = [];

        IMGSraw = double(IMGSraw);
        muIMGS  = double(muIMGS);

    
    end
    
    
    
    
    
    
    
    
    
    
    if doCompress == 2
        IM = IMG;
        IMhist.rawIM = IMG(:,:,1,1);
        IMhist.minIM = min(min(min(min(IMG))));
        IMhist.maxIM = max(max(max(max(IMG))));
        IMhist.aveIM = mean(mean(mean(mean(IMG))));


        if IMhist.minIM < 0
            IMG = im2uint16(  IMG +  abs(IMhist.minIM)   );
            % IM = im2single( IMG  );
        else
            IMG = im2uint16(  IMG -  abs(IMhist.minIM)   );
        end


        IMGSraw = im2single( IMGSraw  );
        muIMGS  = im2single( muIMGS  );


        [filen,pathn] = uiputfile([INFO.file(1:end-4),'.mat'],'Save Vars to Workspace');
        if isequal(filen,0) || isequal(pathn,0)
           memocon('Data Save Cancelled'); return
        end; memocon('Saving data to .mat file, please wait...')

        disableButtons; pause(.02);

        save(fullfile(pathn,filen),'IMG','INFO','GRINtable','XLSD',...
                                   'muIMGS','IMGSraw','LICK','IMhist','-v7.3')

        memocon('Dataset saved!')

        IMG = IM;
        IM = [];

        IMGSraw = double(IMGSraw);
        muIMGS  = double(muIMGS);
    end
            
enableButtons        
end








%----------------------------------------------------
%        OPEN IMAGEJ API
%----------------------------------------------------
function openImageJ(hObject, eventdata)
% disableButtons; pause(.02);


    memocon('LAUNCHING ImageJ (FIJI) using MIJ!')
    
    matfiji(IMG(:,:,1:100), INFO, XLSD, LICK)
        

  
    
% GRINtoolboxGUI
return
enableButtons        
memocon('ImageJ (FIJI) processes completed!')
end




%----------------------------------------------------
%        3D DATA EXPLORATION
%----------------------------------------------------
function img3d(hObject, eventdata)
disableButtons; pause(.02);



    choice = questdlg({'Contour slicing could take a few minutes.',...
                       'Do you want to continue?'},' ','Yes','No','No');
                   
            switch choice
                case 'Yes'
                     memocon('CREATING CONTOUR SLICE (please wait)...')
                case 'No'
                    return
            end

    IM = IMG(:,:,1:50);

    
    fh10=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],...
        'Color','w','MenuBar','none','Pointer','circle');
    hax10 = axes('Position',[.05 .05 .9 .9],'Color','none');
    rotate3d(fh10);
    
    Sx = []; 
    Sy = [];
    Sz = [1 25 50];
    
    contourslice(IM,Sx,Sy,Sz)
        campos([0,-15,8])
        box on
    
    


    
enableButtons        
memocon('3D VIEW FUNCTION COMPLETED!')
end




%----------------------------------------------------
%        VISUAL EXPLORATION
%----------------------------------------------------
function visualexplorer(hObject, eventdata)
% disableButtons; pause(.02);




    if numel(size(IMG))==3

        IM = IMG(:,:,1:XLSD.framesPerTrial);
        
        vol = [round(XLSD.sizeIMG(1)*.25),round(XLSD.sizeIMG(1)*.5),...
               round(XLSD.sizeIMG(2)*.25),round(XLSD.sizeIMG(2)*.5),...
               1,XLSD.framesPerTrial];
        
        isoval = 5;
        
    else
        
        IM = IMG(:,:,1:XLSD.framesPerTrial,1);
        
        vol = [round(XLSD.sizeIMG(1)*.25),round(XLSD.sizeIMG(1)*.5),...
               round(XLSD.sizeIMG(2)*.25),round(XLSD.sizeIMG(2)*.5),...
               1,XLSD.framesPerTrial];
        
        isoval = -1;
    
    end
    
    
    memocon('CREATING SUBVOLUME FROM IMAGE STACK...')

    
    
    [x,y,z,D] = subvolume(IM,vol);

    
    
%     fh10=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],...
%         'Color','w','MenuBar','none');
%     hax10 = axes('Position',[.05 .05 .9 .9],'Color','none');


    p1 = patch(isosurface(x,y,z,D, isoval),...
         'FaceColor','red','EdgeColor','none');
    isonormals(x,y,z,D,p1);
    p2 = patch(isocaps(x,y,z,D, isoval),...
         'FaceColor','interp','EdgeColor','none');
    view(3); axis tight;
    camlight right; camlight left; lighting gouraud
    
    rotate3d(gca);

for i = 1:150;
   camorbit(3,0)
   pause(.05)
end


    
enableButtons        
memocon('SUBVOLUME CREATION COMPLETED (USE MOUSE TO ROTATE IMAGE)!')
end





%----------------------------------------------------
%        RESET WORKSPACE
%----------------------------------------------------
function resetws(hObject, eventdata)
% disableButtons; pause(.02);


    choice = questdlg({'This will close all windows and reset the ',...
                       'GRIN Lens Toolbox workspace. Continue?'}, ...
	'Relaunch GRIN Toolbox', ...
	'reset toolbox','abort reset','reset toolbox');
    % Handle response
    switch choice
        case 'reset toolbox'
            memocon(' Resetting GRIN Lens Toolbox...')
            pause(1)
            GRINtoolboxGUI()
            return
        case 'abort reset'
            memocon(' Continuing without reset...')
    end
    
    
% enableButtons
end





%----------------------------------------------------
%        IMAGE SIDER CALLBACK
%----------------------------------------------------
function imgslider(hObject, eventdata)

    % Hints: hObject.Value returns position of slider
    %        hObject.Min and hObject.Max determine range of slider
    % sunel = get(handles.sunelslider,'value'); % Get current light elev.
    % sunaz = get(hObject,'value');   % Varies from -180 -> 0 deg

    slideVal = ceil(imgsliderH.Value);

    if size(IMG,3) > 99

        phGRIN = imagesc(IMG(:,:,slideVal) , 'Parent', haxGRIN);
                  pause(.05)

        memocon(['image' num2str(slideVal)])

    else

        memocon('There must be at least 100 images in the stack')
        memocon('(per trial) to use the slider; currently there are')
        memocon(size(IMG,3))

    end

end





%----------------------------------------------------
%        CONSOLE DIARY ON / OFF / OPEN
%----------------------------------------------------
function conon
    % diary on
end
function conoff
    % diary(confile)
    % diary off
    
    % UNCOMMENT TO OPEN DIARY WHEN DONE IMAGE PROCESSING
    % web(confilefullpath{1})
end



%----------------------------------------------------
%        CSUS DROPDOWN MENU CALLBACK
%----------------------------------------------------
function CSUSpopup(hObject, eventdata)

    if numel(GRINtable) > 0 
        memocon('reminder of CS/US combos...')
        GRINtable(1:7,1:2)
        % INFO
    end
        
    stimnum = CSUSpopupH.Value;

    % CSUSvals = unique(INFO.csus);
    % set(CSUSpopupH, 'String', CSUSvals);

end




%----------------------------------------------------
%        NormType DROPDOWN MENU CALLBACK
%----------------------------------------------------
function NormTypePopup(hObject, eventdata)
    
    
    PopValue = NormTypePopupH.Value;
    NormType = NormTypePopupH.String{PopValue};
    
    memocon(sprintf('Normalization set to: % s ',NormType));

    
    % set(NormTypePopupH, 'String', {'dF','Zscore'});
    % CSUSvals = unique(INFO.csus);
    % set(CSUSpopupH, 'String', CSUSvals);

end



%----------------------------------------------------
%        ENABLE AND DISABLE GUI BUTTONS
%----------------------------------------------------
function enableButtons()

    smoothimgH.Enable = 'on';
    cropimgH.Enable = 'on';
    imgblocksH.Enable = 'on';
    dFoverFH.Enable = 'on';
    reshapeDataH.Enable = 'on';
    unshapeDataH.Enable = 'on';
    alignCSFramesH.Enable = 'on';
    timepointMeansH.Enable = 'on';
    getROIstatsH.Enable = 'on';
    plotTileStatsH.Enable = 'on';
    runallIPH.Enable = 'on';
    previewStackH.Enable = 'on';
    viewGridOverlayH.Enable = 'on';
    plotGroupMeansH.Enable = 'on';
    viewTrialTimingsH.Enable = 'on';
    plotGUIH.Enable = 'on';
    img3dH.Enable = 'on';
    visualexplorerH.Enable = 'on';
    getAlignH.Enable = 'on';
    setAlignH.Enable = 'on';
    runPCAh.Enable = 'on';

    
    if numel(size(IMG)) > 1 && numel(size(IMG)) < 4;
        openImageJH.Enable = 'on';
    else
        openImageJH.Enable = 'off';
    end
end
function disableButtons()
    
    smoothimgH.Enable = 'off';
    cropimgH.Enable = 'off';
    imgblocksH.Enable = 'off';
    dFoverFH.Enable = 'off';
    reshapeDataH.Enable = 'off';
    unshapeDataH.Enable = 'off';
    alignCSFramesH.Enable = 'off';
    timepointMeansH.Enable = 'off';
    getROIstatsH.Enable = 'off';
    plotTileStatsH.Enable = 'off';
    runallIPH.Enable = 'off';
    openImageJH.Enable = 'off';
    previewStackH.Enable = 'off';
    viewGridOverlayH.Enable = 'off';
    plotGroupMeansH.Enable = 'off';
    viewTrialTimingsH.Enable = 'off';
    plotGUIH.Enable = 'off';
    img3dH.Enable = 'off';
    visualexplorerH.Enable = 'off';
    getAlignH.Enable = 'off';
    setAlignH.Enable = 'off';
    runPCAh.Enable = 'off';

end




%----------------------------------------------------
%        MEMO LOG UPDATE
%----------------------------------------------------
function memocon(spf,varargin)
    
  
    if iscellstr(spf)
        spf = [spf{:}];
    end
    
    if iscell(spf)
        return
        keyboard
        spf = [spf{:}];
    end
    
    if ~ischar(spf)
        return
        keyboard
        spf = [spf{:}];
    end
    
    

    memes(1:end-1) = memes(2:end);
    memes{end} = spf;
    conboxH.String = memes;
    pause(.02)
    
    if nargin == 3
        
        vrs = deal(varargin);
                
        memi = memes;
                 
        memes(1:end) = {' '};
        memes{end-1} = vrs{1};
        memes{end} = spf;
        conboxH.String = memes;
        
        conboxH.FontAngle = 'italic';
        conboxH.ForegroundColor = [.9 .4 .01];
        pause(vrs{2})
        
        conboxH.FontAngle = 'normal';
        conboxH.ForegroundColor = [0 0 0];
        conboxH.String = memi;
        pause(.02)
        
    elseif nargin == 2
        vrs = deal(varargin);
        pause(vrs{1})
    end
    
    
    

end





%------------------------------------------------------------------------------
%        PLOT LICKING DATA
%------------------------------------------------------------------------------
function plotLick(hObject, eventdata)

    maxY = (max(max(LICK)));
    minY = (min(min(LICK)));
    rmaxY = ceil(round(maxY,2));
    rminY = floor(round(minY,2));
    

    %-----------------------------------
    %    CREATE FIGURE FOR LICKING PLOT
    %-----------------------------------
    lickfigh = figure('Units', 'normalized','Position', [.02 .05 .60 .42], 'BusyAction',...
    'cancel', 'Name', 'lickfigh', 'Tag', 'lickfigh','MenuBar', 'none'); 

    LhaxGRIN = axes('Parent', lickfigh, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.05 0.9 0.9],'Color','none'); 
    LhaxGRIN.YLim = [rminY rmaxY];
    LhaxGRIN.XLim = [1 size(LICK,2)];

    GhaxLCK = axes('Parent', lickfigh, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.05 0.9 0.9],'Color','none'); hold on;
    GhaxLCK.YLim = LhaxGRIN.YLim;
    GhaxLCK.XLim = LhaxGRIN.XLim;
    hold on;

    %-----------------------------------
    %    PLOT LICKING DATA
    %-----------------------------------
    axes(LhaxGRIN)
    LhaxGRIN.ColorOrderIndex = 1;
hpLick = plot(LhaxGRIN, LICK' , ':', 'LineWidth',2,'HandleVisibility', 'off');
    
    legLick = legend(hpLick,XLSD.CSUSvals);
	set(legLick, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(legLick, 'Position', legLick.Position .* [1 .94 1 1.4])      
    
    
    
    %-----------------------------------
    %    PLOT CS ON/OFF LINES
    %-----------------------------------
    axes(GhaxLCK)
    
    CSonsetFrame = round(XLSD.CSonsetDelay .* XLSD.framesPerSec);
    CSoffsetFrame = round((XLSD.CSonsetDelay+XLSD.CS_length) .* XLSD.framesPerSec);
    line([CSonsetFrame CSonsetFrame],GhaxLCK.YLim,...
    'Color',[.52 .52 .52],'Parent',GhaxLCK,'LineWidth',2)
    line([CSoffsetFrame CSoffsetFrame],GhaxLCK.YLim,...
    'Color',[.5 .5 .5],'Parent',GhaxLCK,'LineWidth',2)




    axes(LhaxGRIN)
    pause(.02)

   
end


%------------------------------------------------------------------------------
%        PLOT LICKING DATA
%------------------------------------------------------------------------------
function normLick(hObject, eventdata)
    
    
    if strcmp(normLickH.String,'Normalize Lick')
        memocon('Normalizing Lick Data...')
        
        LICKraw = LICK;
        LICKbase = mean(LICK(:,1:round(baselineTime*framesPerSec)),2);
        LICKbase = repmat(LICKbase,1,size(LICK,2));
        LICK = (LICK - LICKbase) ./ (LICKbase);
        
        
        normLickH.String = 'Undo Lick Norm';
        memocon('Normalization Completed.')
    elseif strcmp(normLickH.String,'Undo Lick Norm')
        memocon('Reverting lick data Normalization...')
        
        LICK = LICKraw;
        
        normLickH.String = 'Normalize Lick';
        memocon('Undid lick data Normalization.')
    end
    
    
    
    
end









end
%% EOF



%% ------------------------- OUT OF USE ------------------------------
%{

%----------------------------------------------------
%   MAIN GUI CLOSE REQUEST FUNCTION
%----------------------------------------------------
function mainGUIclosereq(src,callbackdata)
   selection = questdlg('Clear globals from memory?',...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
         clc
         initialVars = who;
         memocon('Clearing globals...')
         memocon(initialVars)
         clearvars -global
         % clearvars IMG;
         memocon('Global variables cleared from memory.')
         memocon('GRIN toolbox closed.')
         delete(gcf)
      case 'No'
      delete(gcf)
      memocon('GRIN toolbox closed.')
   end
end




%----------------------------------------------------
%        COMING SOON NOTIFICATION
%----------------------------------------------------
function comingsoon(hObject, eventdata)
   msgbox('Coming Soon!'); 
end





%----------------------------------------------------
%        MOTION CORRECTION
%----------------------------------------------------
function motioncorrection(hObject, eventdata)
   msgbox('Coming Soon!'); 
   return
   
    % clc; clear all; close all;

    % Input video file which needs to be stabilized.
    % filename = 'shaky_car.avi';
    filename = 'GRIN_zstack.avi';

    hVideoSource = vision.VideoFileReader(filename, ...
              'ImageColorSpace', 'Intensity','VideoOutputDataType', 'double');


    % Create geometric translator object used to compensate for movement.
    hTranslate = vision.GeometricTranslator( ...
           'OutputSize', 'Same as input image', 'OffsetSource', 'Input port');


    % Create template matcher object to compute location of best target match
    % in frame. Use location to find translation between successive frames.
    hTM = vision.TemplateMatcher('ROIInputPort', true, ...
                                'BestMatchNeighborhoodOutputPort', true);


    % Create object to memoconlay the original video and the stabilized video.
    hVideoOut = vision.VideoPlayer('Name', 'Video Stabilization');
    hVideoOut.Position(1) = round(0.4*hVideoOut.Position(1));
    hVideoOut.Position(2) = round(1.5*(hVideoOut.Position(2)));
    hVideoOut.Position(3:4) = [900 550];


        imgA = step(hVideoSource); % Read first frame into imgA
        figure
        imagesc(imgA);
        title('USE MOUSE TO DRAW BOX AROUND BEST STABILIZATION OBJECT')
        h1 = imrect;
        pos1 = round(getPosition(h1)); % [xmin ymin width height]


    % Here we initialize some variables used in the processing loop.

    pos.template_orig = [pos1(1) pos1(2)]; % [x y] upper left corner
    pos.template_size = [pos1(3:4)];    % [width height]
    pos.search_border = [10 10];        % max horizontal and vertical memoconlacement

    pos.template_center = floor((pos.template_size-1)/2);
    pos.template_center_pos = (pos.template_orig + pos.template_center - 1);
    fileInfo = info(hVideoSource);
    W = fileInfo.VideoSize(1); % Width in pixels
    H = fileInfo.VideoSize(2); % Height in pixels
    BorderCols = [1:pos.search_border(1)+4 W-pos.search_border(1)+4:W];
    BorderRows = [1:pos.search_border(2)+4 H-pos.search_border(2)+4:H];
    sz = fileInfo.VideoSize;
    TargetRowIndices = ...
      pos.template_orig(2)-1:pos.template_orig(2)+pos.template_size(2)-2;
    TargetColIndices = ...
      pos.template_orig(1)-1:pos.template_orig(1)+pos.template_size(1)-2;
    SearchRegion = pos.template_orig - pos.search_border - 1;
    Offset = [0 0];
    Target = zeros(20,20);
    % Target = zeros(18,22);
    firstTime = true;



    % Stream Processing Loop

    % Processing loop using objects created above to perform stabilization
    nn = 0;
    while ~isDone(hVideoSource)
    nn = nn+1;

        input = step(hVideoSource);

        % Find location of Target in the input video frame
        if firstTime
          Idx = int32(pos.template_center_pos);
          MotionVector = [0 0];
          firstTime = false;
        else
          IdxPrev = Idx;

          ROI = [SearchRegion, pos.template_size+2*pos.search_border];
          Idx = step(hTM, input, Target, ROI);

          MotionVector = double(Idx-IdxPrev);
        end

        [Offset, SearchRegion] = updatesearch(sz, MotionVector, ...
            SearchRegion, Offset, pos);

        % Translate video frame to offset the camera motion
        Stabilized = step(hTranslate, input, fliplr(Offset));

        Target = Stabilized(TargetRowIndices, TargetColIndices);

        % Add black border for memoconlay
        Stabilized(:, BorderCols) = minmin;
        Stabilized(BorderRows, :) = minmin;

        TargetRect = [pos.template_orig-Offset, pos.template_size];
        SearchRegionRect = [SearchRegion, pos.template_size + 2*pos.search_border];

        % Draw rectangles on input to show target and search region
        input = insertShape(input, 'Rectangle', [TargetRect; SearchRegionRect],...
                            'Color', 'white');
        % Display the offset (memoconlacement) values on the input image
        txt = sprintf('(%+05.1f,%+05.1f)', Offset);
        input = insertText(input(:,:,1),[191 215],txt,'FontSize',16, ...
                        'TextColor', 'white', 'BoxOpacity', 0);
        % Display video
        step(hVideoOut, [input(:,:,1) Stabilized]);


        sGRINs{nn} = Stabilized;
    end

    % Release hVideoSource
    release(hVideoSource);
    % ===============================================
   
end



%----------------------------------------------------
%        RADIO BUTTON CALLBACK
%----------------------------------------------------
function stimselection(source,callbackdata)
        
    % strcmp(stimtypeh.SelectedObject.String,'CSxUS')
    stimtype = stimtypeh.SelectedObject.String;
    
    memoconlay(['Previous Stim: ' callbackdata.OldValue.String]);
    memoconlay(['Current Stim: ' callbackdata.NewValue.String]);
    memoconlay('------------------');
    
    
    % % RADIO BUTTON GROUP FOR TIMEPOINT MEANS
    % stimtypeh = uibuttongroup('Parent', IPpanelH, 'Visible','on',...
    %                   'Units', 'normalized',...
    %                   'Position',[0.63 0.31 0.35 0.06],...
    %                   'SelectionChangedFcn',@stimselection);              
    % stimtypeh1 = uicontrol(stimtypeh,'Style','radiobutton',...
    %                   'String','CSxUS',...
    %                   'Units', 'normalized',...
    %                   'Position',[0.04 0.05 0.38 0.9],...
    %                   'HandleVisibility','off');
    % stimtypeh2 = uicontrol(stimtypeh,'Style','radiobutton',...
    %                   'String','CS',...
    %                   'Units', 'normalized',...
    %                   'Position',[0.42 0.05 0.3 0.9],...
    %                   'HandleVisibility','off');
    % stimtypeh3 = uicontrol(stimtypeh,'Style','radiobutton',...
    %                   'String','US',...
    %                   'Units', 'normalized',...
    %                   'Position',[0.68 0.05 0.3 0.9],...
    %                   'HandleVisibility','off');

end




%----------------------------------------------------
%        FORMAT XLS DATASHEETS
%----------------------------------------------------
function formatXLS()
    
    msgbox('Coming Soon!'); 
   return
   
   xlsdata = formatXLS(varargin);
     
end


%}