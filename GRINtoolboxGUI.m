function [] = GRINtoolboxGUI(varargin)
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

clc; close all; clear; clear java;
% clearvars -except varargin
disp('WELCOME TO THE GRIN LENS IMAGING TOOLBOX')
% set(0,'HideUndocumented','off')

global thisfilepath
thisfile = 'GRINtoolboxGUI.m';
thisfilepath = fileparts(which(thisfile));
cd(thisfilepath);

fprintf('\n\n Current working path set to: \n % s \n', thisfilepath)

% global isbrad
% upath = userpath;
% isbrad = strcmp('/Users/bradleymonk',upath(1:18));


    
    pathdir0 = thisfilepath;
    pathdir1 = [thisfilepath '/grinsubfunctions'];
    pathdir2 = [thisfilepath '/grincustomfunctions'];
    pathdir3 = [thisfilepath '/grinsubfunctions/grinfiji'];
    
    gpath = [pathdir0 ':' pathdir1 ':' pathdir2 ':' pathdir3];
    
    addpath(gpath)

fprintf('\n\n Added folders to path: \n % s \n % s \n % s \n % s \n\n',...
        pathdir0,pathdir1,pathdir2,pathdir3)


%% MANUALLY SET PER-SESSION PATH PARAMETERS IF WANTED (OPTIONAL)

global imgfilename imgpathname xlsfilename xlspathname lickfilename lickpathname
global imgfullpath xlsfullpath lickfullpath

%% ESTABLISH GLOBALS AND SET STARTING VALUES

global mainguih imgLogo

global IMG GRINstruct GRINtable XLSdata LICK
global xlsN xlsT xlsR
global lickN %lickT lickR
global IMGraw IMGSraw IM
global memes conboxH

global frame_period framesUncomp CS_type US_type delaytoCS CS_length compressFrms
global total_trials framesPerTrial secPerFrame framesPerSec secondsPerTrial 
global total_frames CS_lengthFrames IMhist

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
mainguih = figure('Units', 'normalized','Position', [.05 .10 .90 .75], 'BusyAction',...
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
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.43 0.76 0.35 0.23]); % 'Visible', 'Off',


memes = {' ',' ',' ', ' ',' ',' ',' ', ...
         'Welcome to the GRIN TOOLBOX', 'GUI is loading...'};

conboxH = uicontrol('Parent',memopanelH,'Style','listbox','Units','normalized',...
        'Max',9,'Min',0,'Value',9,'FontSize', 13,'FontName', 'FixedWidth',...
        'String',memes,'FontWeight', 'bold',...
        'Position',[.02 .02 .96 .96]);  
    

% memocon(['Factor set to: ' callbackdata.NewValue.String])







%----------------------------------------------------
%           IMAGE PROCESSING PANEL
%----------------------------------------------------
IPpanelH = uipanel('Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.43 0.22 0.35 0.53]); % 'Visible', 'Off',



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
HposTxt.G    = [.71  .07  .27  .04];

HposEdit.A   = [.71  .76  .27  .07];
HposEdit.B   = [.70  .63  .28  .07];
HposEdit.C   = [.71  .50  .27  .07];
HposEdit.D   = [.71  .39  .27  .08];
HposEdit.E   = [.71  .27  .27  .07];
HposEdit.F   = [.70  .14  .28  .07];
HposEdit.G   = [.70  .01  .27  .08];

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
    'Position', HposButton.F, 'FontSize', 12, 'String', 'Compute dF / F',...
    'Callback', @dFoverF, 'Enable','off'); 
dFoverFtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.F, 'FontSize', 10,'String', 'Baseline time (s)');
dFoverFnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.F, 'FontSize', 11);



timepointMeansH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.G, 'FontSize', 12, 'String', 'Compute trial means ',...
    'Callback', @timepointMeans, 'Enable','off');              
CSUSpopupH = uicontrol('Parent', IPpanelH,'Style', 'popup',...
    'Units', 'normalized', 'String', {'CS','US'},...
    'Position', HposEdit.G,...
    'Callback', @CSUSpopup, 'Enable','off');


              

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



