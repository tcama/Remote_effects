#!/bin/bash
#
# warp the atlas to the NickOasisTemplate space
#
# atlas2template.sh atlas116.nii pat08
#
# Thomas Campbell Arnold 5/17/2019
# tcarnold@seas.upenn.edu

MAIN_DIR=/gdrive/public/USERS/tcarnold/remote_effects/VUMC_postsurg_TLE/LCT_pipeline/${2}/
ATLAS_DIR=/mnt/local/gdrive/public/USERS/lkini/Templates/NickOasisTemplate/
OUT_DIR=/mnt/local/gdrive/public/USERS/tcarnold/atlases/
mkdir ${OUT_DIR}

## Registration of Atlas_template to SST
#antsRegistration \
#--dimensionality 3 \
#--float 0 \
#--output ${OUT_DIR}atlas2template_ \
#--interpolation Linear \
#--use-histogram-matching 0 \
#--initial-moving-transform [${ATLAS_DIR}T_template0.nii.gz,${OUT_DIR}MNI_T1.nii,1] \
#--transform Rigid[0.1] \
#--metric MI[${ATLAS_DIR}T_template0.nii.gz,${OUT_DIR}MNI_T1.nii,1,32,Regular,0.25] \
#--convergence [1000x500x250x100,1e-6,10] \
#--shrink-factors 8x4x2x1 \
#--smoothing-sigmas 3x2x1x0vox \
#--transform Affine[0.1] \
#--metric MI[${ATLAS_DIR}T_template0.nii.gz,${OUT_DIR}MNI_T1.nii,1,32,Regular,0.25] \
#--convergence [1000x500x250x100,1e-6,10] \
#--shrink-factors 8x4x2x1 \
#--smoothing-sigmas 3x2x1x0vox \
#--transform SyN[0.1,3,0] \
#--metric CC[${ATLAS_DIR}T_template0.nii.gz,${OUT_DIR}MNI_T1.nii,1,4] \
#--convergence [100x70x50x20,1e-6,10] \
#--shrink-factors 8x4x2x1 \
#--smoothing-sigmas 3x2x1x0vox

# transform Atlas to template space
antsApplyTransforms \
-d 3 \
-i ${OUT_DIR}MNI_T1.nii ${OUT_DIR}${1} \
-o ${OUT_DIR}atlas2template_${1} \
-t ${OUT_DIR}atlas2template_1Warp.nii.gz \
-t ${OUT_DIR}atlas2template_0GenericAffine.mat \
-r ${ATLAS_DIR}T_template0.nii.gz \
-n NearestNeighbor

# transform Atlas to SST space
antsApplyTransforms \
-d 3 \
-i ${OUT_DIR}atlas2template_${1} \
-o ${OUT_DIR}SST_${1} \
-t ${MAIN_DIR}/SingleSubjectTemplate/Atlas/atlas2SST_1Warp.nii.gz \
-t ${MAIN_DIR}/SingleSubjectTemplate/Atlas/atlas2SST_0GenericAffine.mat \
-r ${MAIN_DIR}SingleSubjectTemplate/T_template0.nii.gz \
-n NearestNeighbor

# transform SST_Atlas to native image space (pre)
IMG=T1W3D-0001_pre
IMG_FOLDER=${MAIN_DIR}${IMG}_${2}_0/
antsApplyTransforms \
-d 3 \
-i ${OUT_DIR}SST_${1} \
-n NearestNeighbor \
-o ${OUT_DIR}pre_${1} \
-t ${IMG_FOLDER}${IMG}_${2}SubjectToTemplate0GenericAffine.mat \
-t ${IMG_FOLDER}${IMG}_${2}TemplateToSubject0Warp.nii.gz \
-r ${IMG_FOLDER}${IMG}_${2}CorticalThickness.nii.gz
 
 # transform SST_Atlas to native image space (post)
IMG=T1W3D-0001_post
IMG_FOLDER=${MAIN_DIR}${IMG}_${2}b_1/
antsApplyTransforms \
-d 3 \
-i ${OUT_DIR}SST_${1} \
-n NearestNeighbor \
-o ${OUT_DIR}post_${1} \
-t ${IMG_FOLDER}${IMG}_${2}bSubjectToTemplate0GenericAffine.mat \
-t ${IMG_FOLDER}${IMG}_${2}bTemplateToSubject0Warp.nii.gz \
-r ${IMG_FOLDER}${IMG}_${2}bCorticalThickness.nii.gz

