function [rescale_info] = rescale_variable(calculus, properties)
    if ~isempty(whos(calculus, 'events_info'))
        events_info_cell = calculus.events_info;
    else
        add_info_log('events_info not found');
        return
    end
    events_info = events_info_cell(1, 1);
    video_size = events_info.video_size;
    real_size = calculus.real_size;
    new_units = properties.new_units;
    old_units = {properties.x_unit, properties.y_unit};
    for i = 1:2
        rescale_info.new_units{i} = old_units{i}{1};
        rescale_info.new_coef(i) = 1;
        if ~isempty(old_units{i}{1})
            switch_units = old_units{i}{1}(2);
        else
            switch_units = '';
        end
        switch switch_units
            case 'p'
                switch new_units{i}
                    case {'m'}
                        rescale_info.new_coef(i) = (real_size(i + 1) / video_size(i)) / 1000000;
                        rescale_info.new_units{i} = '(m)';
                        
                    case {'cm'}
                        rescale_info.new_coef(i) = (real_size(i + 1) / video_size(i)) / 10000;
                        rescale_info.new_units{i} = '(cm)';
                        
                    case {'mm'}
                        rescale_info.new_coef(i) = (real_size(i + 1) / video_size(i)) / 1000;
                        rescale_info.new_units{i} = '(mm)';
                        
                    case {'mum'}
                        rescale_info.new_coef(i) = (real_size(i + 1) / video_size(i));
                        rescale_info.new_units{i} = '$(\mu m)$';
                        
                    case {'pixels', ''}
                        rescale_info.new_coef(i) = 1;
                        rescale_info.new_units{i} = '(pixels)';
                        
                end
                if ~isempty(strfind(old_units{i}{1}, '2'))
                    rescale_info.new_units{i} = ['$$', rescale_info.new_units{i}, '^2$$'];
                    rescale_info.new_coef(i) = rescale_info.new_coef(i)^2;
                end
                
            case 'f'
                switch new_units{i}
                    case {'s'}
                        rescale_info.new_coef(i) = 1 / real_size(1);
                        rescale_info.new_units{i} = '(s)';
                    case {'ms'}
                        rescale_info.new_coef(i) = 1 / real_size(1) * 1000;
                        rescale_info.new_units{i} = '(ms)';
                    case {'mus'}
                        rescale_info.new_coef(i) = 1 / real_size(1) * 1000000;
                        rescale_info.new_units{i} = '(mus)';
                    case {'frames', ''}
                        rescale_info.new_coef(i) = 1;
                        rescale_info.new_units{i} = '(frames)';
                end
            case 'a'
                switch new_units{i}
                    case {'bit'}
                        rescale_info.new_coef(i) = 1 / log(2);
                        rescale_info.new_units{i} = '(bit)';
                    case {'trit'}
                        rescale_info.new_coef(i) = 1 / log(3);
                        rescale_info.new_units{i} = '(trit)';
                    case {'dit'}
                        rescale_info.new_coef(i) = 1 / log(10);
                        rescale_info.new_units{i} = '(dit)';
                    case {'nat', ''}
                        rescale_info.new_coef(i) = 1;
                        rescale_info.new_units{i} = '(nat)';
                end
        end
    end
    rescale_info.new_units{3} = properties.colorbar_label;
    rescale_info.new_coef(3) = 1;
    if length(new_units) == 3
        switch new_units{3}
            case {'s'}
                rescale_info.new_coef(3) = 1 / real_size(1);
                rescale_info.new_units{3} = '(s)';
            case {'ms'}
                rescale_info.new_coef(3) = 1 / real_size(1) * 1000;
                rescale_info.new_units{3} = '(ms)';
            case {'mus'}
                rescale_info.new_coef(3) = 1 / real_size(1) * 1000000;
                rescale_info.new_units{3} = '(mus)';
            case {'frames', ''}
        end
    end
end
