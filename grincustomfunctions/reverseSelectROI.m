function [varargout] = reverseSelectROI(IMG, GRINstruct, GRINtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK)
%% grincustomD.m

size(IMG)

XLSdata
GRINstruct
GRINtable


% fhdF=figure('Units','normalized','OuterPosition',[.1 .1 .8 .6],'Color','w','MenuBar','none');
% haxPmPs = axes('Position',[.05 .05 .45 .9],'Color','none'); hold on;
% haxHist = axes('Position',[.52 .05 .45 .9],'Color','none'); hold on;
% axes(haxPmPs)
% phIM = imagesc(IMGraw);

clear fid
for nn = 1:size(GRINstruct.tf,2)
    fid(nn) = find(GRINstruct.id==nn,1); 
end
TreatmentGroup = GRINstruct.csus(fid);


Fcson   = XLSdata.CSonsetFrame
Fcsmid  = Fcson + round(XLSdata.CS_lengthFrames/2)
Fcsoff  = XLSdata.CSoffsetFrame;
Fusmid  = Fcsoff + round((XLSdata.framesPerTrial - Fcsoff)/2)
Fusend  = XLSdata.framesPerTrial



for nn = 1:size(GRINstruct.tf,2)

    
Baseline{nn} = IMG(:,:,1:Fcson,GRINstruct.tf(:,nn));    
Baseline_meanAcrossTrials{nn} = squeeze(mean(Baseline{nn},4));
Baseline_mean{nn} = squeeze(mean(Baseline_meanAcrossTrials{nn},3));

CS{nn} = IMG(:,:,Fcson:Fcsoff,GRINstruct.tf(:,nn));
CS_meanAcrossTrials{nn} = squeeze(mean(CS{nn},4));
CS_mean{nn} = squeeze(mean(CS_meanAcrossTrials{nn},3));

US{nn} = IMG(:,:,Fcsoff:end,GRINstruct.tf(:,nn));
US_meanAcrossTrials{nn} = squeeze(mean(US{nn},4));
US_mean{nn} = squeeze(mean(US_meanAcrossTrials{nn},3));



CSFHh{nn} = IMG(:,:,Fcson:Fcsmid,GRINstruct.tf(:,nn));
CSFH_meanAcrossTrials{nn} = squeeze(mean(CSFHh{nn},4));
CSFH{nn} = squeeze(mean(CSFH_meanAcrossTrials{nn},3));

CSLHh{nn} = IMG(:,:,Fcsmid:Fcsoff,GRINstruct.tf(:,nn));
CSLH_meanAcrossTrials{nn} = squeeze(mean(CSLHh{nn},4));
CSLH{nn} = squeeze(mean(CSLH_meanAcrossTrials{nn},3));

USFHh{nn} = IMG(:,:,Fcsoff:Fusmid,GRINstruct.tf(:,nn));
USFH_meanAcrossTrials{nn} = squeeze(mean(USFHh{nn},4));
USFH{nn} = squeeze(mean(USFH_meanAcrossTrials{nn},3));

USLHh{nn} = IMG(:,:,Fusmid:Fusend,GRINstruct.tf(:,nn));
USLH_meanAcrossTrials{nn} = squeeze(mean(USLHh{nn},4));
USLH{nn} = squeeze(mean(USLH_meanAcrossTrials{nn},3));




USMinusBaseline{nn} = US_mean{nn} - Baseline_mean{nn};


CSFHMinusBaseline{nn} = CSFH{nn} - Baseline_mean{nn};
CSLHMinusBaseline{nn} = CSLH{nn} - Baseline_mean{nn};
USFHMinusBaseline{nn} = USFH{nn} - Baseline_mean{nn};
USLHMinusBaseline{nn} = USLH{nn} - Baseline_mean{nn};



UmB{nn} = USMinusBaseline{nn}(:);
UmB_Zscore{nn} = zscore(UmB{nn});
UmB_Zcut = min(UmB{nn}(UmB_Zscore{nn}>1.5));
UmBz{nn} = USMinusBaseline{nn};
UmBz{nn}(UmBz{nn}<UmB_Zcut) = 0;



CSFHmB{nn} = CSFHMinusBaseline{nn}(:);
CSFHmB_Zscore{nn} = zscore(CSFHmB{nn});
CSFHmB_Zcut = min(CSFHmB{nn}(CSFHmB_Zscore{nn}>1.5));
CSFHmBz{nn} = CSFHMinusBaseline{nn};
CSFHmBz{nn}(CSFHmBz{nn}<CSFHmB_Zcut) = 0;



