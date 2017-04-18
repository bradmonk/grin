
clc; close all; clear;

% memocon('Loading data from .mat file, please wait...')

[filename, pathname] = uigetfile({'*.mat'},'Select a .mat datafile');

regexpStr = '((\S)+(\.mat+))';
fileinfo = dir(pathname);
filenames = {fileinfo.name};
 
datafiles = filenames(~cellfun('isempty',regexp(filenames,regexpStr)));
datafiles = reshape(datafiles,size(datafiles,2),[]);


TILE = {};
GRINstruct = {};
XLSdata = {};

for nn = 1:length(datafiles)

    LODIN = load([pathname, datafiles{nn}]);

    TILE{nn}        = LODIN.TILE;
    GRINstruct{nn}  = LODIN.GRINstruct;
    XLSdata{nn}     = LODIN.XLSdata;

end


%% GET NUMBER OF: DAYS , GROUPS , TILES , FRAMES
clearvars -except TILE GRINstruct XLSdata
clc; close all;

% nd : number of days
% ng : number of groups
% nt : number of tiles
% nf : number of frames
% MX = (nf, nt, ng, nd)

nd = length(TILE);
for ff = 1:nd
    groups{ff} = unique(GRINstruct{ff}.csus);
    ng(ff) = size(groups{ff},1);
    nt(ff) = size(TILE{ff},2);
    nf(ff) = size(TILE{ff}{1},1);
    
    nf_BL(ff) = numel(                          1    : XLSdata{ff}.CSonsetFrame-1  );
    nf_CS(ff) = numel(   XLSdata{ff}.CSonsetFrame    : XLSdata{ff}.CSoffsetFrame   );
    nf_US(ff) = numel(   XLSdata{ff}.CSoffsetFrame+1 : XLSdata{ff}.framesPerTrial  );    
    
end


nf_BL(ff) + nf_CS(ff) + nf_US(ff)
numel(XLSdata{ff}.CSonsetFrame : XLSdata{ff}.CSoffsetFrame)






%% CREATE EMPTY VARS FOR HOLDING RESPONSE AND MAX RESPONSE DATA


% THE MINIMUM NUMBER OF FRAMES IN EACH BL MUST BE MADE EQUAL TO
% THE NUMBER OF FRAMES IN CS, ONE WAY OR ANOTHER


% minBL = min(nf_BL);
% minCS = min(nf_CS);
% minUS = min(nf_US);
% 
% if minBL < minCS
%     
%     for d = 1:nd
%         for t = 1:nt
%         
%         dtTILE = TILE{d}{t};
%         
%         nf_BL(ff) = dtTILE(                          1    : XLSdata{d}.CSonsetFrame-1  );
%         nf_CS(ff) = dtTILE(   XLSdata{ff}.CSonsetFrame    : XLSdata{ff}.CSoffsetFrame   );
%         nf_US(ff) = dtTILE(   XLSdata{ff}.CSoffsetFrame+1 : XLSdata{ff}.framesPerTrial  ); 
%         
%     end
%     
%     
% 
%     
%     
%     min(nf_CS)
%     
%     nf_US




if all(ng(1) == ng(2:end)) && all(nt(1) == nt(2:end)) && all(nf(1) == nf(2:end))
    
    BL = zeros(  ng(1)  ,  nf(1)  ,  nt(1)  ,   nd  );
    CS = BL;
    US = BL;
    
    maxBL = zeros(  nd , nt(1)  );
    maxCS = zeros(  nd , nt(1)  );
    maxUS = zeros(  nd , nt(1)  );
else
    % msgbox('DETECTED UNEQUAL FRAMES, GROUPS, OR TILES');
    % return
end





% if all(ng(1) == ng(2:end)) && all(nt(1) == nt(2:end)) && ~all(nf(1) == nf(2:end))
%     
%     nf_BL
%     
%     nf_CS
%     
%     nf_US
%     
%     
% end



