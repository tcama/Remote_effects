function [mask,roi] = resection_priors_10222019(filepath)
% This function takes in the path to a single subject template, where
% images have been 
%
% Thomas Campbell Arnold
% tcarnold@seas.upenn.edu
% 5/30/2019

outpath = fullfile(filepath, 'LCT_manual');

% read in segmentations
filename = fullfile(outpath,'post2SST_resection_mask.nii.gz');
roi = niftiread(filename);
filename = fullfile(filepath,'SingleSubjectTemplate','T_templateBrainExtractionMask.nii.gz');
mask = niftiread(filename);

mask = abs(mask - roi);

% take difference and save masked template
info = niftiinfo(filename);
filename = fullfile(outpath,'template_resection_masked');
niftiwrite(mask, filename, info);

%% get probability mask
filename = fullfile(filepath,'SingleSubjectTemplate','T_templateBrainExtractionMaskPrior.nii.gz');
mask = niftiread(filename);

mask = abs(mask - roi);

% take difference and save masked template
info = niftiinfo(filename);
filename = fullfile(outpath,'template_resection_probability_masked');
niftiwrite(mask, filename, info);


%% edit priors
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors1.nii.gz');
prior1 = niftiread(filename);
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors2.nii.gz');
prior2 = niftiread(filename);
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors3.nii.gz');
prior3 = niftiread(filename);
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors4.nii.gz');
prior4 = niftiread(filename);

% multiply by roi negative to remove roi from prior
prior1 = abs(prior1 .* abs(roi-1));
prior2 = abs(prior2 .* abs(roi-1));
prior3 = abs(prior3 .* abs(roi-1));
prior4 = abs(prior4 .* abs(roi-1));

% save out editted priors
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors1.nii.gz');
info = niftiinfo(filename);
filename = fullfile(outpath,'resectionPriors1.nii');
niftiwrite(prior1, filename, info);
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors2.nii.gz');
info = niftiinfo(filename);
filename = fullfile(outpath,'resectionPriors2.nii');
niftiwrite(prior2, filename, info);
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors3.nii.gz');
info = niftiinfo(filename);
filename = fullfile(outpath,'resectionPriors3.nii');
niftiwrite(prior3, filename, info);
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors4.nii.gz');
info = niftiinfo(filename);
filename = fullfile(outpath,'resectionPriors4.nii');
niftiwrite(prior4, filename, info);

% save out resection as prior5
filename = fullfile(filepath,'SingleSubjectTemplate','T_templatePriors4.nii.gz');
info = niftiinfo(filename);
filename = fullfile(outpath,'resectionPriors5.nii');
niftiwrite(single(roi), filename, info);

end
