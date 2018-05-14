function image = image_channel_mask(image, channel_mask)
    if (size(image, 3) > 1)
        if sum(channel_mask) == 0
            image = zeros([size(image, 1), size(image, 2)], class(image));
        else
            image = sum(image(:, :, channel_mask), 3) / sum(channel_mask);
        end
    end
end