%% 
clc;

BLdat={};CSdat={};USdat={};

for day = 1:nd
    
    for ti = 1:nt(day)
    
        BLdat{day,ti} = TILE{day}{ti}(1:XLSdata{day}.CSonsetFrame,:);
        CSdat{day,ti} = TILE{day}{ti}(XLSdata{day}.CSonsetFrame:XLSdata{day}.CSoffsetFrame,:);
        USdat{day,ti} = TILE{day}{ti}(XLSdata{day}.CSoffsetFrame:XLSdata{day}.framesPerTrial,:);

    end
end

disp(BLdat(:,1))
disp(CSdat(:,1))
disp(USdat(:,1))

clc;

BL = [];
CS = [];
US = [];

for day = 1:nd
    for ti = 1:nt(day)
        
        BL(:,:,ti,day) = BLdat{day,ti};
        CS(:,:,ti,day) = CSdat{day,ti};
        US(:,:,ti,day) = USdat{day,ti};                
    end
end

size(BL)
size(CS)
size(US)


%% EQUALIZE FRAME NUMBER TO CS


szBL = size(BL,1)
szCS = size(CS,1)
szUS = size(US,1)

    BL = BL(szBL-szCS+1:szBL,:,:,:);
    US = US(1:szCS,:,:,:);
    
size(BL)
size(CS)
size(US)



%%


maxBL = [];
maxCS = [];
maxUS = [];

for day = 1:nd
    for ti = 1:nt(day)
        
        maxBL(ti,day) = max(max(BL(:,:,ti,day)));
        maxCS(ti,day) = max(max(CS(:,:,ti,day)));
        maxUS(ti,day) = max(max(US(:,:,ti,day)));
    end
end



%%

mxBL = maxBL';
[BLval, BLind] = sort(maxBL, 1, 'descend');
BLr = BLind(1:10,:);


mxCS = maxCS';
[CSval, CSind] = sort(maxCS, 1, 'descend');
CSr = CSind(1:10,:);



mxUS = maxUS';
[USval, USind] = sort(maxUS, 1, 'descend');
USr = USind(1:10,:);



%%

size(BL)

BL_fgd = [];
CS_fgd = [];
US_fgd = [];


for d = 1:nd
    for g = 1:ng(d)

    BL_fgd(:,g,d) = squeeze(  mean( BL(:,g,BLr(:,d),d) ,3)  );

    CS_fgd(:,g,d) = squeeze(  mean( CS(:,g,CSr(:,d),d) ,3)  );

    US_fgd(:,g,d) = squeeze(  mean( US(:,g,USr(:,d),d) ,3)  );

    end
end

size(BL_fgd)

%%

size(BL_fgd)

BL_fd = {};
CS_fd = {};
US_fd = {};

for g = 1:ng(1)

    BL_fd{g} = squeeze(  BL_fgd(:,g,:)   );

    CS_fd{g} = squeeze(  CS_fgd(:,g,:)   );

    US_fd{g} = squeeze(  US_fgd(:,g,:)   );

end


disp(BL_fd)

BL_gd = [];
CS_gd = [];
US_gd = [];

BL_gd = squeeze(  mean( BL_fgd , 1 )  );

CS_gd = squeeze(  mean( CS_fgd , 1 )  );

US_gd = squeeze(  mean( US_fgd , 1 )  );


%%

BLCSUS_G1 = [BL_fd{1} ; CS_fd{1} ; US_fd{1}];

BLCSUS_G2 = [BL_fd{2} ; CS_fd{2} ; US_fd{2}];



BLfrms = [1 size(BL_fd{1},1)];
CSfrms = [BLfrms(2)+1 BLfrms(2)+1+size(CS_fd{1},1)];
USfrms = [CSfrms(2)+1 CSfrms(2)+1+size(US_fd{1},1)];

%%

close all;
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .7 .8],'Color','w'); % ,'MenuBar','none'

