
XLSdata.CSUSvals



IMGROI(1,2).Groups([1,2])



IMGROI(1,2).ROIfacDat

fh1=figure('Units','normalized','OuterPosition',[.1 .1 .8 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .45 .9],'Color','none'); % axis off; hold on;
hax2 = axes('Position',[.52 .05 .45 .9],'Color','none'); % axis off; hold on;

axes(hax1)
for nn = 2:size(IMGROI,1)
    plot(hax1,IMGROI(1,nn).ROIfacDat)
    title(IMGROI(1,nn).Groups(nn) )
    disp(IMGROI(1,nn).Groups([1,nn]) )
    hold on
end

axes(hax2)
for nn = 2:size(IMGROI,1)
    plot(hax2,IMGROI(1,nn).ROIcofDat)
    title(IMGROI(1,nn).Groups(nn) )
    hold on
end

legend(IMGROI(1,2).Groups(2:end))
