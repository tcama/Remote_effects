#!/bin/bash
#
# This code warps an atlas to the ADNI normal template space.
#
# Usage: ./scripts/atlas2ADNI_normal.sh AAL116_origin_MNI_T1.nii
#
#
# Thomas Campbell Arnold 
# tcarnold@seas.upenn.edu
# 
# 5/17/2019 - created
# 6/5/2019 - seperated into atlas2NickOasis.sh and atlas2native.sh
# 9/19/2019 - converted to run on ANDI normal dataset, renamed atlas2ADNI_normal.sh
# 10/3/2019 - use the origin_MNI image to 

TEMPLATE_DIR=./tools/ADNI_normal_atlas/
ATLAS_DIR=./tools/atlases/

# name of atlas being used
IMG=$(echo "$1" | cut -f 1 -d '.')

# Registration of MNI-Atlas to ADNI normal template
antsRegistration \
--dimensionality 3 \
--float 0 \
--output ${ATLAS_DIR}atlas2template_${IMG} \
--interpolation Linear \
--use-histogram-matching 0 \
--initial-moving-transform [${TEMPLATE_DIR}T_template0.nii.gz,${ATLAS_DIR}MNI_T1.nii,1] \
--transform Rigid[0.1] \
--metric MI[${TEMPLATE_DIR}T_template0.nii.gz,${ATLAS_DIR}MNI_T1.nii,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[${TEMPLATE_DIR}T_template0.nii.gz,${ATLAS_DIR}MNI_T1.nii,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric CC[${TEMPLATE_DIR}T_template0.nii.gz,${ATLAS_DIR}MNI_T1.nii,1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox

# transform MNI-template to ADNI-template space
antsApplyTransforms \
-d 3 \
-i ${ATLAS_DIR}MNI_T1.nii \
-o ${ATLAS_DIR}atlas2template_MNI_T1.nii \
-t ${ATLAS_DIR}atlas2template_${IMG}1Warp.nii.gz \
-t ${ATLAS_DIR}atlas2template_${IMG}0GenericAffine.mat \
-r ${TEMPLATE_DIR}T_template0.nii.gz \
-n Linear

# transform MNI-Atlas to ADNI-template space
antsApplyTransforms \
-d 3 \
-i ${ATLAS_DIR}${1} \
-o ${ATLAS_DIR}atlas2template_${1} \
-t ${ATLAS_DIR}atlas2template_${IMG}1Warp.nii.gz \
-t ${ATLAS_DIR}atlas2template_${IMG}0GenericAffine.mat \
-r ${TEMPLATE_DIR}T_template0.nii.gz \
-n NearestNeighbor




