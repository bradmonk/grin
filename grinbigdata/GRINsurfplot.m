

%% IMPORT TILE DATA

clear all

Files = ['TILE_gc33_2016_0323_g.mat';
         'TILE_gc33_2016_0323_g.mat';
         'TILE_gc33_2016_0323_g.mat';
         'TILE_gc33_2016_0323_g.mat';
         'TILE_gc33_2016_0323_g.mat']


Days = size(Files,1);


for nn = 1:Days

    T{nn} = load(Files(nn,:));

    TILE{nn} = T{nn}.TILE;

end


%% VISUALIZE ALL TILES FOR ALL DAYS
close all
for mm = 1:Days
for nn = 1:100

    plot(TILE{mm}{nn})
    ylim([-.15 .15])


    spf = sprintf('\n Day: %.0f  Tile: %.0f \n',mm,nn);
    title(spf)
    pause(.2)
end
end



%% VIEW SINGLE TILE DATA


day_tile = [ 1 , 56 ];

plot(TILE{day_tile(1)}{day_tile(2)})
ylim([-.15 .15])


%% SPECIFY WHICH TILES YOU WANT FROM EACH DAY

t = [17 26 32 17 26]; % 55

for nn = 1:Days

    D{nn} = TILE{nn}{t(nn)}

end


y = cell2mat(D);

sz = size(D{1});


y = reshape(y,sz(1),sz(2),[])


for nn = 1:sz(2)

    TrialType{nn} = squeeze(y(:,nn,:));

end




%% SHITTY LINE PLOT

close all
plot(TrialType{1})
legend(    cellstr(    num2str(  (1:Days)'   )    )    )



%% SURFACE PLOT SMOOTHED
% cftool

ESALEQ = TrialType{2};

close all
fh31 = figure('Units','normalized','OuterPosition',[.1 .05 .85 .92],'Color','w');
ax31 = axes('Position',[.1 .40 .83 .55],'Color','none');
ax32 = axes('Position',[.1 .05 .83 .26],'Color','none');

[xData, yData, zData] = prepareSurfaceData(1:size(ESALEQ,1), 1:size(ESALEQ,2), ESALEQ);
ft = 'biharmonicinterp';
[fitresult, gof] = fit( [xData, yData], zData, ft, 'Normalize', 'on' );

axes(ax31)
h = plot( fitresult, [xData, yData], zData );
legend( h, 'fit', 'Neural Activity', 'Location', 'NorthEast' );
xlabel('SECONDS'); ylabel('DAY'); zlabel('NEURAL ACTIVITY')
grid on
view(-15,20)
L1 = light('Position',[1 .3 .8],'Style','local');
L2 = light('Position',[1 .5 1],'Style','local');
lighting gouraud;


% Make contour plot.
axes(ax32)
h = plot( fitresult, [xData, yData], zData, 'Style', 'Contour' );
legend( h, 'fit', 'Neural Activity', 'Location', 'NorthEast' );
xlabel('SECONDS'); ylabel('DAY');
grid on