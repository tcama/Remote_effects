function [mask,roi] = resection_mask(filepath)
% This function takes in the path to a single subject template, where
% images have been 
%
% Thomas Campbell Arnold
% tcarnold@seas.upenn.edu
% 5/30/2019

outpath = fullfile(filepath, 'LCT_final');

% read in segmentations
filename = fullfile(outpath,'post2SST_resection_mask.nii.gz');
roi = niftiread(filename);
filename = fullfile(filepath,'SingleSubjectTemplate','T_templateBrainExtractionMask.nii.gz');
mask = niftiread(filename);

mask = mask - roi;

% take difference and save masked template
info = niftiinfo(filename);
filename = fullfile(outpath,'template_resection_masked');
niftiwrite(mask, filename, info,'Compressed',1);

end
