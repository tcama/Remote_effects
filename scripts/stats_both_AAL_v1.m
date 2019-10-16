main_dir = 'C:\Users\tca11\Desktop\CNT\Remote_effects\tmp\RE_results';

% subject folder names
subs_HUP = {'14_w';'15_e';'23_r';'24_c';'25_f';'27_m';'28_d';'29_w';'30_m';'31_h';'40_f';'41_h';'42_m'};
subs_VU = {'pat02'; 'pat03'; 'pat04'; 'pat05'; 'pat06'; 'pat07'; 'pat08'; 'pat09'; 'pat11'; 'pat13'; 'pat14'; 'pat15'; 'pat18'; 'pat20'; 'pat21'; 'pat22'; 'pat23'; 'pat24'; 'pat25'; 'pat26'; 'pat27'; 'pat30'; 'pat32'};
subs = [subs_HUP; subs_VU];

% determine which ROIs are left versus right
R_labels = [0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1];
L_labels = abs(R_labels-1);
R_idx = find(R_labels);
L_idx = find(L_labels);

%% Get mean ROI values for each subject

% read in data for each subject
[CT_vals,labels] = read_data(main_dir,subs);


%% (AAL - LR asymmetry) T-test comparing pre v.s. post for each ROI
% does not control for LATL versus RATL

% index (1:21) of subjects with LATL
TLE_L_HUP = [1 4 6:7 10:11]; % HUP left TLE patients
TLE_L_VU = [3,5,7,12,19,20]; % VU left TLE pateints
TLE_L = [TLE_L_HUP (TLE_L_VU + size(subs_HUP,1))]; % offset VU by numver of HUP patients

% sort into contralateral and ipsilateral based on TLE_L
for i = 1:length(subs)
    if find(TLE_L==i) % if TLE_L patient, ipsilateral left ROIs are first
    	CI_vals{1,i}.pre = [CT_vals{1,i}.pre(L_idx) CT_vals{1,i}.pre(R_idx)];
        CI_vals{1,i}.post = [CT_vals{1,i}.post(L_idx) CT_vals{1,i}.post(R_idx)];
    else% if right TLE patient, ipsilateral right ROIs are first
        CI_vals{1,i}.pre = [CT_vals{1,i}.pre(R_idx) CT_vals{1,i}.pre(L_idx)];
        CI_vals{1,i}.post = [CT_vals{1,i}.post(R_idx) CT_vals{1,i}.post(L_idx)];
    end
end

N = length(CT_vals{1,1}.pre); % get number of ROIs
clear vals_pre vals_post h p t mean_diff

% loop through each ROI and get mean difference
for i = 1:N
    
    % get values for comparison
    for j = 1:length(good_subs)%1:length(subs)
        vals_pre(j) = CI_vals{1,good_subs(j)}.pre(i);
        vals_post(j) = CI_vals{1,good_subs(j)}.post(i);
    end
    
    % run t-test
    [h(i),p(i),~,stat] = ttest(vals_pre,vals_post);
    t(i) = stat.tstat;
    mean_diff(i) = -(mean(vals_pre) - mean(vals_post)) / mean(vals_pre);
    median_diff(i) = -(median(vals_pre) - median(vals_post)) / median(vals_pre);
    
end

% concatenate results
mean_diff = mean_diff';
p=p'; t=t'; h=h';
results = [h p t mean_diff];

%% plot
n = 0;
figure
TLE_R = setdiff(1:size(subs,1),TLE_L);
for j = 1:82
    m = ceil( sqrt( sum( results(:,1)))); % make a square plot based on the number of significant results 
    if results(j,1) == 1
        n=n+1;
        subplot(m,m,n)
        for i = 1:numel(good_subs)
            vals_pre(i) = CI_vals{1,good_subs(i)}.pre(j);
            vals_post(i) = CI_vals{1,good_subs(i)}.post(j);
        end
        
        scatter(vals_pre,vals_post);
        hold on
        %scatter(vals_pre(setdiff(TLE_L,bad_subs)),vals_post(setdiff(TLE_L,bad_subs)));
        plot([0,max([vals_pre vals_post])],[0,max([vals_pre vals_post])]);
        xlabel('preop CT');
        ylabel('postop CT');
        title(num2str(j))
    end
end

%% FUNCTIONS
% test Atlas_mean_val function

function [labels,vals] = Atlas_vals(img,atlas)
% used to assess the mean values in img for each label in atlas
%
% Input:
%       img - Nifti image in atlas space
%       atlas - Nifti image in atlas space, intensity corresponds to atlas
%               labels
%
% Output:
%       labels - intensity values in the atlas
%       vals - mean value in img for each atlas voxel label
%

% get labels in atlas
labels = unique(atlas(:));
labels = setdiff(labels,0); % remove 0 as a label
vals = zeros(length(labels),1); % preallocate space for mean intensity values

% loop through and get mean for each label
for i = 1:length(labels)
    idx1 = atlas == labels(i); % get label locations in atlas
    idx2 = img > 0; % get label locations in CT image
    idx = find(idx1.*idx2); % get overlapping voxels
    vals(i,1) = mean(img(idx)); % add mean value to array
    vals(i,2) = median(img(idx)); % add mean value to array
end

end

function [CT_vals,labels] = read_data(main_dir,subs)
% read in all data and parse based on atlas

for i = 1:length(subs)
    
    % file paths for pre and post imaging
    pre_filepath = fullfile(main_dir,subs{i},'pre_CT.nii.gz');
    post_filepath = fullfile(main_dir,subs{i},'post_CT.nii.gz');
    
    % read in CT images
    pre = niftiread(pre_filepath);
    post = niftiread(post_filepath);
    
    % file paths for pre and post imaging
    pre_filepath = fullfile(main_dir,subs{i},'pre_AAL116.nii');
    post_filepath = fullfile(main_dir,subs{i},'post_AAL116.nii');
    
    % read in CT images
    pre_atlas = niftiread(pre_filepath);
    post_atlas = niftiread(post_filepath);
    
    % get the mean values
    pre_atlas = atlas_scrub(pre_atlas); % remove unnecessary ROIs
    post_atlas = atlas_scrub(post_atlas); % remove unnecessary ROIs
    [labels,CT_vals{i}.pre] = Atlas_vals(pre,pre_atlas);
    [labels,CT_vals{i}.post] = Atlas_vals(post,post_atlas);
end
end

function [scrubbed_atlas] = atlas_scrub(atlas)
% This function removes unnecessary ROIs from the atlas

rois = [2001,2002,2101,2102,2111,2112,2201,2202,2211,2212,2301,2302,2311,2312,2321,2322,2331,2332,2401,2402,2501,2502,2601,2602,2611,2612,2701,2702,3001,3002,4001,4002,4011,4012,4021,4022,4101,4102,4111,4112,4201,4202,5001,5002,5011,5012,5021,5022,5101,5102,5201,5202,5301,5302,5401,5402,6001,6002,6101,6102,6201,6202,6211,6212,6221,6222,6301,6302,6401,6402,7001,7002,7011,7012,7021,7022,7101,7102,8101,8102,8111,8112,8121,8122,8201,8202,8211,8212,8301,8302,9001,9002,9011,9012,9021,9022,9031,9032,9041,9042,9051,9052,9061,9062,9071,9072,9081,9082,9100,9110,9120,9130,9140,9150,9160,9170];
idx = [1:70 79:90]; % included ROIs
rois = rois(idx);

scrubbed_atlas = zeros(size(atlas));
for i = rois
    idx = find(atlas==i);
    scrubbed_atlas(idx) = i;
end

end


