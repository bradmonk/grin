%% GRINimregister

%% PURGE RAM
clc; close all; clear;
system('sudo purge')
F = what('grindata');
cd(F.path);



%% GET PATHS TO GRIN DATA MAT FILES
clc; close all; clear

datafilepath = uigetdir;
regexpStr = '((\S)+(\.mat+))';
allfileinfo = dir(datafilepath);
allfilenames = {allfileinfo.name};
r = regexp(allfilenames,regexpStr);                        
datafiles = allfilenames(~cellfun('isempty',r));      
datafiles = reshape(datafiles,size(datafiles,2),[]);
datapaths = fullfile(datafilepath,datafiles);
disp(' '); fprintf('   %s \r',  datafiles{:} ); disp(' ')
disp(' '); fprintf('   %s \r',  datapaths{:} ); disp(' ')
clearvars -except datapaths datafiles




%% IMPORT DATASETS INTO CELL STRUCT

% IMPORT DATASETS
DATA = cell(size(datapaths));

for nn = 1:size(datapaths,1)

    DATA{nn} = load(datapaths{nn});

    IMGC = DATA{nn}.IMGS;
    DATA{nn} = rmfield(DATA{nn},'IMGS');
    DATA{nn}.IMGC = IMGC;

end

clearvars -except datapaths datafiles DATA


%% PREVIEW IMAGE STACK FROM FIRST STACK

I = DATA{1}.IMGC;
I = mean(I,4);

figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
axes('Position',[.05 .05 .9 .9],'Color','none');

ph1 = imagesc(I(:,:,1)); pause(1)

for nn = 1:size(I,3)
    fprintf('Stack: % .0f \n',nn)
    ph1.CData = I(:,:,nn);
    pause(.04)
end

close all
clearvars -except datapaths datafiles DATA









%% MAKE EVERY DAY 40 X 40 IMAGE


if size(DATA{1}.IMGC , 1) ~= 40 

for mm = 1:size(DATA,1)

    I = DATA{mm}.IMGC;

    B = imresize(I,[40 40]);

    DATA{mm}.IMGC = B;

end

end


clc; clearvars -except datapaths datafiles DATA



%% NORMALIZE TO RED CHANNEL THEN DISCARD RED CHANNEL




% TBD







%% SAVE GREEN CHANNEL PROJECTION IMAGE FOR EACH DAY INTO 'IM'
clc;

IM = zeros(size(DATA{1}.IMGC,1),size(DATA{1}.IMGC,2),size(DATA,1));

for mm = 1:size(DATA,1)

    I = DATA{mm}.IMGC;

    IM(:,:,mm) = mean(mean(I,4),3);

end


clearvars -except datapaths datafiles DATA IM









%% PREVIEW PROJECTION 'IM' STACK

fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');

ph1 = imagesc(IM(:,:,1)); pause(1)

for nn = 1:size(IM,3)
    fprintf('Stack: % .0f \n',nn)
    ph1.CData = IM(:,:,nn);
    pause(.5)
end


clearvars -except datapaths datafiles DATA IM



%% SHOW MONTAGE OF EACH DAY'S PROJECTION IMAGE

close all
fh1=figure('Units','normalized','OuterPosition',[.05 .06 .9 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.01 .04 .97 .95],'Color','none'); %hold on;

clc
disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
disp('CLOSE WINDOW WHEN READY TO CONTINUE')
disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
disp(' ')

I = mat2gray(reshape(IM,40,40,1,[]));

hm = montage(I,'Parent',hax1, 'Size', [NaN 9]);

colormap(jet)

uiwait
close all;



%% GET ALIGNMENT VALUES
clc; disp('CHOOSE TWO ALIGNMENT LANDMARKS'); disp(' ')


AlignVals.P1x = zeros(size(IM,3),1);
AlignVals.P1y = zeros(size(IM,3),1);
AlignVals.P2x = zeros(size(IM,3),1);
AlignVals.P2y = zeros(size(IM,3),1);


for nn = 1:size(IM,3)

I = IM(:,:,nn);

close all;

fhIMA=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
haxIMA = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);


