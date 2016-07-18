function varargout = CSUSplot(varargin)



%% -- DEAL ARGS

    if nargin < 1

        count = load('count.dat');
        tablesize = size(count);
        colnames = {'CSxUS', 'CS', 'US'};
        xticlab = {'12 AM','5 AM','10 AM','3 PM','8 PM'};

    elseif nargin == 1
        v1 = varargin{1};
        
        count = v1;
        tablesize = size(count);
        colnames = {'CSxUS', 'CS', 'US'};

    elseif nargin == 2
        [v1, v2] = deal(varargin{:});

        count = v1;
        tablesize = size(count);
        colnames = v2.csus;

    elseif nargin == 3
        [v1, v2, v3] = deal(varargin{:});

        count     = v1;
        tablesize = size(count);
        colnames  = v2.csus;
        futura    = v3;

    else
        warning('Too many inputs')
    end







figure('Position', [10, 100, 1200, 600],...
       'Name', 'TablePlot',...  % Title figure
       'NumberTitle', 'off',... % Do not show figure number
       'MenuBar', 'none');      % Hide standard menu bar menus





% All column contain numeric data (integers, actually)
colfmt = {'numeric', 'numeric', 'numeric'};
% allow editing values (but this can be changed)
coledit = [true true true];
% Set columns all the same width (must be in pixels)
colwdt = {60 60 60};
% Create a uitable on the left side of the figure
htable = uitable('Units', 'normalized',...
                 'Position', [0.025 0.03 0.375 0.92],...
                 'Data',  count,... 
                 'ColumnName', colnames,...
                 'ColumnFormat', colfmt,...
                 'ColumnWidth', colwdt,...
                 'ColumnEditable', coledit,...
                 'ToolTipString',...
                 'Select cells to highlight them on the plot',...
                 'CellSelectionCallback', {@select_callback});

% Create an axes on the right side; set x and y limits to the
% table value extremes, and format labels for the demo data.
haxes = axes('Units', 'normalized',...
             'Position', [.465 .065 .50 .85],...
             'XLim', [0 tablesize(1)],...
             'YLim', [0 max(max(count))],...
             'XLimMode', 'manual',...
             'YLimMode', 'manual');
         
title(haxes, 'GRIN data explorer')   % Describe data set
% Prevent axes from clearing when new lines or markers are plotted
hold(haxes, 'all')

% Create an invisible marker plot of the data and save handles
% to the lineseries objects; use this to simulate data brushing.
hmkrs = plot(count, 'LineStyle', 'none',...
                    'Marker', 'o',...
                    'MarkerSize',12,...
                    'MarkerFaceColor', 'g',...
                    'HandleVisibility', 'off',...
                    'Visible', 'off');

% Create an advisory message (prompt) in the plot area;
% it will vanish once anything is plotted in the axes.
axpos = haxes.Position;
ptpos = axpos(1) + .1*axpos(3);
ptpos(2) = axpos(2) + axpos(4)/2;
ptpos(3) = .4; ptpos(4) = .035;
hprompt = uicontrol('Style', 'text',...
                    'Units', 'normalized',...
                    'Position', ptpos,... % [.45 .95 .3 .035],...
                    'String',...
                      'Use Plot check boxes to graph columns',...
                    'FontWeight', 'bold',...
                    'ForegroundColor', [1 .8 .8],...
                    'BackgroundColor', 'w');

% Create three check boxes to toggle plots for columns
uicontrol('Style', 'checkbox',...
          'Units', 'normalized',...
          'Position', [.10 .96 .09 .035],...
          'TooltipString', 'Check to plot column 1',...
          'String', 'Col 1',...
          'Value', 1,...
          'Callback', {@plot_callback,1});
uicontrol('Style', 'checkbox',...
          'Units', 'normalized',...
          'Position', [.20 .96 .09 .035],...
          'TooltipString', 'Check to plot column 2',...
          'String', 'Col 2',...
          'Value', 0,...
          'Callback', {@plot_callback,2});
uicontrol('Style', 'checkbox',...
          'Units', 'normalized',...
          'Position', [.30 .96 .09 .035],...
          'TooltipString', 'Check to plot column 3',...
          'String', 'Col 3',...
          'Value', 0,...
          'Callback', {@plot_callback,3});

% Create a text label to say what the checkboxes do
uicontrol('Style', 'text',...
          'Units', 'normalized',...
          'Position', [.025 .955 .06 .035],...
          'String', 'Plot',...
          'FontWeight', 'bold');
      
      
% Create initial plot of column-1 data
% ------------------------------------------
    colors = {'b','m','r'}; % Use consistent color for lines
    colnames = htable.ColumnName;
    colname = colnames{1};
    ydata = htable.Data;
    haxes.NextPlot = 'Add';
    % Draw the line plot for column
    plot(haxes, ydata(:,1),...
    'DisplayName', colname,...
    'Color', colors{1});
               
% Subfuntions implementing the two callbacks
% ------------------------------------------

    function plot_callback(hObject, eventdata, column)
    % hObject     Handle to Plot menu
    % eventdata   Not used
    % column      Number of column to plot or clear

    colors = {'b','m','r'}; % Use consistent color for lines
    colnames = htable.ColumnName;
    colname = colnames{column};

    if (hObject.Value)
        % Turn off the advisory text; it never comes back
        hprompt.Visible = 'off';
        % Obtain the data for that column
        ydata = htable.Data;
        haxes.NextPlot = 'Add';
        % Draw the line plot for column
        plot(haxes, ydata(:,column),...
            'DisplayName', colname,...
            'Color', colors{column});
    else % Adding a line to the plot
        % Find the lineseries object and delete it
        delete(findobj(haxes, 'DisplayName', colname))
    end
    end


    function select_callback(hObject, eventdata)
    % hObject    Handle to uitable1 (see GCBO)
    % eventdata  Currently selected table indices
    % Callback to erase and replot markers, showing only those
    % corresponding to user-selected cells in table. 
    % Repeatedly called while user drags across cells of the uitable

        % hmkrs are handles to lines having markers only
        set(hmkrs, 'Visible', 'off') % turn them off to begin
        
        % Get the list of currently selected table cells
        sel = eventdata.Indices;     % Get selection indices (row, col)
                                     % Noncontiguous selections are ok
        selcols = unique(sel(:,2));  % Get all selected data col IDs
        table = hObject.Data; % Get copy of uitable data
        
        % Get vectors of x,y values for each column in the selection;
        for idx = 1:numel(selcols)
            col = selcols(idx);
            xvals = sel(:,1);
            xvals(sel(:,2) ~= col) = [];
            yvals = table(xvals, col)';
            % Create Z-vals = 1 in order to plot markers above lines
            zvals = col*ones(size(xvals));
            % Plot markers for xvals and yvals using a line object
            hmkrs(col).Visible = 'on';
            hmkrs(col).XData = xvals;
            hmkrs(col).YData = yvals;
            hmkrs(col).ZData = zvals;
            
        end
    end
 end