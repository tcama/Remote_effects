#!/bin/bash
#
# Input:    Oasis Template
#           AAL atlas and corresponding MNI image
#
# Usage:    HCP_virtual_lesion.sh unaffected_sub1.nii pre_lesion_sub2.nii lesion_mask_sub2.nii
#
# Steps:    1. register sub2 to sub1
#           2. transfrom lesion to sub1 space
#           3. extract brain of sub1
#           4. segment sub1 into tissue types (CSF,GM,WM,DGM)
#           5. apply lesion using matlab
#
# Output:   previously unaffected image (in native space) with lesion applied
#
# Thomas Campbell Arnold 
# tcarnold@seas.upenn.edu
#
# 8/19/2019 - created

# make directory for output and place original template in folder
OUTDIR=./tools/lobectomy_atlas/
mkdir ${OUTDIR}
cp -r ./tools/OasisTemplate/* ${OUTDIR}

# change all images in directory to have centered origin
FILES=$(find ${OUTDIR} -type f -name '*.nii.gz')
for file in FILES
do
c3d $file -origin-voxel 50% -o $file
done

# name relevant inputs
AAL_T1=./tools/atlases/MNI_T1.nii
AAL=./tools/atlases/AAL116_origin_MNI_T1.nii
OASIS_T1=${OUTDIR}/T_template0.nii.gz

# deformable registration of MNI atlas subject to Nick Oasis Template
antsRegistration \
--dimensionality 3 \
--float 0 \
--output AAL2Oasis_ \
--interpolation Linear \
--use-histogram-matching 0 \
--initial-moving-transform [${OASIS_T1},${AAL_T1},1] \
--transform Rigid[0.1] \
--metric MI[${OASIS_T1},${AAL_T1},1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[${OASIS_T1},${AAL_T1},1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform SyN[0.1,3,0] \
--metric CC[${OASIS_T1},${AAL_T1},1,4] \
--convergence [100x70x50x20,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox

# transform MNI template to Oasis template space
antsApplyTransforms \
-d 3 \
-i ${AAL_T1} \
-o AAL2Oasis_T1.nii.gz \
-t AAL2Oasis_0GenericAffine.mat \
-t AAL2Oasis_1Warp.nii.gz \
-r ${OASIS_T1} \
-n Linear

# transform AAL MNI template to Oasis template space
antsApplyTransforms \
-d 3 \
-i ${AAL} \
-o AAL2Oasis_atlas.nii.gz} \
-t AAL2Oasis_0GenericAffine.mat \
-t AAL2Oasis_1Warp.nii.gz \
-r ${OASIS_T1} \
-n NearestNeighbor

# generate lesioned template priors
matlab -nodesktop -nosplash -r "lobectomy_template('"${OUTDIR}"'); exit"

###############################################################################
# for CFN

# make directory for output and place original template in folder
OUTDIR=./lobectomy_atlas/
mkdir ${OUTDIR}
cp -r ./OasisTemplate/* ${OUTDIR}

# change all images in directory to have centered origin
FILES=$(find ${OUTDIR} -type f -name '*.nii.gz')
for file in ${FILES}
do
c3d ${file} -origin-voxel 50% -o ${file}
done

# name relevant inputs
AAL_T1=./atlases/MNI_T1.nii
AAL=./atlases/AAL116_origin_MNI_T1.nii
OASIS_T1=${OUTDIR}/T_template0.nii.gz

antsRegistration \
--dimensionality 3 \
--float 0 \
--output AAL2Oasis_ \
--interpolation Linear \
--use-histogram-matching 0 \
--initial-moving-transform [${OASIS_T1},${AAL_T1},1] \
--transform Rigid[0.1] \
--metric MI[${OASIS_T1},${AAL_T1},1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[${OASIS_T1},${AAL_T1},1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox 

# transform MNI template to Oasis template space
antsApplyTransforms \
-d 3 \
-i ${AAL_T1} \
-o AAL2Oasis_test.nii.gz \
-t AAL2Oasis_0GenericAffine.mat \
-r ${OASIS_T1} \
-n Linear

# transform AAL MNI template to Oasis template space
antsApplyTransforms \
-d 3 \
-i ${AAL} \
-o AAL2Oasis_atlas.nii.gz \
-t AAL2Oasis_0GenericAffine.mat \
-r ${OASIS_T1} \
-n NearestNeighbor

# generate lesioned template priors
matlab -nodesktop -nosplash -r "lobectomy_template('"${OUTDIR}"'); exit"