% axes(haxIMA)
phG = imagesc(I,'Parent',haxIMA,'CDataMapping','scaled');
% phG = imshowpair(IM(:,:,1), I,'Scaling','independent');

% [cmax, cmaxi] = max(I(:));
% [cmin, cmini] = min(I(:));
% cmax = cmax - abs(cmax/12);
% cmin = cmin + abs(cmin/12);
% haxIMA.CLim = [cmin cmax];


% SELECT TWO ROI POINTS
hAP1 = impoint;
hAP2 = impoint;

AP1pos = hAP1.getPosition;
AP2pos = hAP2.getPosition;

imellipse(haxIMA, [AP1pos-2 4 4]); pause(.1);
imellipse(haxIMA, [AP2pos-2 4 4]); pause(.1);

pause(.5);
close(fhIMA)


fprintf('ALIGNMENT POINTS \n');
fprintf('P1(X,Y): \t    %.2f \t    %.2f \n',AP1pos);
fprintf('P2(X,Y): \t    %.2f \t    %.2f \n',AP2pos);


AlignVals.P1x(nn) = AP1pos(1);
AlignVals.P1y(nn) = AP1pos(2);
AlignVals.P2x(nn) = AP2pos(1);
AlignVals.P2y(nn) = AP2pos(2);

end


clearvars -except datapaths datafiles DATA IM AlignVals





%% USE ALIGNMENT VALUES FOR TRANSLATION
clc;

n = round(numel(AlignVals.P1x) / 2);

MASTER1x = AlignVals.P1x(n);
MASTER1y = AlignVals.P1y(n);
MASTER2x = AlignVals.P2x(n);
MASTER2y = AlignVals.P2y(n);

IMx = AlignVals.P1x;
IMy = AlignVals.P1y;

% tX = IMx - MASTER1x;
% tY = IMy - MASTER1y;

tX = MASTER1x - IMx;
tY = MASTER1y - IMy;



IMGC={};
for mm = 1:size(DATA,1)
    IMGC{mm} = DATA{mm}.IMGC;
end


IMGA={};
for i = 1:size(IMGC,2)

    G = IMGC{i};

    IMGA{i} = imtranslate(G,[tX(i), tY(i)],'FillValues',mean(G(:)),'OutputView','same');

end


clearvars -except datapaths datafiles DATA IM AlignVals IMGA






%% PREVIEW ALIGNMENT
clc; close all;


IG = zeros(size(IMGA{1},1) , size(IMGA{1},2) , size(IMGA,2));


for nn = 1:size(IG,3)

    IG(:,:,nn) = mean(mean(IMGA{nn},4),3);

end



%---------  PREVIEW ALIGNMENT AND CAPTURE GIF FRAMES  -----------

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');

ph1 = imagesc(IG(:,:,1)); pause(.2)

for nn = 1:size(IG,3)

    ph1.CData = IG(:,:,nn);
    title(DATA{nn}.GRINstruct.file,'Interpreter','none')
    pause(.4)

    frame = getframe(fh1);
    figframe{nn} = frame2im(frame);

end



% --- JUST WAIT TO SAVE A GIF OF THE CROPPED DATA BELOW ---
%
% clearvars -except datapaths datafiles DATA IM AlignVals IMGA IMRA IG IR...
% isred figframe
% 
% 
% %---------  SAVE ANIMATED GIF OF ALIGNMENT  -----------
% 
% filename = [DATA{1}.GRINstruct.file(1:4) '_aligned.gif'];
% 
% for i = 1:size(figframe,2)
% 
%     [A,map] = rgb2ind(figframe{i},256);
% 
%     if i == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',.5);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',.5);
%     end
% end
% 
% close all;


clearvars -except datapaths datafiles DATA IM AlignVals IMGA IG













%% GET CROPBOX COORDINATES FOR ALIGNED (REGISTERED) STACKS
clc; close all;

I = mean(IG,3);

disp(' '); 
disp('DRAG RECTANGLE TO DESIRED POSITION')
disp('THEN DOUBLE CLICK INSIDE RECTANGLE TO CONTINUE')

%---------  CREATE IMAGE CROPPING FIGURE  -----------
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none'); % ,'YDir','reverse'
phTRIM = imagesc(I,'Parent',hax1,'CDataMapping','scaled');
axis tight; colormap(hot(40))
pause(.07);