hax1 = axes('Parent',fh1,'Color','none',...
    'Position',[0.1 0.1 0.88 0.88],'NextPlot','add','FontSize',14); % ,'XLimMode','manual','YLimMode','manual'
hax2 = axes('Parent',fh1,'Color','none',...
    'Position',[0.1 0.1 0.88 0.88],'NextPlot','add','FontSize',14); % ,'XDir','reverse' 
hax2.XColor = 'none';
hax2.YColor = 'none';
hax2.ZColor = 'none';
hax2.XTick = [];
hax2.YTick = [];
hax2.ZTick = [];
hax2.XLim = [1 nd];
hax2.YLim = [1 USfrms(2)];
hax2.ZLim = [-.1 .25];
hax1.XLim = [1 USfrms(2)];
hax1.YLim = [-.1 .25];
hold on



axes(hax1)
ps0 = plot(hax1, BLCSUS_G1(:,1),'r','LineWidth',5);
hold on;
pause(1)
ps0 = plot(hax1, BLCSUS_G1(:,2),'b','LineWidth',5);
hold on
% pause(1)
% ps0 = plot(hax1, BLCSUS_G1(:,3),'LineWidth',3);
% hold on;
% pause(1)
% ps0 = plot(hax1, BLCSUS_G1(:,4),'LineWidth',3);
% hold on;
% pause(1)
% ps0 = plot(hax1, BLCSUS_G1(:,5),'LineWidth',3);
% hold on;
% pause(1)




line([size(BL_fd{1},1) size(BL_fd{1},1)],hax1.YLim,...
    'Color',[.7 .7 .7],'Parent',hax1)
line([size(BL_fd{1},1)+size(CS_fd{1},1) size(BL_fd{1},1)+size(CS_fd{1},1)],hax1.YLim,...
    'Color',[.7 .7 .7],'Parent',hax1)

pause(3)


hax1.XColor = 'none';
hax1.YColor = 'none';
hax1.XTick = [];
hax1.YTick = [];


axes(hax2)
hax2.XDir = 'reverse';
ps1 = surf(BLCSUS_G1(:,1:2),'FaceColor','interp','EdgeColor','none',...
                     'FaceLighting','gouraud');
                 
% hax2.XLim = [1 nd];
% hax2.YLim = [1 USfrms(2)];
% hax2.ZLim = [-.1 .25];           
view(90,0)
axes(hax1)
pause(3)




axes(hax2)
% hax2.XDir = 'reverse';
ps1 = surf(BLCSUS_G1,'FaceColor','interp','EdgeColor','none',...
                     'FaceLighting','gouraud');
% axis tight
camlight right

shading interp
lightangle(-45,30)
ps1.FaceLighting = 'gouraud';
ps1.AmbientStrength = 0.3;
ps1.DiffuseStrength = 0.8;
ps1.SpecularStrength = 0.9;
ps1.SpecularExponent = 25;
ps1.BackFaceLighting = 'unlit';


axes(hax1)
pause(3)
axes(hax2)

% ph1 = patch(surf2patch(ps1));
% delete(ps1)
% shading faceted;
delete(hax1.Children)
% hax1.Visible = 'off';

az=linspace(90,85,20);
el=linspace(0,30,20);
for nn = 1:numel(az)
    view(az(nn),el(nn))
    pause(.05) 
end


view(az(end),el(end))

% hax1.ZLim = [-.1 .25];
hax1.XTick = 1:5;
hax1.XLabel.String = 'DAYS';
hax1.YLabel.String = 'FRAMES';
hax1.ZLabel.String = 'INTENSITY';

hold on;




ps0 = surf([BL_fd{1}.*0-.1 ; CS_fd{1} ; US_fd{1}.*0-.1],...
          'FaceAlpha',.2,'LineWidth',0.3);
hidden off

% surfl(CS_fd{1})
% shading interp



