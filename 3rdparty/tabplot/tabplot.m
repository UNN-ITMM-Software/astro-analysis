% TABPLOT Add multiple plots to a single figure separated by tabs
%
% Author:
%       Joseph Kirk
%       jdkirk630@gmail.com
%
% Date: 08/16/16
%
% Description: Uses tabs to display multiple plots in a single figure.
%
% Inputs:
%     tabName   - (optional) string specifying the name to use for the tab
%     hFig      - (optional) handle to the desired figure (default = gcf)
%     tabLoc    - (optional) string specifying the location of the tabs
%                    must be one of {'top','bottom','left','right'}
%     tabColor  - (optional) value specifying the background color of the tab
%
% Outputs:
%     hAx       - (optional) handle of the axes created for the new tab
%     hTab      - (optional) handle of the new tab
%     hTabGroup - (optional) handle of the entire tab group
%
% Usage:
%     tabplot
%       -or-
%     tabplot('Tab Name')
%       -or-
%     tabplot('Tab Name',hFig)
%       -or-
%     tabplot('Tab Name',hFig,tabLoc)
%       -or-
%     tabplot('Tab Name',hFig,tabColor)
%       -or-
%     hAx = tabplot( ... )
%       -or-
%     [hAx,hTab] = tabplot( ... )
%       -or-
%     [hAx,hTab,hTabGroup] = tabplot( ... )
%
% Example:
%     % Open a new figure and create 2 tabs with plots
%     figure;
%     tabplot;
%     imagesc(peaks);
%     tabplot;
%     mesh(peaks);
%
% Example:
%     % Open a new figure and create 2 *named* tabs with plots
%     hFig = figure;
%     tabplot('Peaks Image',hFig);
%     imagesc(peaks);
%     tabplot('Peaks Mesh',hFig);
%     mesh(peaks);
%
% Example:
%     % Open a new figure and create 2 tabs that appear on the top
%     hFig = figure;
%     tabplot('Peaks Image',hFig,'top');
%     imagesc(peaks);
%     tabplot('Peaks Mesh',hFig);
%     mesh(peaks);
%
% Example:
%     % Test case where figure already has graphics (generates prompt)
%     figure;
%     mesh(peaks);
%     tabplot;
%     imagesc(peaks);
%
% Example:
%     % Delete tabgroup from figure
%     figure;
%     tabplot;
%     imagesc(peaks);
%     title('Tab group will be deleted in 3 seconds')
%     pause(3)
%     [~,~,hTabGroup] = tabplot;
%     delete(hTabGroup)
%
% See also: uitabgroup, uitab
%
function varargout = tabplot(tabName,hFig,tabLoc,tabColor)
    
    
    % Use current figure handle if none provided
    if (nargin < 2) || isempty(hFig)
        hFig = gcf;
    end
    
    % Identify any figure children
    hChild = get(hFig,'Children');
    
    % See if the figure already has tabs
    hasTabGroup = false;
    if ~isempty(hChild)
        childTags = get(hChild,'Tag');
        isTabGroup = strcmp(childTags,'tabplot:uitabgroup');
        if any(isTabGroup)
            hasTabGroup = true;
        else
            useNewFig = generate_alert();
            if useNewFig
                hFig = figure;
            end
        end
    end
    
    % Get the handle to the tab group
    if hasTabGroup
        hTabGroup = hChild(isTabGroup);
    else
        hTabGroup = uitabgroup('Parent',hFig, ...
            'Tag','tabplot:uitabgroup', ...
            'TabLocation','left');
    end
    
    % Set the location of the tab group if specified
    if (nargin >= 3) && ~isempty(tabLoc)
        if any(strcmpi(tabLoc,{'top','bottom','left','right'}))
            set(hTabGroup,'TabLocation',tabLoc);
        end
    end
    
    % Find any existing tabs
    tabList = get(hTabGroup,'Children');
    nTabs = length(tabList);
    
    % Give the tab a generic name if none is specified
    if (nargin < 1) || isempty(tabName)
        tabName = sprintf('%d',nTabs+1);
    end
    
    % Create the new tab and bring it to the front
    hTab = uitab('Parent',hTabGroup,'Title',tabName);
    set(hTabGroup,'SelectedTab',hTab);
    
    % Set the color of the tab if specified
    if (nargin >= 4) && ~isempty(tabColor)
        set(hTab,'BackgroundColor',tabColor);
    end
    
    % Create a handle for the tab axis content
%     hAx = axes('Parent',hTab);
    
    % Create a button to close the tab
%     uicontrol( ...
%         'Parent',hTab, ...
%         'Style','togglebutton', ...
%         'String','X', ...
%         'Units','normalized', ...
%         'Position',[0.97 0.97 0.03 0.03], ...
%         'Callback',{@close_tab,hTab});
        
    % Pass the output handles if requested
    if nargout
        varargout = {hTab,hTabGroup};
    end
    
end

% Subfunction to close a tab
function close_tab(varargin)
    delete(varargin{3});
end

% Subfunction to prompt user when selected figure already has graphics
function useNewFig = generate_alert()
    txt = 'Figure already contains graphics. A new tab will cover it up. Continue?';
    answer = questdlg(txt,'TABPLOT | Warning', ...
        'Use Current Figure','Create New Figure','Create New Figure');
    useNewFig = true;
    switch answer
        case 'Use Current Figure'
            useNewFig = false;
        otherwise
    end
end
