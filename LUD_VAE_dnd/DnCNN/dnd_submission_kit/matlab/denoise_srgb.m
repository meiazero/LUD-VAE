% Utility function for denoising all bounding boxes in all sRGB images of
% the DND dataset.
%
% denoiser      Function handle
%               It is called as Idenoised = denoiser(Inoisy, nlf) where Inoisy is the noisy image patch 
%               and nlf is a struct containing the  mean noise strength (nlf.sigma)
% data_folder   Folder where the DND dataset resides
% out_folder    Folder where denoised output should be written to
%
% You can parallelize by having a parfor over the bounding boxes.
%
% Author: Tobias Plötz, TU Darmstadt (tobias.ploetz@visinf.tu-darmstadt.de)
%
% This file is part of the implementation as described in the CVPR 2017 paper:
% Tobias Plötz and Stefan Roth, Benchmarking Denoising Algorithms with Real Photographs.
% Please see the file LICENSE.txt for the license governing this code.

function denoise_srgb( denoiser, data_folder, output_folder )

infos = load(fullfile(data_folder, 'info.mat'));
info = infos.info;

% iterate over images
for i=1:50
    img = load(fullfile(data_folder, 'images_srgb', sprintf('%04d.mat', i)));
    Inoisy = img.InoisySRGB;
    
    % iterate over bounding boxes
    Idenoised_crop_bbs = cell(1,20);
    parfor b=1:20
        bb = info(i).boundingboxes(b,:);
        Inoisy_crop = Inoisy(bb(1):bb(3), bb(2):bb(4), :);
        nlf = info(i).nlf;
        
        nlf.sigma = info(i).sigma_srgb(b);
        Idenoised_crop = denoiser(Inoisy_crop, nlf);

        
        Idenoised_crop_bbs{b} = single(Idenoised_crop);
    end
    for b=1:20
        Idenoised_crop = Idenoised_crop_bbs{b};
        save(fullfile(output_folder, sprintf('%04d_%02d.mat', i, b)), 'Idenoised_crop');
    end
    fprintf('Image %d/%d done\n', i,50);
end

end

