
# generate template for ROI analysis
./scripts/atlas2ADNI_normal.sh AAL116_origin_MNI_T1.nii

# loop through HUP subjects
for sub in 14_w 15_e 20_l 22_m 23_r 24_c 25_f 26_k 27_m 28_d 29_w 30_m 31_h 33_s 40_f 41_h 42_m
do
	screen -dmS ${sub} sh
	screen -S ${sub} -X stuff "cd /gdrive/public/USERS/tcarnold/Projects/Remote_effects/
	./scripts/LCT_ADNI.sh ${sub}
	./scripts/resection_roi_affine.sh ${sub} ${sub}_preop.nii.gz ${sub}_postop.nii.gz 
	./scripts/LCT_resection_priors.sh ${sub} ${sub}_preop.nii.gz ${sub}_postop.nii.gz
	"
done

# loop through VU subjects
for sub in 02 03 04 05 06 07 08 09 11 13 14 15 18 20 21 22 23 24 25 26 27 30 32
do
	screen -dmS pat${sub} sh
	screen -S pat${sub} -X stuff "cd /gdrive/public/USERS/tcarnold/Projects/Remote_effects/
	./scripts/LCT_ADNI.sh pat${sub}
	./scripts/resection_roi_affine.sh pat${sub} T1W3D-0001_pre_pat${sub}.nii T1W3D-0001_post_pat${sub}b.nii
	./scripts/LCT_resection_priors.sh pat${sub} T1W3D-0001_pre_pat${sub}.nii T1W3D-0001_post_pat${sub}b.nii
	"
done