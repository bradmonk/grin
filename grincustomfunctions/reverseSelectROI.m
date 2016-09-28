function [varargout] = reverseSelectROI(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK)
%% grincustomD.m

size(IMG)

XLSdata
GRINstruct
GRINtable


fhPH=figure('Units','normalized','OuterPosition',[.1 .1 .8 .6],'Color','w','MenuBar','none');
haxPmPs = axes('Position',[.05 .05 .45 .9],'Color','none'); hold on;
haxHist = axes('Position',[.52 .05 .45 .9],'Color','none'); hold on;


axes(haxPmPs)
phIM = imagesc(IMGraw);

for nn = 1:size(GRINstruct.tf,2)


PostCS{nn} = IMG(:,:,XLSdata.CSoffsetFrame:end,GRINstruct.tf(:,nn));

PreCS{nn} = IMG(:,:,1:XLSdata.CSonsetFrame,GRINstruct.tf(:,nn));



% PostCS_meanAcrossFrames = squeeze(mean(PostCS{nn},3));
% PreCS_meanAcrossFrames = squeeze(mean(PreCS{nn},3));

PostCS_meanAcrossTrials{nn} = squeeze(mean(PostCS{nn},4));
PreCS_meanAcrossTrials{nn} = squeeze(mean(PreCS{nn},4));



PostCS_mean{nn} = squeeze(mean(PostCS_meanAcrossTrials{nn},3));
PreCS_mean{nn} = squeeze(mean(PreCS_meanAcrossTrials{nn},3));


PostMinusPre{nn} = PostCS_mean{nn} - PreCS_mean{nn};

phIM.CData = PostMinusPre{nn};
pause(.1)


TSpmp{nn} = PostMinusPre{nn}(:);



TSz{nn} = zscore(TSpmp{nn});

Zcut = min(TSpmp{nn}(TSz{nn}>1.5));


TSpmpIMG{nn} = PostMinusPre{nn};

TSpmpIMG{nn}(TSpmpIMG{nn}<Zcut) = 0;

end

axes(haxHist)
histogram(TSpmp{nn})




pause(2)
close(fhPH);

% ------------------------------------------

fh1=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
hax1 = axes('Position',[.001 .001 .999 .999],'Color','none'); hold on;
hax2 = axes('Position',[.001 .001 .999 .999],'Color','none'); hold on;

axes(hax1)
ph1 = imagesc(IMGraw,'Parent',hax1,...
'CDataMapping','scaled');
axis image;  pause(.01)
axis normal; pause(1)


for mm = 1:size(IMGSraw,3)
for nn = 1:size(IMGSraw,4)    
    ph1.CData = IMGSraw(:,:,mm,nn);
    pause(.05)
end
end


IMGSrawMu = squeeze(mean(IMGSraw,4));
IMGSrawMu = squeeze(mean(IMGSrawMu,3));

ph1.CData = IMGSrawMu;

pause(1)


axes(hax2)

    xdim = size(TSpmpIMG{1},2); 
    ydim = size(TSpmpIMG{1},1);

    pause(.2)
    imXlim = hax1.XLim;
    imYlim = hax1.YLim;



    set(hax2, 'XLim', [1 xdim]);
    set(hax2, 'YLim', [1 ydim]);
    
    hold on;
    
    
    colorlist = [.99 .00 .00;
                 .00 .99 .00;
                 .99 .88 .88;
                 .11 .77 .77;
                 .77 .77 .11;
                 .77 .11 .77;
                 .00 .00 .99;
                 .22 .33 .44];
             
             
     legpos = {  [0.01,0.94,0.15,0.033], ...
        [0.01,0.90,0.15,0.033], ...
        [0.01,0.86,0.15,0.033], ...
        [0.01,0.82,0.15,0.033], ...
        [0.01,0.78,0.15,0.033], ...
        [0.01,0.74,0.15,0.033], ...
        };
    

    

for nn = 1:size(GRINstruct.tf,2)
    
    clear TooSmall

    BW = im2bw(TSpmpIMG{nn}, graythresh(TSpmpIMG{nn}));
    [B,L] = bwboundaries(BW,'noholes');
    
    
    for mm = 1:size(B,1)
    
        TooSmall(mm) = length(B{mm}) < 15;

    end
    
    
    B(TooSmall) = [];
    

    
    Bi{nn} = B;
    Li{nn} = L;
    
    % imshow(label2rgb(L, @jet, [.5 .5 .5]))
    % imagesc(label2rgb(L, @jet, [.5 .5 .5]))
    % hold on
    for k = 1:length(Bi{nn})
        boundary = Bi{nn}{k};
        plot(boundary(:,2), boundary(:,1), 'Color', colorlist(nn,:) , 'LineWidth', 2)
    end
    % axis image;  pause(.01)
    % axis normal; pause(.01)

    pause(2)

end


clear fid
for nn = 1:size(GRINstruct.tf,2)
    
    fid(nn) = find(GRINstruct.id==nn,1);
    
end


pt = GRINstruct.csus(fid);

for nn = 1:size(GRINstruct.tf,2)

annotation(fh1,'textbox',...
'Position',legpos{nn},...
'Color',colorlist(nn,:),...
'FontWeight','bold',...
'String',pt(nn),...
'FontSize',14,...
'FitBoxToText','on',...
'EdgeColor',colorlist(nn,:),...
'FaceAlpha',.7,...
'Margin',3,...
'LineWidth',2,...
'VerticalAlignment','bottom',...
'BackgroundColor',[1 1 1]);

end


%% ------------------------------------------

% ph2 = imagesc(TSpmpIMG,'Parent',hax2,...
% 'CDataMapping','scaled','AlphaData',0.2);
% axis image;  pause(.01)
% axis normal; pause(.01)
% 
%     ccmap = jet;
%     cmmap = [zeros(10,3); ccmap(end-40:end,:)];
%     colormap(hax2,cmmap)


varargout = {Bi};
end
%% EOF