%---------  CREATE ROI RECTANGLE ON CROPPING FIGURE  -----------
cropAmount = 4;

[Iw,Ih,In] = size(I);

h = imrect(hax1, [cropAmount cropAmount Iw-cropAmount*2 Ih-cropAmount*2]);
setFixedAspectRatioMode(h,true)
setResizable(h,false)

CropPosition = wait(h);
close all;

% CropPosition = round(CropPosition);

pos = [ceil(CropPosition(1:2) - .5) ceil(CropPosition(3:4))];
cols = pos(1):(pos(1)+pos(3)-1);
rows = pos(2):(pos(2)+pos(4)-1);



clearvars -except datapaths datafiles DATA IM AlignVals IMGA IG...
CropPosition pos cols rows



%% CROP AND TILE ALIGNED IMAGE STACK FOR EACH DAY

%---- CROP IMAGES

IMGAC={}; 

for i = 1:size(IMGA,2)

    G = IMGA{i};
    IMGAC{i} = G(rows , cols , :, :);

end




%---------  PREVIEW ALIGNED & CROPPED STACK  -----------

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');

IMU = mean(mean(IMGAC{1},4),3);

ph1 = imagesc(IMU); pause(.2)

for nn = 1:size(IG,3)

    IMU = mean(mean(IMGAC{nn},4),3);

    ph1.CData = IMU;
    title(DATA{nn}.GRINstruct.file,'Interpreter','none')
    pause(.2)

    frame = getframe(fh1);
    figframe{nn} = frame2im(frame);

end


%---------  SAVE ANIMATED GIF OF ALIGNMENT  -----------

filename = [DATA{1}.GRINstruct.file(1:4) '_aligned_cropped.gif'];
for i = 1:size(figframe,2)
    [A,map] = rgb2ind(figframe{i},256);
    if i == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',.5);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',.5);
    end
end
close all;



clearvars -except datapaths datafiles DATA IM AlignVals IMGA IG IMGAC





% ################################################################
%%                      SAVE ALIGNED DATASET
% ################################################################

%---- SAVE STACK BACK INTO MAIN DATA CONTAINER
for i = 1:size(IMGAC,2)

    DATA{i}.IMAL = IMGAC{i};

end



for nn = 1:size(DATA,1)

    if isfield(DATA{nn}, 'blockSize')
        DATA{nn} = rmfield(DATA{nn},'blockSize');
    end

%     if isfield(DATA{nn}, 'IMGC')
%     DATA{nn} = rmfield(DATA{nn},'IMGC');
%     end
% 
%     if isfield(DATA{nn}, 'IMGR')
%     DATA{nn} = rmfield(DATA{nn},'IMGR');
%     end

end


clc; clearvars -except datapaths datafiles DATA IM AlignVals IMGA IG IMGAC


filename = [DATA{1}.GRINstruct.file(1:4) '_ALIGNED.mat'];

save(filename,'DATA')







return

open GRINbiganalysis_v2.m








%% OTHER CRAP...


