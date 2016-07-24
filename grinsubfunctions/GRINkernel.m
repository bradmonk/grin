function Mask = GRINkernel(varargin)
%% GRINkernel
% Mask = GRINkernel(2.5, 11, .18, .1)
% GRINkernel([HIGHT OF PEAK] [WIDTH MASK] [STDEV OF SLOPE] [RESOLUTION])

%         GNpk  = 2.5;	% HIGHT OF PEAK
%         GNnum = 11;   % SIZE OF MASK
%         GNsd = 0.18;	% STDEV OF SLOPE
%         GNres = 0.1;  % RESOLUTION
        
        

%% -- DEAL ARGS

    if nargin < 1
    
        GNpk  = 2.5;	% HIGHT OF PEAK
        GNnum = 11;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 1
        v1 = varargin{1};
        
        GNpk  = v1;     % HIGHT OF PEAK
        GNnum = 11;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 2
        [v1, v2] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 3
        [v1, v2, v3] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 4
        [v1, v2, v3, v4] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = v4;     % RESOLUTION
        doMASKfig = 0;
        
    elseif nargin == 5
        [v1, v2, v3, v4, v5] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = v4;     % RESOLUTION
        doMASKfig = v5;

    else
        warning('Too many inputs')
    end

%% -- MASK SETUP
GNx0 = 0;       % x-axis peak locations
GNy0 = 0;   	% y-axis peak locations
GNspr = ((GNnum-1)*GNres)/2;

a = .5/GNsd^2;
c = .5/GNsd^2;

[X, Y] = meshgrid((-GNspr):(GNres):(GNspr), (-GNspr):(GNres):(GNspr));
Z = GNpk*exp( - (a*(X-GNx0).^2 + c*(Y-GNy0).^2)) ;

Mask=Z;

disp('SMOOTHING KERNEL PARAMETERS:')
fprintf('  SIZE OF MASK:   % s x % s \n', num2str(GNnum), num2str(GNnum));
fprintf('  STDEV OF SLOPE: % s \n', num2str(GNsd));
fprintf('  HIGHT OF PEAK:  % s \n', num2str(GNpk));
fprintf('  RESOLUTION:     % s \n\n', num2str(GNres));


if doMASKfig == 1
    % disp(Mask);
    
    fh96=figure('Units','normalized','OuterPosition',[.05 .05 .6 .8],'Color','w');
    hax97 = axes('Position',[.05 .55 .33 .40],'Color','none');
    hax98 = axes('Position',[.04 .08 .32 .42],'Color','none');
    hax99 = axes('Position',[.45 .05 .50 .90],'Color','none');
    
        %----------------%
        axes(hax97)
    ph5 = imagesc(Mask); 
    colorbar
        axis equal;
        
        axes(hax98)
    ph6 = surf(X,Y,Z);
        axis equal; shading interp; view(90,90); 
        
        axes(hax99)
    ph7 = surf(X,Y,Z);
        axis vis3d; shading interp;
        view(-45,30); 
        xlabel('x-axis');ylabel('y-axis');zlabel('z-axis')
    %-------------------------------%
    
    
    
    
%     % axis off; hold on;
%     %----------------%
%         subplot('Position',[.05 .55 .30 .40]); 
%     ph5 = imagesc(Mask); 
%         axis equal;
%         %set(gca,'XTick',[],'YTick',[])
%         subplot('Position',[.04 .08 .32 .42]); 
%     ph6 = surf(X,Y,Z);
%         axis equal; shading interp; view(90,90); 
%         subplot('Position',[.45 .05 .50 .90]); 
%     ph7 = surf(X,Y,Z);
%         axis vis3d; shading interp;
%         view(-45,30); 
%         xlabel('x-axis');ylabel('y-axis');zlabel('z-axis')
%     %-------------------------------%
end
%{
MSK = {[2.5000]    [0]    [0]    [0.1800]    [11]    [0.1000]};

%--------------------
GNpk  = MSK{1};	% hight of peak
GNx0 = MSK{2};	% x-axis peak locations
GNy0 = MSK{3};	% y-axis peak locations
GNsd = MSK{4};	% sigma (stdev of slope)

GNnum = MSK{5};
GNres = MSK{6};
GNspr = ((GNnum-1)*GNres)/2;

%--------------------
hkMask=Z;
% hk = convn(S,hkMask,'same');
% hkor = hk(PSAsz+1,PSAsz+1);
%-----
%LBR(1) = hkor-sqrt(GNpk); LBR(2) = hkor+sqrt(GNpk);
%--------------------


Mx1 = [1, 2, 3; 4, 5, 6; 7, 8, 9];
Kernel = ones(2);

Mx2 = convn(Mx1,Kernel,'same');
Mx2(end,:) = []; Mx2(:,end) = [];
disp(Mx2)

%}

end















