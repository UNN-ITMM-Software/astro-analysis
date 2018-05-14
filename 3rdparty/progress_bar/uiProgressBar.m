function h = uiProgressBar(varargin)
%uiProgressBar: A waitbar that can be embedded in a GUI figure.

    if ishandle(varargin{1}) && size(varargin, 2) > 1
        ax = varargin{1};
        value = varargin{2};
        h_text = findall(ax,'type','Text');
        h_patch = findall(ax,'type','Patch');
        
        x = get(h_patch,'XData');
        x(3:4) = value;
        set(h_patch,'XData',x)
        set(h_text, 'Interpreter', 'none', ...
            'String', sprintf('%d%%', int32(100 * value)));
        return
    end

    bg_color = 'w';
    fg_color = [133 180 243] / 255;
    %[71 204 100] / 255; %[91 191 223] / 255; %[48 140 252] / 255;
    h = axes('Units','Normalized',...
        'XLim',[0 1],'YLim',[0 1],...
        'XTick',[],'YTick',[],...
        'Color',bg_color,...
        'XColor',bg_color,'YColor',bg_color, ...
        'Parent', varargin{1}, ...
        'Position', [0 0 1 1], 'Visible', 'Off');
    patch(h, [0 0 0 0],[0 1 1 0],fg_color,...
        'EdgeColor','none');
    text(h, 0.5, 0.5, '50%', 'HorizontalAlignment', 'Center', ...
        'Interpreter', 'none');
end