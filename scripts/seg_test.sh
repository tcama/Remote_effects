#!/bin/bash
#
# This file takes in two images (pre-resection and post-resection), performs an affine registration,
# warps the previously generated Atropos segmentation to the same space, and generates an roi image
# of the resection zone
# 
# Usage:    scripts/seg_test.sh pat03 T1W3D-0001_pre_pat03.nii T1W3D-0001_post_pat03b.nii
#           resection_roi_affine.sh pat02 T1W3D-0001_pre_pat02.nii T1W3D-0001_post_pat02b.nii
#           resection_roi_affine.sh 15_em 15_e_preop.nii.gz 15_e_postop.nii.gz
# 
#   pat04 - HUP subject ID
#   15_e - VU subject ID
#
#
# Data:
# HUP subjects (17)
# subs = ['14_w';'15_e';'20_l';'22_m';'23_r';'24_c';'25_f';'26_k';'27_m';'28_d';'29_w';'30_m';'31_h';'33_s';'40_f';'41_h';'42_m';];
# VU Subjects (23)
# subs = ['02'; '03'; '04'; '05'; '06'; '07'; '08'; '09'; '11'; '13'; '14'; '15'; '18'; '20'; '21'; '22'; '23'; '24'; '25'; '26'; '27'; '30'; '32'];
#
# Thomas Campbell Arnold
# tcarnold@seas.upenn.edu
# 5/23/2019

DATA_DIR=./data/${1}/
TEMPLATE_DIR=./tools/OasisTemplate/

# set image names to variable

name=$(echo "$3" | cut -f 1 -d '.')
post=${name}

# setup output directory
OUT_DIR=./analysis/${1}/
mkdir $OUT_DIR
OUT_DIR=./analysis/${1}/resection_affine/
mkdir $OUT_DIR

# Registration of pre-resection to post-resection
antsRegistration \
--dimensionality 3 \
--float 0 \
--output ${OUT_DIR}pre2post_ \
--interpolation Linear \
--use-histogram-matching 0 \
--initial-moving-transform [${DATA_DIR}${3},${DATA_DIR}${2},1] \
--transform Rigid[0.1] \
--metric MI[${DATA_DIR}${3},${DATA_DIR}${2},1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[${DATA_DIR}${3},${DATA_DIR}${2},1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox
#--masks [./analysis/${1}/${post}_0/${post}BrainExtractionMask.nii.gz]

# transform pre to post space
IMG_FOLDER=./analysis/${1}/${pre}_1/
antsApplyTransforms \
-d 3 \
-i ${DATA_DIR}${2} \
-o ${OUT_DIR}pre2post_${2} \
-t ${OUT_DIR}/pre2post_0GenericAffine.mat \
-r ${DATA_DIR}${3}

# get extraction mask in post-space
antsBrainExtraction.sh \
-d 3 \
-a ${OUT_DIR}pre2post_${2} \
-e ${TEMPLATE_DIR}T_template0.nii.gz \
-m ${TEMPLATE_DIR}T_template0ProbabilityMask.nii.gz \
-o ${OUT_DIR}

# Registration of template to pre-resection (post-space)
antsRegistration \
--dimensionality 3 \
--float 0 \
--output ${OUT_DIR}/template2post_ \
--interpolation Linear \
--use-histogram-matching 0 \
--initial-moving-transform [${OUT_DIR}/pre2post_${2},${TEMPLATE_DIR}T_template0.nii.gz,1] \
--transform Rigid[0.1] \
--metric MI[${OUT_DIR}pre2post_${2},${TEMPLATE_DIR}T_template0.nii.gz,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[${OUT_DIR}pre2post_${2},${TEMPLATE_DIR}T_template0.nii.gz,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric CC[${OUT_DIR}pre2post_${2},${TEMPLATE_DIR}T_template0.nii.gz,1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--masks [${OUT_DIR}BrainExtractionMask.nii.gz]

# transform priors to post-space
for i in 1 2 3 4
do
antsApplyTransforms \
-d 3 \
-i ${TEMPLATE_DIR}Priors2/priors${i}.nii.gz \
-o ${OUT_DIR}template2post_priors${i}.nii.gz \
-t ${OUT_DIR}template2post_1Warp.nii.gz \
-t ${OUT_DIR}template2post_0GenericAffine.mat \
-r ${DATA_DIR}${3}
done

# transform template extraction mask to post-space
antsApplyTransforms \
-d 3 \
-i ${TEMPLATE_DIR}T_template0Mask.nii.gz \
-o ${OUT_DIR}template2post_T_template0Mask.nii.gz \
-t ${OUT_DIR}template2post_1Warp.nii.gz \
-t ${OUT_DIR}template2post_0GenericAffine.mat \
-r ${DATA_DIR}${3}

# perform segmentation (pre)
antsAtroposN4.sh \
-d 3 \
-a ${OUT_DIR}pre2post_${2} \
-x ${OUT_DIR}template2post_T_template0Mask.nii.gz \
-c 4 \
-p ${OUT_DIR}template2post_priors%d.nii.gz \
-o ${OUT_DIR}pre_

# perform segmentation (post)
antsAtroposN4.sh \
-d 3 \
-a ${DATA_DIR}${3} \
-x ${OUT_DIR}template2post_T_template0Mask.nii.gz \
-c 4 \
-p ${OUT_DIR}template2post_priors%d.nii.gz \
-o ${OUT_DIR}post_

## transform pre seg1 (CSF) to post space
#IMG_FOLDER=./analysis/${1}/${pre}_1/
#antsApplyTransforms \
#-d 3 \
#-i ${OUT_DIR}pre_SegmentationPosteriors1.nii.gz \
#-o ${OUT_DIR}pre2post_BrainSegmentationPosteriors1.nii.gz \
#-t ${OUT_DIR}pre2post_0GenericAffine.mat \
#-r ${DATA_DIR}${3}
#
## transform pre seg2 (Gray Matter) to post space
#IMG_FOLDER=./analysis/${1}/${pre}_1/
#antsApplyTransforms \
#-d 3 \
#-i ${IMG_FOLDER}${pre}BrainSegmentationPosteriors2.nii.gz \
#-o ${OUT_DIR}pre2post_BrainSegmentationPosteriors2.nii.gz \
#-t ${OUT_DIR}pre2post_0GenericAffine.mat \
#-r ${DATA_DIR}${3}
#
## transform pre seg2 (White Matter) to post space
#IMG_FOLDER=./analysis/${1}/${pre}_1/
#antsApplyTransforms \
#-d 3 \
#-i ${IMG_FOLDER}${pre}BrainSegmentationPosteriors3.nii.gz \
#-o ${OUT_DIR}pre2post_BrainSegmentationPosteriors3.nii.gz \
#-t ${OUT_DIR}pre2post_0GenericAffine.mat \
#-r ${DATA_DIR}${3}
# 
## copy post CSF to resection_affine/
#IMG_FOLDER=./analysis/${1}/${post}_0/
#cp ${IMG_FOLDER}${post}BrainSegmentationPosteriors1.nii.gz ${OUT_DIR}post_BrainSegmentationPosteriors1.nii.gz
#cp ${DATA_DIR}${3} ${OUT_DIR}${3}

cd scripts
matlab -nodisplay -nosplash -r "resection_roi_affine('/gdrive/public/USERS/tcarnold/Remote_effects/analysis/"${1}"/'); exit;"