%----------------------------------------------------
%    CUSTOM FUNCTIONS PANEL
%----------------------------------------------------
customfunpanelH = uipanel('Title','Custom Code & Data Exploration','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.80 0.64 0.18 0.34]); % 'Visible', 'Off',
              
runCustomAH = uicontrol('Parent', customfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.73 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function A',...
    'Callback', @runCustomA);

runCustomBH = uicontrol('Parent', customfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.50 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function B',...
    'Callback', @runCustomB);

runCustomCH = uicontrol('Parent', customfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.26 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function C',...
    'Callback', @runCustomC);

runCustomDH = uicontrol('Parent', customfunpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.20], 'FontSize', 13, 'String', 'Custom Function D',...
    'Callback', @runCustomD);





%----------------------------------------------------
%    DATA EXPLORATION & API PANEL
%----------------------------------------------------
explorepanelH = uipanel('Title','Data Exploration & API','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.80 0.25 0.18 0.34]); % 'Visible', 'Off',
              
openImageJH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.73 0.95 0.20], 'FontSize', 13, 'String', 'Open stack in ImageJ ',...
    'Callback', @openImageJ, 'Enable','off');

img3dH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.50 0.95 0.20], 'FontSize', 13, 'String', '3D Views',...
    'Callback', @img3d, 'Enable','off');

visualexplorerH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.26 0.95 0.20], 'FontSize', 13, 'String', 'Visual Explorer',...
    'Callback', @visualexplorer, 'Enable','off');

resetwsH = uicontrol('Parent', explorepanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.20], 'FontSize', 13, 'String', 'Reset Toolbox',...
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

    
    memocon('XLS data successfully imported and processed!')
    
    fprintf('\n\n In this dataset there are...')
    fprintf('\n    total trials: %10.1f  ', total_trials)
    fprintf('\n    frames per trial: %7.1f  ', framesPerTrial)
    fprintf('\n    seconds per frame: %8.5f  ', secPerFrame)
    fprintf('\n    frames per second: %8.5f  ', framesPerSec)
    fprintf('\n    seconds per trial: %8.4f  \n\n', secondsPerTrial)  
    
    
    % CREATE ID FOR EACH UNIQUE CS+US COMBO AND DETERMINE ROW 
    [GRINstruct, GRINtable] = gettrialtypes(total_trials, CS_type, US_type, framesPerTrial);

    GRINstruct.file  = imgfilename;
    GRINstruct.path  = [imgpathname imgfilename];

    disp('GRINstruct contains the following structural arrays:')
    disp('{  Example usage: GRINstruct.tf(:,1)  }')
    disp(GRINstruct)

    disp('GRINtable includes the following columns:')
    disp(GRINtable(1:10,:))

    CSonsetDelay = min(delaytoCS);
    set(alignCSFramesnumH, 'String', num2str(CSonsetDelay));
    baselineTime = CSonsetDelay;
    set(dFoverFnumH, 'String', num2str(baselineTime));
        
     CSUSvals = unique(GRINstruct.csus);
     set(CSUSpopupH, 'String', CSUSvals);
     
     CSonsetFrame = round(CSonsetDelay .* framesPerSec);
     CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);
     
    XLSdata.frame_period    = frame_period;
    XLSdata.framesUncomp    = framesUncomp;
    XLSdata.CS_type         = CS_type;
    XLSdata.US_type         = US_type;
    XLSdata.delaytoCS       = delaytoCS;
    XLSdata.CS_length       = CS_length;
    XLSdata.compressFrms    = compressFrms;
    XLSdata.total_trials    = total_trials;
    XLSdata.framesPerTrial  = framesPerTrial;
    XLSdata.secPerFrame     = secPerFrame;
    XLSdata.framesPerSec    = framesPerSec;
    XLSdata.secondsPerTrial = secondsPerTrial;
    XLSdata.total_frames    = total_frames;
    XLSdata.CS_lengthFrames = CS_lengthFrames;
    XLSdata.CSonsetDelay    = CSonsetDelay;
    XLSdata.CSonsetFrame    = CSonsetFrame;
    XLSdata.CSoffsetFrame   = CSoffsetFrame;
    XLSdata.baselineTime    = baselineTime;
    XLSdata.CSUSvals        = CSUSvals;
    XLSdata.blockSize       = blockSize;
    XLSdata.cropAmount      = cropAmount;
    XLSdata.sizeIMG         = size(IMG);
    
    
    % GET TREATMENT GROUP STRINGS
    fid=[];
    for nn = 1:size(GRINstruct.tf,2)
        fid(nn) = find(GRINstruct.id==nn,1); 
    end
    GRINstruct.TreatmentGroups = GRINstruct.csus(fid);
     
     
     
    % if isbrad
        if numel(lickfilename) > 2;
        % ------------- LICK DATA IMPORT CODE -----------
        [lickN,~,~] = xlsread([lickpathname , lickfilename]);

        if (size(lickN,2) ~= total_trials) 
            warning(['\n Number of colums in % s \n does not match number ',...
            'of trials in % s \n (toolbox may crash during analysis). \n'],...
            lickfilename, xlsfilename)
        end

        LICK = reshape(lickN,floor(size(lickN,1) / framesPerTrial),...
                       [], size(lickN,2));

        memocon('Lick data imported and reshaped')
        fprintf('\n\n Lick data imported and reshaped to size:\n   size(LICK) % s \n\n', ...
                 num2str(size(LICK)));
        % LICK = squeeze(sum(LICK,1));

        end
    % end
     
     
     
     
     
     
     
     
     
     
     % VISUALIZE AND ANNOTATE
     memocon(sprintf('Imported stack size: % s ', num2str(size(IMG))));
     fprintf('\n\n Imported stack size: % s ', num2str(size(IMG)));
     
  IMG = IMG(:,:,1:total_frames);
     
     fprintf('\n Size after excel-informed adjustment:  % s \n\n', num2str(size(IMG)));
     
     update_IMGfactors()
    
