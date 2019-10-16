function [] = lobectomy_generation(out_dir)

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
ROIs_R = [4102,4112,4202,8122,8212];
ROIs_L = [4101,4111,4201,8121,8211];

% build a mask for the ROIs
lesion_R = zeros(size(AAL.vol));
for i = ROIs_R
    idx = find(AAL.vol == i);
    lesion_R(idx) = 1;
end

% save out the lesion mask
lesion_R = single(lesion_R);
info.Filename = [out_dir,'lesionR.nii.gz'];
niftiwrite(lesion_R, 'lesionR', info, 'Compressed', 1);

% edit the original priors
cd([out_dir,'Priors2\']);
lesion_inv = abs(1 - lesion_R);
for i = 1:4
    info = niftiinfo([out_dir,'Priors2\priors',num2str(i),'.nii.gz']);
    prior = niftiread([out_dir,'Priors2\priors',num2str(i),'.nii.gz']);
    prior = prior .* lesion_inv; % remove voxels in the lesion zone
    niftiwrite(prior, ['priors',num2str(i)], info, 'Compressed', 1);
end
% add new prior of resection
info.Filename = [out_dir,'Priors2\priors5.nii.gz'];
niftiwrite(lesion_R, 'priors5', info, 'Compressed', 1);

%%

% read in necessary images
mask = load_nifti(mask_filepath);
CSF = load_nifti(CSF_filepath);
img = load_nifti(img_filepath);
brain_mask = load_nifti(brainmask_filepath);
mask.vol = mask.vol .* brain_mask.vol;
idx = find(mask.vol);
vals = img.vol(find(CSF.vol>0.99));
vals2=vals(randperm(length(vals)));
mask.vol(idx) = vals2(1:length(idx));

% Gaussian Filter
A = mask.vol;
sigma = 1;
% Find size of Gaussian filter
N = ceil(6*sigma);
% Define grid of centered coordinates of size N x N x N
[X, Y, Z] = meshgrid(-N/2 : N/2);
% Compute Gaussian filter - note normalization step
B = exp(-(X.^2 + Y.^2 + Z.^2) / (2.0*sigma^2));
B = B / sum(B(:));
% Convolve
C = convn(A, B);
[x,y,z] = size(A);
C = C((N/2)+1:x+(N/2),(N/2)+1:y+(N/2),(N/2)+1:z+(N/2));
%mask = imgaussfilt3(mask,1);

img.vol(idx) = C(idx);
img.vol = fliplr(img.vol);
save_nifti(img,'vl_patient.nii');


end


