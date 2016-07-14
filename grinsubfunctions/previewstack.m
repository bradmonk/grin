function [] = previewstack(IMGS)


fh1=figure('Units','normalized','OuterPosition',[.05 .05 .6 .7],'Color','w');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);

imagesc(IMGS(:,:,1))
colormap(jet)

mx = max(max(IMGS(:,:,1)));
mn = min(min(IMGS(:,:,1)));

for nT = 1:length(IMGS)
  
    muuIMG = muIMG(:,:,nT);

    imagesc(muuIMG)
    
    pause(.05)
end
%----------------------


end