enableButtons
memocon('Image stack and xls data import completed!')
% diary(confile)
diary off
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

        XLSdata.sizeIMG = size(IMG);

        
        
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
    
    for nn = 1:size(GRINstruct.tf,2)
        
        IMGSraw(:,:,:,nn) = squeeze(mean(IMG(:,:,:,GRINstruct.tf(:,nn)),4));
    
    end
    
    % IMGSraw = IMG(:,:,[1, XLSdata.CSonsetFrame, XLSdata.CSoffsetFrame, size(IMG,3)],:);
    IMG = IMGt;
    XLSdata.sizeIMG = size(IMG);
    % unshapeData
    
    
        previewStack
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        update_IMGfactors()
        
        XLSdata.cropAmount = cropAmount;
        XLSdata.sizeIMG = size(IMG);
        
        
        
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

        
        XLSdata.blockSize = blockSize;
        XLSdata.sizeIMG = size(IMG);
        

        
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
    
    IMGr = reshape(IMG,size(IMG,1),size(IMG,2),framesPerTrial,[]);
        
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGr)));
        memocon(sprintf('IMG matrix previous size: % s ', num2str(size(IMG))));
        memocon(sprintf('IMG matrix current size: % s ', num2str(size(IMGr))));
    
    IMG = IMGr;
        
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        
        XLSdata.sizeIMG = size(IMG);

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
        
        XLSdata.sizeIMG = size(IMG);

IMhist.reshaped = 0;
enableButtons
memocon('Undo reshape completed!')
end






