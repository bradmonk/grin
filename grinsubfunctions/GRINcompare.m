function [] = GRINcompare(IMa, IMb, frames, varargin)

fh1=figure('Units','normalized','OuterPosition',[.1 .1 .8 .6],'Color','w');
hax1 = axes('Position',[.05 .05 .45 .9],'Color','none'); 
% axis off; hold on;
hax2 = axes('Position',[.52 .05 .45 .9],'Color','none');
% axis off; hold on;


if nargin == 4
    
    Cb1 = varargin{1};
    Cb2 = varargin{1};
    
elseif nargin == 5
    
    [v1, v2] = deal(varargin{:});

    Cb1 = v1;
    Cb2 = v2;
    
else
    
    Cb1 = [.98 1.05];
    Cb2 = [.98 1.05];
    
end


axes(hax1)
ih1 = imagesc(IMa(:,:,1));
title('BEFORE'); axis off; 
cb1 = colorbar;
cb1.Limits = cb1.Limits .* Cb1;
cb1.LimitsMode = 'manual';
hax1.CLim = cb1.Limits;
hax1.CLimMode =  'manual';
hold on;

axes(hax2)
ih2 = imagesc(IMb(:,:,1));
title('AFTER'); axis off; 
cb2 = colorbar;
cb2.Limits = cb2.Limits .* Cb2;
cb2.LimitsMode = 'manual';
hax2.CLim = cb2.Limits;
hax2.CLimMode =  'manual';
hold on;



% keyboard

if frames > 1;
for nn = 1:frames
    
    ih1.CData = IMa(:,:,nn);
    ih2.CData = IMb(:,:,nn);
    
    pause(.08)
end
end



end