CSLHmB{nn} = CSLHMinusBaseline{nn}(:);
CSLHmB_Zscore{nn} = zscore(CSLHmB{nn});
CSLHmB_Zcut = min(CSLHmB{nn}(CSLHmB_Zscore{nn}>1.5));
CSLHmBz{nn} = CSLHMinusBaseline{nn};
CSLHmBz{nn}(CSLHmBz{nn}<CSLHmB_Zcut) = 0;



USFHmB{nn} = USFHMinusBaseline{nn}(:);
USFHmB_Zscore{nn} = zscore(USFHmB{nn});
USFHmB_Zcut = min(USFHmB{nn}(USFHmB_Zscore{nn}>1.5));
USFHmBz{nn} = USFHMinusBaseline{nn};
USFHmBz{nn}(USFHmBz{nn}<USFHmB_Zcut) = 0;



USLHmB{nn} = USLHMinusBaseline{nn}(:);
USLHmB_Zscore{nn} = zscore(USLHmB{nn});
USLHmB_Zcut = min(USLHmB{nn}(USLHmB_Zscore{nn}>1.5));
USLHmBz{nn} = USLHMinusBaseline{nn};
USLHmBz{nn}(USLHmBz{nn}<USLHmB_Zcut) = 0;


end


%% ------------------------------------------------------------
clc; close all;


for nn = 1:size(GRINstruct.tf,2)

figure('Units','normalized','OuterPosition',[.02 .06 .88 .88],'Color','w','MenuBar','none');
hax1 = axes('OuterPosition',[.00 .50 .33 .50],'Color','none'); axis off; hold on;
hax2 = axes('OuterPosition',[.33 .50 .33 .50],'Color','none'); axis off; hold on;
hax3 = axes('OuterPosition',[.66 .50 .33 .50],'Color','none'); axis off; hold on;
hax4 = axes('OuterPosition',[.00 .00 .33 .50],'Color','none'); axis off; hold on;
hax5 = axes('OuterPosition',[.33 .00 .33 .50],'Color','none'); axis off; hold on;
hax6 = axes('OuterPosition',[.66 .00 .33 .50],'Color','none'); axis off; hold on;


ph1 = imagesc(IMGraw, 'Parent', hax1);
ph2 = imagesc(UmBz{nn}, 'Parent', hax2);
ph3 = imagesc(CSFHmBz{nn}, 'Parent', hax3);
ph4 = imagesc(CSLHmBz{nn}, 'Parent', hax4);
ph5 = imagesc(USFHmBz{nn}, 'Parent', hax5);
ph6 = imagesc(USLHmBz{nn}, 'Parent', hax6);



axes(hax1); title('Raw Pixels');
axes(hax2); title('US full - Baseline (dF/F)');
axes(hax3); title('CS 1st half - Baseline (dF/F)');
axes(hax4); title('CS 2st half - Baseline (dF/F)');
axes(hax5); title('US 1st half - Baseline (dF/F)');
axes(hax6); title('US 2st half - Baseline (dF/F)');

       
annotation('textbox',...
'Position',[0.005,0.95,0.1,0.03],...
'FontWeight','bold',...
'String',TreatmentGroup(nn),...
'FontSize',13,...
'FitBoxToText','on',...
'LineStyle','none');

end







% ph1.CData = USMinusBaseline{nn}; pause(.1)
% axes(hax2); hold(hax2,'off');
% histogram(UmB{nn})

%% ------------------------------------------

figure('Units','normalized','OuterPosition',[.10 .10 .60 .80],'Color','w','MenuBar','none');
hax7 = axes('OuterPosition',[.00 .00 .99 .99],'Color','none'); axis off; hold on;

ph7 = imagesc(USMinusBaseline{1}, 'Parent', hax7);

for mm = 1:6
for nn = 1:size(GRINstruct.tf,2)
    
    ph7.CData = USMinusBaseline{nn};
    
    title(TreatmentGroup(nn));
    pause(1)

end
end



%% ------------------------------------------

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

    xdim = size(UmBz{1},2); 
    ydim = size(UmBz{1},1);

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

    BW = im2bw(UmBz{nn}, graythresh(UmBz{nn}));
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




for nn = 1:size(GRINstruct.tf,2)

annotation(fh1,'textbox',...
'Position',legpos{nn},...
'Color',colorlist(nn,:),...
'FontWeight','bold',...
'String',TreatmentGroup(nn),...
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