az=linspace(az(end),0,60);
el=linspace(el(end),35,60);
for nn = 1:numel(az)
    view(az(nn),el(nn))
    pause(.05) 
end

az=linspace(az(end),180,180);
el=linspace(el(end),34,180);
for nn = 1:numel(az)
    view(az(nn),el(nn))
    pause(.05) 
end
az=linspace(az(end),0,180);
el=linspace(el(end),35,180);
for nn = 1:numel(az)
    view(az(nn),el(nn))
    pause(.05) 
end

az=linspace(az(end),85,90);
el=linspace(el(end),30,90);
for nn = 1:numel(az)
    view(az(nn),el(nn))
    pause(.05) 
end

az=linspace(az(end),90,60);
el=linspace(el(end),0,60);
for nn = 1:numel(az)
    view(az(nn),el(nn))
    pause(.05) 
end
    
% hax1.Visible = 'on';


axes(hax1)
ps0 = plot(hax1, BLCSUS_G1(:,1),'LineWidth',5);
ps0.Color = [0.0 1.0 0.0];
hold on;
pause(1)
ps0 = plot(hax1, BLCSUS_G1(:,2),'LineWidth',5);
ps0.Color = [0.0 0.9 0.2];
hold on
pause(1)
ps0 = plot(hax1, BLCSUS_G1(:,3),'LineWidth',5);
ps0.Color = [0.0 0.7 0.3];
hold on;
pause(1)
ps0 = plot(hax1, BLCSUS_G1(:,4),'LineWidth',5);
ps0.Color = [0.0 0.3 0.7];
hold on;
pause(1)
ps0 = plot(hax1, BLCSUS_G1(:,5),'LineWidth',5);
ps0.Color = [0.0 0.0 1.0];
hold on;
pause(1)

delete(hax1.Children)
axes(hax2)
pause(1)

az=linspace(az(end),80,180);
el=linspace(el(end),30,180);
for nn = 1:numel(az)
    view(az(nn),el(nn))
    pause(.05) 
end


% axes(hax2)

%%
close all;
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .7 .8],'Color','w','MenuBar','none');

hax1 = axes('Parent',fh1,'Color','none','XLimMode','manual','YLimMode','manual',...
    'Position',[0.05 0.05 0.90 0.90],'NextPlot','add'); 
    hax1.YLim = [-.1 .2];
    hax1.XLim = [1 size(muCS_FAC,2)];
    hold on
    
    
hax1.ColorOrderIndex = 1;
phBLFAC = plot(mean(muBL_FAC,1),'-','LineWidth',1); hold on;
phBLCOF = plot(mean(muBL_COF,1),'-','LineWidth',1); hold on;    
    
hax1.ColorOrderIndex = 1;
phCSFAC = plot(mean(muCS_FAC,1),'--','LineWidth',3); hold on;
phCSCOF = plot(mean(muCS_COF,1),'--','LineWidth',3); hold on;

hax1.ColorOrderIndex = 1;
phUSFAC = plot(mean(muUS_FAC,1),':','LineWidth',3); hold on;
phUSCOF = plot(mean(muUS_COF,1),':','LineWidth',3); hold on;




leg1 = legend({'BL FACTOR','BL COFACTOR','CS FACTOR','CS COFACTOR','US FACTOR','US COFACTOR'});
	set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4]);



%%


DmuBL_FAC = mean(muBL_FAC,1);
DmuCS_FAC = mean(muCS_FAC,1);
DmuUS_FAC = mean(muUS_FAC,1);



[DmuBL_FAC; DmuCS_FAC; DmuUS_FAC]






%%
close all;
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .7 .8],'Color','w','MenuBar','none');

hax1 = axes('Parent',fh1,'Color','none','XLimMode','manual','YLimMode','manual',...
    'Position',[0.05 0.05 0.90 0.90],'NextPlot','add'); 
    hax1.YLim = [-.1 .2];
    hax1.XLim = [1 size(muCS_FAC,2)];
    hold on
    
    
