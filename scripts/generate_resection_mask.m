function [mask,ROI] = resection_roi_affine(filepath)
% This function takes in the path to a single subject template, where
% images have been 
%
% Thomas Campbell Arnold
% tcarnold@seas.upenn.edu
% 5/22/2019

outpath = fullfile(filepath, 'resection_affine');

% read in segmentations
filename = fullfile(outpath,'pre2post_BrainSegmentationPosteriors1.nii.gz');
CSF_post = niftiread(filename);
filename = fullfile(outpath,'pre2post_BrainSegmentationPosteriors1.nii.gz');
CSF = niftiread(filename);
filename = fullfile(outpath,'pre2post_BrainSegmentationPosteriors2.nii.gz');
GM = niftiread(filename);
filename = fullfile(outpath,'pre2post_BrainSegmentationPosteriors3.nii.gz');
WM = niftiread(filename);

% smooth images and take differences
sigma = 2;
CSF_post = imgaussfilt3(CSF_post,sigma);
CSF = imgaussfilt3(CSF,sigma);
diff = CSF_post - CSF;

pre = (GM + WM) > 0.5; % great than 50% change GM or WM (pre-resection
roi = pre .* (diff > 0.25); % must also show 25% increase in CSF likelihood after resection

% find largest cluster
CC = bwconncomp(roi);
N = length(CC.PixelIdxList); % number of clusters
clusters = zeros(N,1); % preallocate space for cluster sizes
for j = 1:N
    clusters(j) = length(CC.PixelIdxList{1,j}); % get size of cluster
end
[val,idx] = max(clusters); % get max

% generate ROI for resection
ROI = zeros(size(roi));
ROI(CC.PixelIdxList{1,idx}) = 1;
ROI = single(ROI); % make proper output precision

% subtract resection roi from template mask
%filename = fullfile(filepath,'T_templateBrainExtractionMask.nii.gz');
filename = './T_templateBrainExtractionMask.nii.gz';
mask = niftiread(filename);
mask = mask - ROI;

% take difference and save masked template
info = niftiinfo(filename);
filename = fullfile(outpath,'template_resection_masked');
niftiwrite(mask, filename, info,'Compressed',1);

% take difference and save masked template
filename = fullfile(filepath,'T_templateBrainExtractionMask.nii.gz');
info = niftiinfo(filename);
filename = fullfile(outpath,'resection_mask_SST');
niftiwrite(ROI, filename, info,'Compressed',1);

end