%% CROP AND TILE ALIGNED IMAGE STACK FOR EACH DAY
%{
% s = size(IMGA{1},1);
% x = CropPosition(1);
% y = CropPosition(2);
% w = CropPosition(3);
% h = CropPosition(4);
% 
% 
% % %---- CROP IMAGES
% % IMGAC={}; IMRAC={};
% % for i = 1:size(IMGA,2)
% %     G = rot90(IMGA{i});
% %     R = rot90(IMRA{i});
% %     IMGAC{i} = rot90(  G(x:(x+w-1) , y:(y+h-1) , :)   ,-1);
% %     IMRAC{i} = rot90(  R(x:(x+w-1) , y:(y+h-1) , :)   ,-1);
% % end
% 
% %---- CROP IMAGES
% IMGAC={}; IMRAC={};
% for i = 1:size(IMGA,2)
%     G = IMGA{i};
%     R = IMRA{i};
%     IMGAC{i} = G(x:(x+w-1) , y:(y+h-1) , :, :);
%     IMRAC{i} = R(x:(x+w-1) , y:(y+h-1) , :, :);
% end
% 
% 
% 
% %---- RESIZE IMAGES
% for i = 1:size(IMGAC,2)
% 
%     IMGAC{i} = imresize(IMGAC{i}, 1/4 , 'bilinear');
%     IMRAC{i} = imresize(IMRAC{i}, 1/4 , 'bilinear');
% 
% end
% 
% % size(IMGA{1})
% % size(IMGAC{1})
% 
% 
% for i = 1:size(IMGAC,2)
% 
% DATA{i}.IMGAC = IMGAC{i};
% DATA{i}.IMRAC = IMRAC{i};
% 
% end
% 
% clc; close all;
% clearvars -except datapaths datafiles DATA IM AlignVals IMGA IMRA IG IR ...
% CropPosition
% 
% 
% 
% 
% 
% 
% %% PREVIEW ALIGNED AND CROPPED IMAGES
% 
% IMGAC={}; IMRAC={};
% for i = 1:size(DATA,2)
%     IMGAC{i} = DATA{i}.IMGAC;
%     IMRAC{i} = DATA{i}.IMRAC;
% end
% 
% 
% IG = zeros(size(IMGAC{1},1) , size(IMGAC{1},2) , size(IMGAC,2));
% IR = zeros(size(IMRAC{1},1) , size(IMRAC{1},2) , size(IMRAC,2));
% 
% for nn = 1:size(IG,3)
%     IG(:,:,nn) = mean(mean(IMGAC{nn},4),3);
%     IR(:,:,nn) = mean(mean(IMRAC{nn},4),3);
% end
% 
% figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
% axes('Position',[.05 .05 .9 .9],'Color','none');
% ph1 = imagesc(IG(:,:,1)); pause(1)
% for nn = 1:size(IG,3)
%     ph1.CData = IG(:,:,nn); pause(.8);
% end
% 
% 
% 
% clearvars -except datapaths datafiles DATA IM AlignVals IMGA IMRA IG IR ...
% CropPosition

%}


%% NORMALIZE DATASET
%{

IMGAC={}; IMRAC={};
for i = 1:size(DATA,2)
    IMGAC{i} = double(DATA{i}.IMGAC);
    IMRAC{i} = double(DATA{i}.IMRAC);
end

% Z = zscore(IMGAC{i},[],1);
% size(Z)


ZIMG = {};
for i = 1:size(DATA,2)

    I = IMGAC{i};
    s = size(IMGAC{i});
    ZIMG{i} = reshape(  zscore( I(:) ) , s  );

end


clearvars -except datapaths datafiles DATA IM AlignVals IMGA IMRA IG IR ...
CropPosition ZIMG


%----------------------------------------------------
%%        PLOT TILES OF RAW DATA
%----------------------------------------------------


for tt = 1:size(DATA,2)
close all;
% for tt = 1


    pxl = ZIMG{tt};
%     size(pxl)



    GRINstruct = DATA{1,tt}.GRINstruct;
    tf         = DATA{1,tt}.GRINstruct.tf;
    csus       = DATA{1,tt}.GRINstruct.csus;
    CSUSonoff  = DATA{1,tt}.GRINstruct.CSUSonoff;
    

    CSids = unique(csus);

    

    px = zeros(size(pxl,1),size(pxl,2),size(pxl,3),size(tf,2));

    for j = 1:size(tf,2)
        px(:,:,:,j) = mean(pxl(:,:,:,tf(:,j)),4);
    end

    pxl=px;

    pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    
    
    
    %-------------------------- MULTI-TILE FIGURE --------------------------

    fh10=figure('Units','normalized','OuterPosition',[.02 .02 .90 .90],'Color','w');
    
    set(fh10,'ButtonDownFcn',@(~,~)disp('figure'),'HitTest','off')
    
    
    
    aXlocs =  (0:(size(pxl,1))) .* (1/(size(pxl,1)));
    aXlocs(end) = [];
    aYlocs =  (0:(size(pxl,2))) .* (1/(size(pxl,2)));
    aYlocs(end) = [];
    aXlocs = aXlocs+.005;
    aYlocs = aYlocs+.005;
    [aX,aY] = meshgrid(aXlocs,aYlocs);
    
%     if strcmp(NormType,'dF')
%         
%         YL = [-.15 .15];
% 
%     elseif strcmp(NormType,'Zscore')
%         
        YL = [-1 3];
%         
%     elseif strcmp(NormType,'Dprime')
%         
%         YL = [-.15 .15];
%         
%     else
%         YL = 'auto';
%     end
    

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
        %ylim(YL)
        cYlim = get(gca,'YLim');
        line([CSUSonoff(1) CSUSonoff(1)],cYlim,'Color',[.8 .8 .8])
        line([CSUSonoff(2) CSUSonoff(2)],cYlim,'Color',[.8 .8 .8])
        
        set(axh{ii},'ButtonDownFcn',@(~,~)disp(gca),'HitTest','on')
        
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
    'String',GRINstruct.file,...
    'FontSize',12,...
    'FitBoxToText','on',...
    'EdgeColor','none',...
    'FaceAlpha',.7,...
    'Margin',3,...
    'LineWidth',2,...
    'VerticalAlignment','bottom',...
    'Interpreter','none',...
    'BackgroundColor',[1 1 1]);






