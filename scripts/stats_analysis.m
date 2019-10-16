cd('C:\Users\tca11\Desktop\CNT\Remote_effects\tmp\RE_results');
files = dir;
files = files(3:end);
cd ..
CT.regions = zeros(116,length(files));

for i = 1:length(files)

% file paths for pre and post imaging
resection_filepath = fullfile(files(i).folder,files(i).name,'pre_CT.nii.gz');
post_filepath = fullfile(files(i).folder,files(i).name,'post_CT.nii.gz');

% read in CT images
pre = niftiread(resection_filepath);
post = niftiread(post_filepath);

% file paths for pre and post imaging
resection_filepath = fullfile(files(i).folder,files(i).name,'pre_AAL116.nii');
post_filepath = fullfile(files(i).folder,files(i).name,'post_AAL116.nii');

% read in CT images
pre_atlas = niftiread(resection_filepath);
post_atlas = niftiread(post_filepath);
[labels,CT.pre(:,i)] = Atlas_mean_val(pre,pre_atlas);
[labels,CT.post(:,i)] = Atlas_mean_val(post,post_atlas);

% file paths for pre and post imaging
resection_filepath = fullfile(files(i).folder,files(i).name,'resection_mask');
resection = niftiread(resection_filepath);

rois = setdiff(post_atlas(find(post_atlas)),0); % get all roi regions
idx = find(resection); % get resection voxels
labels = post_atlas(idx); % get labels for resection voxels
CT.labels{i} = setdiff(unique(labels),0); % get unique non-zero values
[val,Ia,Ib]=intersect(CT.labels{i},rois); % get index of regions
CT.regions(Ib,i) = 1; % add affected regions to matrix

end

% remove cerebellar and deep gray matter ROIs
idx = [1:70 79:90];
CT.pre = CT.pre(idx,:);
CT.post = CT.post(idx,:);

% flip to make first 41 rois ipsilateral and 2nd 41 rois contralateral
Lflag = logical([1,0,0,1,0,1,1,0,0,1,1,1,0,0,0,0,1,0,1,0,1,0,0,0,0,1,0,0,0,0,0,0,1,1,0,0,0]);
Rflag = logical(abs(Lflag-1));
R_labels = [0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1];
L_labels = abs(R_labels-1);
R_idx = find(R_labels);
L_idx = find(L_labels);
CT_flip.pre = [CT.pre([R_idx L_idx],Rflag) CT.pre([L_idx R_idx],Lflag)];
CT_flip.post = [CT.post([R_idx L_idx],Rflag) CT.post([L_idx R_idx],Lflag)];

% get affected regions
figure
CT_flip.regions = CT.regions(idx ,:);
subplot(1,2,1);
imagesc(CT_flip.regions);
title('AAL regions overlapping resection ROI');
CT_flip.regions = [CT_flip.regions([R_idx L_idx],Rflag) CT_flip.regions([L_idx R_idx],Lflag)];
subplot(1,2,2);
imagesc(CT_flip.regions);
title('AAL regions overlapping resection ROI');

A={'Precentral contra	    '
'Precentral ipsa	    '
'Frontal Sup contra	    '
'Frontal Sup ipsa	    '
'Frontal Sup Orb contra	'
'Frontal Sup Orb ipsa	'
'Frontal Mid contra       '
'Frontal Mid ipsa       '
'Frontal Mid Orb contra	'
'Frontal Mid Orb ipsa	'
'Frontal Inf Oper contra	'
'Frontal Inf Oper ipsa	'
'Frontal Inf Tri contra	'
'Frontal Inf Tri ipsa	'
'Frontal Inf Orb contra	'
'Frontal Inf Orb ipsa	'
'Rolandic Oper contra     '
'Rolandic Oper ipsa     '
'Supp Motor Area contra	'
'Supp Motor Area ipsa	'
'Olfactory contra         '
'Olfactory ipsa         '
'Frontal Sup Medial contra'	
'Frontal Sup Medial ipsa'	
'Frontal Med Orb contra	'
'Frontal Med Orb ipsa	'
'Rectus contra	        '
'Rectus ipsa	        '
'Insula contra	        '
'Insula ipsa	        '
'Cingulum Ant contra	    '
'Cingulum Ant ipsa	    '
'Cingulum Mid contra	    '
'Cingulum Mid ipsa	    '
'Cingulum Post contra	    '
'Cingulum Post ipsa	    '
'Hippocampus contra	    '
'Hippocampus ipsa	    '
'ParaHippocampal contra   '
'ParaHippocampal ipsa   '
'Amygdala contra	        '
'Amygdala ipsa	        '
'Calcarine contra	        '
'Calcarine ipsa	        '
'Cuneus contra	        '
'Cuneus ipsa	        '
'Lingual contra	        '
'Lingual ipsa	        '
'Occipital Sup contra	    '
'Occipital Sup ipsa	    '
'Occipital Mid contra	    '
'Occipital Mid ipsa	    '
'Occipital Inf contra	    '
'Occipital Inf ipsa	    '
'Fusiform contra	        '
'Fusiform ipsa	        '
'Postcentral contra	    '
'Postcentral ipsa	    '
'Parietal Sup contra	    '
'Parietal Sup ipsa	    '
'Parietal Inf contra	    '
'Parietal Inf ipsa	    '
'SupraMarginal contra	    '
'SupraMarginal ipsa	    '
'Angular contra	        '
'Angular ipsa	        '
'Precuneus contra	        '
'Precuneus ipsa	        '
'Paracentral contraobule contra'
'Paracentral contraobule ipsa'
'Caudate contra	        '
'Caudate ipsa	        '
'Putamen contra	        '
'Putamen ipsa	        '
'Pallidum contra	        '
'Pallidum ipsa	        '
'Thalamus contra	        '
'Thalamus ipsa	        '
'Heschl contra	        '
'Heschl ipsa	        '
'Temporal Sup contra	    '
'Temporal Sup ipsa	    '
'Temporal Pole Sup contra	'
'Temporal Pole Sup ipsa	'
'Temporal Mid contra	    '
'Temporal Mid ipsa	    '
'Temporal Pole Mid contra	'
'Temporal Pole Mid ipsa	'
'Temporal Inf contra	    '
'Temporal Inf ipsa	    '}