hax1.ColorOrderIndex = 1;
phFAC = plot([mean(muBL_FAC) mean(muUS_FAC) mean(muUS_FAC)],...
                '-','LineWidth',1); hold on;
phCOF = plot([mean(muBL_COF,2) mean(muUS_COF) mean(muUS_COF)],...
                '-','LineWidth',1); hold on;


leg1 = legend({'BL FACTOR','BL COFACTOR','CS FACTOR','CS COFACTOR','US FACTOR','US COFACTOR'});
	set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4]);    
    

%% PLOT TILE VALUES
close all;

groups = unique(GRINstruct{1}.csus);


BLdat = TILE{1}{1}(1:XLSdata{1}.CSonsetFrame,:);
CSdat = TILE{1}{1}(XLSdata{1}.CSonsetFrame:XLSdata{1}.CSoffsetFrame,:);
USdat = TILE{1}{1}(XLSdata{1}.CSoffsetFrame:XLSdata{1}.framesPerTrial,:);


CSd = CSdat;
USd = USdat(1:length(CSd),:);
BLd = BLdat(end-length(CSd)+1:end,:);

fh1=figure('Units','normalized','OuterPosition',[.1 .1 .8 .6],'Color','w','MenuBar','none');

hax1 = axes('Parent',fh1,'Color','none','XLimMode','manual','YLimMode','manual',...
    'Position',[0.05 0.05 0.90 0.90],'NextPlot','add'); 
    hax1.YLim = [-.1 .2];
    hax1.XLim = [1 size(CSd,1)];
    hold on
   
hax1.ColorOrderIndex = 1;    
ph1 = plot(hax1, BLd,'-','LineWidth',3); hold on;
hax1.ColorOrderIndex = 1;
ph2 = plot(hax1, CSd,'--','LineWidth',3); hold on;
hax1.ColorOrderIndex = 1;
ph3 = plot(hax1, USd,':','LineWidth',3); hold on;

leg1 = legend([strcat(groups', {' baseline', ' baseline'}),...
               strcat(groups', {' CS', ' CS'}),...
               strcat(groups', {' US', ' US'}) ]'   );
	set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4]);
    
Y1a = BLd(:,1);
Y1b = BLd(:,2);
Y2a = CSd(:,1);
Y2b = CSd(:,2);
Y3a = USd(:,1);
Y3b = USd(:,2);

ph1(1).YDataSource = 'Y1a';
ph1(2).YDataSource = 'Y1b';
ph2(1).YDataSource = 'Y2a';
ph2(2).YDataSource = 'Y2b';
ph3(1).YDataSource = 'Y3a';
ph3(2).YDataSource = 'Y3b';

refreshdata

%%
for ff = 1:length(TILE)
    
    for tt = 1:length(TILE{ff})
    
        BLdat = TILE{ff}{tt}(1:XLSdata{ff}.CSonsetFrame,:);
        CSdat = TILE{ff}{tt}(XLSdata{ff}.CSonsetFrame:XLSdata{ff}.CSoffsetFrame,:);
        USdat = TILE{ff}{tt}(XLSdata{ff}.CSoffsetFrame:XLSdata{ff}.framesPerTrial,:);
        
        CSd = CSdat;
        USd = USdat(1:length(CSd),:);
        BLd = BLdat(end-length(CSd)+1:end,:);
        
        Y1a = BLd(:,1);
        Y1b = BLd(:,2);
        Y2a = CSd(:,1);
        Y2b = CSd(:,2);
        Y3a = USd(:,1);
        Y3b = USd(:,2);
        
        refreshdata
        
        disp([ff tt])
        pause(.1)
        
    end
    
    maxT(nn) = max(max(tiledatY{nn}));
end











    
    
    
%% NOTES AND EXAMPLE CODE
%{
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

%}