% SET AXES LIMITS ACCORDING TO MIN MAX
% xL=zeros(size(axh,2) , 2);
% yL=zeros(size(axh,2) , 2);
% for j = 1:size(axh,2)
%     xL(j,:) = axh{j}.XLim;
%     yL(j,:) = axh{j}.YLim;
% end
% xLm = median(xL);  
% yLm = median(yL);  
% for j = 1:size(axh,2)
%     axh{j}.XLim = xLm;
%     axh{j}.YLim = yLm;
% end



for j = 1:size(axh,2)
    axh{j}.YLim = YL;
end




% cd(path);
set(gcf, 'PaperPositionMode', 'auto');
saveas(gcf,[DATA{tt}.GRINstruct.file(1:end-6) '_Z'],'png');
% cd(path);



    pause(.2)
    %-------------------------------------------------------------------------
    
%     pcabutton = uicontrol(fh10,'Units','normalized',...
%                   'Position',[.065 .003 .06 .04],...
%                   'String','PCA',...
%                   'Tag','gridbutton',...
%                   'Callback',{@runPCA,axh,pha,pixels,tiledatX,tiledatY}); 
%     
%     
%     gridbutton = uicontrol(fh10,'Units','normalized',...
%                   'Position',[.003 .003 .06 .04],...
%                   'String','Toggle Grid',...
%                   'Tag','gridbutton',...
%                   'Callback',@toggleGridOverlay);
%     
%     
%     savetilesH = uicontrol(fh10,'Units','normalized',...
%                   'Position',[.96 .003 .04 .04],...
%                   'String','Save',...
%                   'Tag','gridbutton',...
%                   'Callback',@savetilesfun);    


clearvars -except datapaths datafiles DATA IM AlignVals IMGA IMRA IG IR ...
CropPosition ZIMG tt
end
    
        
        







%% COMPUTE DF/F FOR RED AND GREEN STACKS


for nn = 1:size(DATA,2)
    fprintf('Computing df/f for stack % .0f  of % .0f \n',nn,size(DATA,2))

    IMGC = double(DATA{nn}.IMGC);

    CSonsetFrame = DATA{nn}.XLSdata.CSonsetFrame;

    baseIMG = mean(IMGC(:,:,1:CSonsetFrame,:),3);

    im = repmat(baseIMG,1,1,size(IMGC,3),1);

    IMGf = (IMGC - im) ./ im;
    
    IMGC = IMGf;




    IMRC = double(DATA{nn}.IMRC);

    CSonsetFrame = DATA{nn}.XLSdata.CSonsetFrame;

    baseIMG = mean(IMRC(:,:,1:CSonsetFrame,:),3);

    im = repmat(baseIMG,1,1,size(IMRC,3),1);

    IMGf = (IMRC - im) ./ im;
    
    IMRC = IMGf;



    DATA{nn}.IMGC = IMGC;
    DATA{nn}.IMRC = IMRC;
end

clearvars -except datapaths datafiles DATA




%% NORMALIZE GREEN - RED CHANNEL STACKS


for nn = 1:size(DATA,2)

    IM = DATA{nn}.IMGC - DATA{nn}.IMRC;

    DATA{nn}.IMG = IM;
