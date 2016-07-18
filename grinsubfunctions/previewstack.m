function [] = previewstack(IM, varargin)


if nargin > 1
    %%
    close all
    fh1=figure('Units','normalized','OuterPosition',[.05 .05 .9 .7],'Color','w');
    hax1 = axes('Position',[.05 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);
    hax2 = axes('Position',[.53 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);
    hax3 = axes('Position',[.53 .05 .45 .9],'Color','none','XTick',[],'YTick',[]);
    
    [onoff, fY] = deal(varargin{:});
    
    sz = size(IM);
    
    timeline = 1:sz(end);
    
    % plot(hax2, timeline, ones(size(timeline)));
    plot(hax2, 1:numel(fY), fY);
    hold on;
    plot(hax3, 1:numel(fY), fY);
    hold on;
    
    text(onoff(1),0,'\downarrow','FontSize',50,'VerticalAlignment','bottom')
    text(onoff(1)-4,0,'CS on','FontSize',16,'HorizontalAlignment','center'...
        ,'VerticalAlignment','bottom')
    
    text(onoff(2),0,'\downarrow','FontSize',50,'VerticalAlignment','bottom')
    text(onoff(2)-4,0,'CS off','FontSize',16,'HorizontalAlignment','center'...
        ,'VerticalAlignment','bottom')
    
    sg = scatter(hax3, 1, fY(1), 100,'r','filled');
    
    
    axes(hax1)
    ih = imagesc(IM(:,:,1));
    colormap(parula)

    mx = max(max(IM(:,:,1))) * 1.2;
    mn = min(min(IM(:,:,1))) * 0.8;

    ndims = numel(size(IM));

    for nT = 1:size(IM,ndims)

        ih.CData = IM(:,:,nT);

        sg.XData = nT;
        sg.YData = fY(nT);

        pause(.2)
    end
    %%
    
else
    
    fh1=figure('Units','normalized','OuterPosition',[.05 .05 .6 .8],'Color','w');
    hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);
    
    axes(hax1)
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



end