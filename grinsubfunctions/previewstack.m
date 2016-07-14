function [] = previewstack(IM, varargin)

keyboard

if nargin > 1
    fh1=figure('Units','normalized','OuterPosition',[.05 .05 .9 .7],'Color','w');
    hax1 = axes('Position',[.05 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);
    hax2 = axes('Position',[.55 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);
    
    
    
    
    
else
    
    fh1=figure('Units','normalized','OuterPosition',[.05 .05 .6 .8],'Color','w');
    hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);
    
    
end





ih = imagesc(IM(:,:,1));
colormap(jet)

mx = max(max(IM(:,:,1))) * 1.2;
mn = min(min(IM(:,:,1))) * 0.8;

ndims = numel(size(IM));

for nT = 1:size(IM,ndims)

    ih.CData = IM(:,:,nT);
    
    pause(.05)
end



end