%----------------------------------------------------
%        ALIGN CS FRAMES BY CS ONSET
%----------------------------------------------------
function alignCSframes(hObject, eventdata)
disableButtons;
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
    
    GRINstruct.CSUSonoff = CSUSonoff;
    
    fprintf(['\n\n (in frames)...\n   CSon: % 6.1d \n   CSoff: % 5.1d ',...
             '\n   USon: % 6.1d \n   USoff: % 5.1d '],CSUSonoff);
    
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGe)));
    
    IMG = IMGe;
    
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        XLSdata.CSonsetFrame = CSonsetFrame;
        XLSdata.CSoffsetFrame = CSoffsetFrame;


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



    % COMPUTE dF/F FOR ALL FRAMES
    memocon(' '); memocon('Computing dF/F for all frames...')
    
    
    
    if numel(size(IMG)) == 3
        
        % As a shortcut and to retain the original frame number I am using
        % circshift to move the first image to the end of the image matrix
        im = circshift( IMG , -1 ,3);
        IMGf = (im - IMG) ./ im;
        IMGf(:,:,end) = IMGf(:,:,end-1); % this just duplicates the last frame
    
        % muIMG = mean(IMG(:,:,1:baselineTime),3);
        % im = repmat(muIMG,1,1,size(IMG,3));
        % IMGf = (IMG - im) ./ im;
    
    elseif numel(size(IMG)) == 4
        
        muIMG = mean(IMG(:,:,1:round(baselineTime*framesPerSec),:),3);
        im = repmat(muIMG,1,1,size(IMG,3),1);
        IMGf = (IMG - im) ./ im;
        
    end

    
    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix previous size: % s ', num2str(size(IMG)));
        fprintf('\n IMG matrix current size: % s \n\n', num2str(size(IMGf)));
        % GRINcompare(IMG, IMGf, previewNframes, [.98 1.05], [8 2])
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
    IMG = IMGf;
    
        previewStack
        axes(haxGRIN)
        phGRIN = imagesc(IMG(:,:,1) , 'Parent', haxGRIN);

        

