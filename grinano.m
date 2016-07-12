function [] = grinano(scase, varargin)


%% -- DEAL ARGS
% keyboard
%%

sv = length(varargin);

    if sv == 1

        var1 = varargin;

    elseif sv == 2

        [var1 var2] = deal(varargin{:});
        
    elseif sv == 3

        [var1 var2 var3] = deal(varargin{:});

    elseif sv == 4

        [var1 var2 var3 var4] = deal(varargin{:});

    elseif sv == 5

        [var1 var2 var3 var4 var5] = deal(varargin{:});

    end


%%



switch scase
    
    case 'import' 
        
        fprintf('\n importing tif stack from...\n % s \n', var1{1});
        
        
    case 'trim'
        
        st1 = {'rows(y)';'cols(x)';'frames'};
        sp1 = sprintf('\n  % 34.10s % s % s  \n', st1{1:3});
        sp2 = sprintf('\n Imported image was size: %6.0f %8.0f %8.0f  \n', [size(var1) size(var2,3)]);
        sp3 = sprintf('\n Trimmed image is size: %8.0f %8.0f %8.0f  \n', size(var2));
        disp([sp1 sp2 sp3])
        
        
    case 'importxls' 
        
        fprintf('\n importing xls info from...\n % s \n', var1{1});
        
    case 'xlsparams'
        
        fprintf('\n\n In this dataset there are...')
        fprintf('\n    total trials: %10.1f  ', var1)
        fprintf('\n    frames per trial: %7.1f  ', var2)
        fprintf('\n    seconds per frame: %8.5f  ', var3)
        fprintf('\n    frames per second: %8.5f  ', var4)
        fprintf('\n    seconds per trial: %8.4f  \n\n', var5)        
        
    otherwise
        warning('Unexpected annotation call.')
end


















end