end

clearvars -except DATA






























%% Write to TIFF file
%{.

% imagesc(I(:,:,1))

I = mat2gray(IMA);
imwrite(I(:,:,1), 'stack.tif'); % tif compression is lossless by default
for k = 1:size(I,3)
    imwrite(I(:,:,k), 'stack.tif', 'writemode', 'append');
end



numrows = size(IMA,1);
numcols = size(IMA,2);
alpha = 255*ones([numrows numcols], 'uint8');
data = cat(3,IMA,alpha);


t = Tiff('myfile.tif','w');
tagstruct.ImageLength = size(IMA,1)
tagstruct.ImageWidth = size(IMA,2)
% tagstruct.Photometric = Tiff.Photometric.RGB
tagstruct.BitsPerSample = 8
tagstruct.SamplesPerPixel = size(IMA,3)
tagstruct.RowsPerStrip = size(IMA,1)
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky
tagstruct.Software = 'MATLAB'
t.setTag(tagstruct)

width = t.getTag('ImageWidth');
height = t.getTag('RowsPerStrip');
numSamples = t.getTag('SamplesPerPixel');
stripData = zeros(height,width,numSamples,'uint8');

t.writeEncodedStrip(1, stripData);

t.write(data);
t.close();


%% PREVIEW TRANSLATED IMAGE STACK
close all

fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');

ph1 = imagesc(IMA(:,:,1)); pause(1)

im={};
for nn = 1:size(IMA,3)
    fprintf('Stack: % .0f \n',nn)
    ph1.CData = IMA(:,:,nn);

    pause(.5)
    frame = getframe(1);
    im{nn} = frame2im(frame);
    pause(.5)
end

% clearvars -except datapaths datafiles DATA IM AlignVals IMGG IMGA IMA im



%% SAVE STACK PREVIEW AS ANIMATED GIF

filename = 'testAnimated.gif'; % Specify the output file name
for idx = 1:size(im,2)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',1);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',1);
    end
end


clearvars -except datapaths datafiles DATA IM AlignVals IMGG IMGA IMA im





%% DISPLAY IMAGE GRADIENTS IN XYZ DIRECTIONS

I = mat2gray(reshape(IM,40,40,1,[]));

[Gx, Gy, Gz] = imgradientxyz(IM);

close all
fh1=figure('Units','normalized','OuterPosition',[.05 .06 .9 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none'); %hold on;

montage(reshape(Gx,size(IM,1),size(IM,2),1,size(IM,3)),...
        'Parent',hax1, 'Size', [NaN 5], 'DisplayRange',[])

fh2=figure('Units','normalized','OuterPosition',[.05 .06 .9 .9],'Color','w','MenuBar','none');
hax2 = axes('Position',[.05 .05 .9 .9],'Color','none'); %hold on;

montage(reshape(Gy,size(IM,1),size(IM,2),1,size(IM,3)),...
        'Parent',hax2, 'Size', [NaN 5], 'DisplayRange',[])

fh3=figure('Units','normalized','OuterPosition',[.05 .06 .9 .9],'Color','w','MenuBar','none');
hax3 = axes('Position',[.05 .05 .9 .9],'Color','none'); %hold on;

montage(reshape(Gz,size(IM,1),size(IM,2),1,size(IM,3)),...
        'Parent',hax3, 'Size', [NaN 5], 'DisplayRange',[])


%%
% close all
% fh1=figure('Units','normalized','OuterPosition',[.05 .1 .9 .6],'Color','w','MenuBar','none');
% hax1 = axes('Position',[.05 .05 .45 .9],'Color','none'); %hold on;
% hax2 = axes('Position',[.52 .05 .45 .9],'Color','none'); %hold on;
% 
% axes(hax1)
% ih1 = imagesc(I(:,:,1));
% 
% axes(hax2)
% ih2 = imagesc(I(:,:,3));
% 
% CL1 = hax1.CLim
% CL2 = hax2.CLim
% 
% hax1.CLim = [min([CL1 CL2])     max([CL1 CL2])  ]
% hax2.CLim = [min([CL1 CL2])     max([CL1 CL2])  ]

%}