IMhist.normalized = 1;
dFoverFH.FontWeight = 'normal';
pause(.02);
enableButtons        
memocon('dF/F computation completed!')
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
    nCSUS = size(GRINstruct.tf,2);
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
        im = IMG(:,:,:,GRINstruct.tf(:,tt));
        muIMGS(:,:,:,tt) = squeeze(mean(im,4));
    end


    
        % VISUALIZE AND ANNOTATE
        fprintf('\n\n IMG matrix retains size: % s ', num2str(size(IMG)));
        fprintf('\n muIMGS matrix is now size: % s \n\n', num2str(size(muIMGS)));

        previewIMGSTACK(muIMGS)
        
        
        mIm = squeeze(mean(squeeze(mean(muIMGS,4)),3));
        
        axes(haxGRIN)
        phGRIN = imagesc(mIm,'Parent',haxGRIN,'CDataMapping','scaled');
        cmax = max(max(max(max(mIm))));
        cmin = min(min(min(min(mIm))));
        cmax = cmax - abs(cmax/3);
        cmin = cmin + abs(cmin/3);
        haxGRIN.CLim = [cmin cmax];

        % phGRIN.CData = squeeze(mean(squeeze(mean(muIMGS,4)),3));

    
        
        % GRINcompare(IMG, muIMGS, previewNframes)
        % mainguih.HandleVisibility = 'off';
        % close all;
        % mainguih.HandleVisibility = 'on';
        % axes(haxGRIN)
        % phGRIN = imagesc(muIMGS(:,:,1,1) , 'Parent', haxGRIN);

        
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
    
    XLSdata.sizeIMG = size(IMG);

    disp('memocon(''XLSdata'') >>')
    disp(XLSdata)

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
    
    graphguih = ROITOOLBOXGUI(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK);
    
    
    
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

    CSUSplot(ROImu', GRINstruct);
    % CSUSplot(ROImu', GRINstruct, CSUSonoff);
    % previewstack(squeeze(muIMGS(:,:,:,1)), CSUSonoff, ROImu)
    
    
    
    
enableButtons
memocon('Compute ROI statistics completed!')
end





%----------------------------------------------------
%        PLOT TILE STATS DATA
%----------------------------------------------------
function plotTileStats(hObject, eventdata)
% disableButtons; pause(.02);

    if size(muIMGS,1) < 1
       
        msgbox('DATA HAS NOT BEEN PROCESSED'); 
        
        enableButtons
        
        return
        
    end

    memocon(' '); memocon('PLOTTING TILE STATS DATA (PLEASE WAIT)...'); 
    
    
    blockSize = str2num(imgblockspopupH.String(imgblockspopupH.Value,:));

    pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);

    pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    CSids = unique(GRINstruct.csus);
    
    
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
    YL=[-.15 .15];
    

    % PLOT ALL THE TILES ON A SINGLE FIGURE WINDOW. THIS PLOTS THE FIRST
    % AXIS IN THE BOTTOM LEFT CORNER AND FIRST FILLS UPWARD THEN RIGHTWARD
    for ii = 1:size(pixels,1)

        axh{ii} = axes('Position',[aX(ii) aY(ii) (1/(size(pxl,1)+1)) (1/(size(pxl,2)+1))],...
        'Color','none','Tag',num2str(ii)); 
        % axis off;
        hold on;
    
        % h = squeeze(pixels(ii,:,:));
        pha = plot( 1:size(pixels,2) , squeeze(pixels(ii,:,:)));
        set(gca,'YLim',YL)
        line([CSUSonoff(1) CSUSonoff(1)],YL,'Color',[.8 .8 .8])
        line([CSUSonoff(2) CSUSonoff(2)],YL,'Color',[.8 .8 .8])
        
        
        set(axh{ii},'ButtonDownFcn',@(~,~)disp(gca),...
        'HitTest','on')
        
    end
        pause(.05)
    
    
    
    
    legpos = {  [0.01,0.94,0.15,0.033], ...
                [0.01,0.90,0.15,0.033], ...
                [0.01,0.86,0.15,0.033], ...
                [0.01,0.82,0.15,0.033], ...
                [0.01,0.78,0.15,0.033], ...
                [0.01,0.74,0.15,0.033], ...
                };
    
    pc = {pha.Color};
    pt = CSids;
    
    for nn = 1:size(pixels,3)
        
    annotation(fh10,'textbox',...
    'Position',legpos{nn},...
    'Color',pc{nn},...
    'FontWeight','bold',...
    'String',pt(nn),...
    'FontSize',14,...
    'FitBoxToText','on',...
    'EdgeColor',pc{nn},...
    'FaceAlpha',.7,...
    'Margin',3,...
    'LineWidth',2,...
    'VerticalAlignment','bottom',...
    'BackgroundColor',[1 1 1]);
    
    end
    
    annotation(fh10,'textbox',...
    'Position',[.01 .97 .2 .05],...
    'Color',[0 0 0],...
    'FontWeight','bold',...
    'String','RIGHT-CLICK ON ANY GRAPH TO OPEN ADVANCED REPLOT GUI',...
    'FontSize',14,...
    'FitBoxToText','on',...
    'EdgeColor','none',...
    'FaceAlpha',.7,...
    'Margin',3,...
    'LineWidth',2,...
    'VerticalAlignment','bottom',...
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
    
    TILEplotGUI(axesdata, GRINstruct, XLSdata, LICK)
 
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
    
    GRINplotGUI(IMG, GRINstruct, XLSdata, LICK, IMGSraw)
 
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
            delete(axGRID.Children)
            delete(axGRID)
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
    
    CSids = unique(GRINstruct.csus);
    
    
    
    
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
    
    trials(nn,delaytoCS(nn):delaytoCS(nn)+10) = GRINstruct.id(nn);
    
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

hax1.YTickLabel = GRINstruct.csus;
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
% tv3{nn} = strcat(tv2{nn}, GRINstruct.csus{nn});
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






%% ------------------------- OUT OF USE ------------------------------


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





%% ------------------------- CALLBACKS & HELPERS ------------------------------


%----------------------------------------------------
%        PREVIEW IMAGE STACK
%----------------------------------------------------
function previewStack(hObject, eventdata)
disableButtons; pause(.02);

    % memocon('PREVIEWING IMAGE STACK')
    
    totframes = size(IMG,3);
    
    previewStacknum = str2num(previewStacknumH.String);

    
    if totframes >= previewStacknum
    
        IMGi = IMG(:,:,1:previewStacknum);
    
    
        [IMGcMax, IMGcMaxInd] = max(IMG(:));
        [IMGcMin, IMGcMinInd] = min(IMG(:));    
        % [I,J,tmp1] = ind2sub(size(IMG),cb1)
        % IMG(I,J,tmp1)
        
        axes(haxGRIN)
        phGRIN = imagesc(IMGi(:,:,1),'Parent',haxGRIN,'CDataMapping','scaled');
        cmax = max(max(max(IMGi)));
        cmin = min(min(min(IMGi)));
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
%        RUN CUSTOM FUNCTION
%----------------------------------------------------
function runCustomA(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION A!')

    [varargin] = grincustomA(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, muIMGS, LICK);

enableButtons        
memocon('Run custom function completed!')
end

function runCustomB(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION B!')

    [varargin] = grincustomB(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, muIMGS, LICK);

    
enableButtons        
memocon('Run custom function completed!')
end

function runCustomC(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION C!')

    [varargin] = grincustomC(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, muIMGS, LICK);

    
enableButtons        
memocon('Run custom function completed!')
end

function runCustomD(hObject, eventdata)
% disableButtons; pause(.02);
    
    mainguih.HandleVisibility = 'off';
    close all;
    mainguih.HandleVisibility = 'on';
        
    memocon('RUNNING CUSTOM FUNCTION D!')

    % grincustomD(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK);
    
    [Boundaries] = reverseSelectROI(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK);
    
    
    
enableButtons        
memocon('Run custom function completed!')
end



%----------------------------------------------------
%        EXPORT DATA TO BASE WORKSPACE
%----------------------------------------------------
function exportvars(hObject, eventdata)
% disableButtons; pause(.02);

    if size(GRINtable,1) > 1
        checkLabels = {'Save IMG to variable named:' ...
                   'Save GRINstruct to variable named:' ...
                   'Save GRINtable to variable named:' ...
                   'Save XLSdata to variable named:' ...
                   'Save IMGraw to variable named:'...
                   'Save IMGSraw to variable named:'...
                   'Save muIMGS to variable named:'...
                   'Save LICK to variable named:'}; 
        varNames = {'IMG','GRINstruct','GRINtable','XLSdata','IMGraw','IMGSraw','muIMGS','LICK'}; 
        items = {IMG,GRINstruct,GRINtable,XLSdata,IMGraw,IMGSraw,muIMGS,LICK};
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
        
        

        
        
        
        [filen,pathn] = uiputfile([GRINstruct.file(1:end-4),'.mat'],'Save Vars to Workspace');
            
        if isequal(filen,0) || isequal(pathn,0)
           memocon('User selected Cancel')
        else
           memocon(['User selected ',fullfile(pathn,filen)])
        end
        
        % IMGint16 = uint16(IMG);
        % IMG = single(IMG);
                
        memocon('Saving data to .mat file, please wait...')
        save(fullfile(pathn,filen),'IMG','GRINstruct','GRINtable','XLSdata',...
            'LICK','IMGraw','muIMGS','IMGSraw','-v7.3')
        % save(fullfile(pathn,filen),'IMGint16','GRINstruct','GRINtable','-v7.3')
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

        [filen,pathn] = uiputfile([GRINstruct.file(1:end-4),'.mat'],'Save Vars to Workspace');
        if isequal(filen,0) || isequal(pathn,0)
           memocon('Data Save Cancelled'); return
        end; memocon('Saving data to .mat file, please wait...')

        disableButtons; pause(.02);

        save(fullfile(pathn,filen),'IMG','GRINstruct','GRINtable','XLSdata',...
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


        [filen,pathn] = uiputfile([GRINstruct.file(1:end-4),'.mat'],'Save Vars to Workspace');
        if isequal(filen,0) || isequal(pathn,0)
           memocon('Data Save Cancelled'); return
        end; memocon('Saving data to .mat file, please wait...')

        disableButtons; pause(.02);

        save(fullfile(pathn,filen),'IMG','GRINstruct','GRINtable','XLSdata',...
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
%        LOAD .mat DATA
%----------------------------------------------------
function loadmatdata(hObject, eventdata)
% disableButtons; pause(.02);


    [filename, pathname] = uigetfile( ...
    {'*.mat'}, ...
   'Select a .mat datafile');
    
    IMG = [];
    IMGSraw = [];
    muIMGS = [];

memocon('Loading data from .mat file, please wait...')
disableButtons; pause(.02);    

    LODIN = load([pathname, filename]);
    
    
    [IMG] = deal(LODIN.IMG);
    [GRINstruct] = deal(LODIN.GRINstruct);
    [GRINtable] = deal(LODIN.GRINtable);
    [XLSdata] = deal(LODIN.XLSdata);
    [muIMGS] = deal(LODIN.muIMGS);
    [IMGSraw] = deal(LODIN.IMGSraw);
    [LICK] = deal(LODIN.LICK);
    [IMhist] = deal(LODIN.IMhist);
    
    
    if isa(IMG, 'single')

        memocon('loading single precision dataset...')
        IM = IMG;
        IMG = double(IM);
        
    else
        
        memocon('loading uint16-compressed dataset...')
        IM = IMG;
        IMG = double(IM);
        lintrans = @(x,a,b,c,d) (c.*(1-(x-a)./(b-a)) + d.*((x-a)./(b-a)));
        IMG = lintrans(IMG,min(min(min(min(IMG)))),max(max(max(max(IMG)))),IMhist.minIM,IMhist.maxIM);
        
    end
    
    LODIN = [];
    IM = [];
    
    previewStack

    clc;
    memocon('Dataset loaded with the following history...')
    memocon(IMhist)
    memocon('Experimental parameters...')
    memocon(XLSdata.CSUSvals)
    memocon('Image stack sizes...')
    memocon(['size(IMG) :  ' num2str(size(IMG))])
    memocon(['size(muIMGS) :  ' num2str(size(muIMGS))])
    memocon(['size(IMGSraw) :  ' num2str(size(IMGSraw))])

memocon('Dataset fully loaded, GRIN Toolbox is Ready!')
enableButtons        
end





%----------------------------------------------------
%        OPEN IMAGEJ API
%----------------------------------------------------
function openImageJ(hObject, eventdata)
% disableButtons; pause(.02);


    memocon('LAUNCHING ImageJ (FIJI) using MIJ!')
    
    matfiji(IMG(:,:,1:100), GRINstruct, XLSdata, LICK)
        

  
    
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

        IM = IMG(:,:,1:XLSdata.framesPerTrial);
        
        vol = [round(XLSdata.sizeIMG(1)*.25),round(XLSdata.sizeIMG(1)*.5),...
               round(XLSdata.sizeIMG(2)*.25),round(XLSdata.sizeIMG(2)*.5),...
               1,XLSdata.framesPerTrial];
        
        isoval = 5;
        
    else
        
        IM = IMG(:,:,1:XLSdata.framesPerTrial,1);
        
        vol = [round(XLSdata.sizeIMG(1)*.25),round(XLSdata.sizeIMG(1)*.5),...
               round(XLSdata.sizeIMG(2)*.25),round(XLSdata.sizeIMG(2)*.5),...
               1,XLSdata.framesPerTrial];
        
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
        % GRINstruct
    end
        
    stimnum = CSUSpopupH.Value;

    % CSUSvals = unique(GRINstruct.csus);
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

end




%----------------------------------------------------
%        MEMO LOG UPDATE
%----------------------------------------------------
function memocon(spf)
    
    if iscellstr(spf)
        spf = [spf{:}];
    end
    
    if iscell(spf)
        keyboard
        spf = [spf{:}];
    end
    
    if ~ischar(spf)
        keyboard
        spf = [spf{:}];
    end
    
    

    memes(1:end-1) = memes(2:end);
    memes{end} = spf;
    conboxH.String = memes;
    pause(.02)

end



end
%% EOF