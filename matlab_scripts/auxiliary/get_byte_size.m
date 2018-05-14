function [mem] = get_byte_size(bytes, return_type, fid)
    % get_byte_size returns the mem.usage of the provided variable(theVariable) to the given file
    % identifier.
    % return_type is assigned meaningfully according to the byte size if not stated
    % Output is written to screen if fid is 1, empty or not provided.
    if nargin == 1 || isempty(return_type)
        scale = floor(log(bytes) / log(1024));
        switch scale
            case 0
                return_type = 'byte';
            case 1
                return_type = 'KB';
            case 2
                return_type = 'MB';
            case 3
                return_type = 'GB';
            case 4
                return_type = 'TB';
            case -inf
                % Size occasionally returned as zero (eg some Java objects).
                return_type = 'byte';
                %warning('Size occasionally returned as zero (eg some Java objects). Bytes assumed');
            otherwise
                return_type = 'petabytes';
                warning('Over 1024 petabyte. petabytes assumed');
        end
    end
    switch lower(return_type)
        case {'b', 'byte', 'bytes'}
            bytes = bytes;
        case {'kb', 'kbs', 'kilobyte', 'kilobytes'}
            bytes = bytes / 1024;
        case {'mb', 'mbs', 'megabyte', 'megabytes'}
            bytes = bytes / 1024^2;
        case {'gb', 'gbs', 'gigabyte', 'gigabytes'}
            bytes = bytes / 1024^3;
        case {'tb', 'tbs', 'terabyte', 'terabytes'}
            bytes = bytes / 1024^4;
        case {'pb', 'pbs', 'petabyte', 'petabytes'}
            bytes = bytes / 1024^5;
        otherwise
            return_type = 'bytes';
    end
    mem = bytes;
    if (nargin <= 2 || isempty(fid) || fid == 1) && nargout < 1
        fprintf(1, [num2str(bytes), ' ', return_type, '\n']);
    elseif nargin > 2 && ~isempty(fid) && fid > 2
        try
            fprintf(fid, [num2str(bytes), ' ', return_type, '\n']);
        catch
            warning(['fid(', num2str(fid), ') could not be edited. Hence the output will be written on the screen.']);
            fprintf(1, [num2str(bytes), ' ', return_type, '\n']);
        end
    else
        mem = [num2str(bytes), ' ', return_type];
    end
end