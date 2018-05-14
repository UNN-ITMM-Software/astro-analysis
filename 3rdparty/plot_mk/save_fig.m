function [] = save_fig(fig_p, file_name, paper_position, save_type, need_copy)
    if nargin < 3 || isempty(paper_position)
        paper_position = [0 0 10 6];
    end
    if nargin < 4 || isempty(save_type)
        save_type = 'png';
    end
    if nargin < 5 || isempty(need_copy)
        need_copy = true;
    end
    if need_copy
        fig = figure('Visible', 'Off');
        ch = allchild(fig_p);
        all_ch = [];
        for i = 1:length(ch)
            if ~isa(ch(i), 'matlab.ui.container.Menu') && ...
               ~isa(ch(i), 'matlab.ui.container.Toolbar')
                all_ch(end + 1) = ch(i);
            end
        end
        copyobj (all_ch, fig);
        p = properties(fig);
        for i = 1:length(p)
            if strcmp(p{i}, 'CurrentAxes')
                continue;
            end
            if strcmp(p{i}, 'CurrentCharacter')
                continue;
            end
            if strcmp(p{i}, 'Children')
                continue;
            end
            if strcmp(p{i}, 'CloseRequestFcn')
                continue;
            end
            prop = findprop(fig, p{i});
            if ~strcmp(prop.SetAccess, 'public')
                continue;
            end
            fig.(p{i}) = fig_p.(p{i});
        end
    else
        fig = fig_p;
    end
    
    fig.PaperUnits = 'inches';
    fig.PaperPositionMode = 'manual';
    fig.PaperPosition = paper_position;
    fig.Units = 'inches';
    
    hAllAxes = findobj(fig, 'type', 'axes');
%     for i = 1:length(hAllAxes)
%         ax = hAllAxes(i);
%         ax.Units = 'inches';
%         outerpos = ax.OuterPosition;
%         ti = ax.TightInset; 
%         left = outerpos(1) + ti(1);
%         bottom = outerpos(2);% + ti(2);
%         ax_width = outerpos(3) - ti(1) - ti(3);
%         ax_height = outerpos(4);% - ti(2) - ti(4);
%         pos = ax.Position;
%         ax.Units = 'normalized';
%         ax.Position = [left pos(2) ax_width pos(4)];
%         ax.OuterPosition = outerpos;
%         
%         [left pos(2) ax_width pos(4)]
%         ax.Position
%         ax.OuterPosition
%         %[left bottom ax_width ax_height]
%     end
    set(hAllAxes, ...
        'XTickMode', 'manual', ...
        'YTickMode', 'manual', ...
        'ZTickMode', 'manual', ...
        'XLimMode', 'manual', ...
        'YLimMode', 'manual', ...
        'ZLimMode', 'manual');
    
    switch save_type
        case 'png'
            print(fig, sprintf ('%s', file_name), '-dpng');
        case 'bmp'
            print(fig, sprintf ('%s', file_name), '-dbmp');
        case 'eps'
            print(fig, sprintf ('%s', file_name), '-depsc');
        otherwise
            print(fig, sprintf ('%s', file_name), save_type);
    end
    if need_copy
        close(fig);
    end
end