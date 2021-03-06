function [centroids] = image_processing(frame,intensity_thres,currAxes)
%image_processing Summary of this function goes here
%   Detailed explanation goes here
    
    figure(1)
    image(frame, 'Parent', currAxes);hold on
    currAxes.Visible = 'on';
    r = frame(:, :, 1);
    g = frame(:, :, 2);
    b = frame(:, :, 3);
    justRed = r - g/2 - b/2;
    bw = justRed > intensity_thres;
    se = strel('disk',7);
    bw = imopen(bw,se);  
    
%     axes('pos',[.6 .6 .5 .3])
%     imshow(bw);hold on;
    measurements = regionprops(bw, 'centroid');
    centroids = cat(1, measurements.Centroid);
    centroids = centroids';
end

