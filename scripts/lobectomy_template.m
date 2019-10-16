function [] = lobectomy_template(out_dir)

% C:\Users\tca11\Desktop\CNT\Remote_effects\tmp\ADNI_resection\small_test\lobectomy_atlas
%main_dir = 'C:\Users\tca11\Desktop\CNT\Remote_effects\tmp\ADNI_resection\small_test\';
%cd(main_dir);
%out_dir = 'C:\Users\tca11\Desktop\CNT\Remote_effects\tmp\ADNI_resection\small_test\lobectomy_atlas\';

% read in relevant files
AAL = load_nifti('AAL2Oasis_atlas.nii.gz');
CSF = load_nifti([out_dir,'Priors2/priors1.nii.gz']);

% HIPPOG	Hippocampus_L	4101
% HIPPOD	Hippocampus_R	4102
% PARA_HIPPOG	ParaHippocampal_L	4111
% PARA_HIPPOD	ParaHippocampal_R	4112
% AMYGDG	Amygdala_L	4201
% AMYGDD	Amygdala_R	4202
% T1AG	Temporal_Pole_Sup_L	8121
% T1AD	Temporal_Pole_Sup_R	8122
% T2AG	Temporal_Pole_Mid_L	8211
% T2AD	Temporal_Pole_Mid_R	8212

% choose which ROIs are removed
ROIs = [4102,4112,4202,8122,8212];  % right rois
%ROIs = [4101,4111,4201,8121,8211]; % left rois

% build a mask for the ROIs
lesion = zeros(size(AAL.vol));
for i = ROIs
    idx = find(AAL.vol == i);
    lesion(idx) = 1;
end

% edit the original priors
cd([out_dir,'Priors2/']);
lesion_inv = abs(1 - lesion);
for i = 1:4
    prior = load_nifti([out_dir,'Priors2/priors',num2str(i),'.nii.gz']);
    prior.vol = prior.vol .* lesion_inv; % remove voxels in the lesion zone
    save_nifti(prior,['priors',num2str(i),'.nii']);
    gzip(['priors',num2str(i),'.nii']); % compress
end
% add new prior of resection
prior = load_nifti([out_dir,'Priors2/priors',num2str(i),'.nii.gz']);
prior.vol = lesion; % change out volume for resection
save_nifti(prior,['priors',num2str(i+1),'.nii']);
gzip(['priors',num2str(i+1),'.nii']); % compress

% remove lesion from mask images
cd(out_dir);
mask = load_nifti([out_dir,'T_template0ProbabilityMask.nii.gz']);
mask.vol = mask.vol .* lesion_inv; % remove resection from mask
save_nifti(mask,'T_template0ProbabilityMask.nii');
gzip('T_template0ProbabilityMask.nii'); % compress
mask = load_nifti([out_dir,'T_template0ExtractionMask.nii.gz']);
mask.vol = mask.vol .* lesion_inv; % remove resection from mask
save_nifti(mask,'T_template0ExtractionMask.nii');
gzip('T_template0ExtractionMask.nii'); % compress

end