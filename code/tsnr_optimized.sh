#!/bin/bash

# Set the number of cores to use
NCORES=20

# Ensure paths are correct irrespective from where user runs the script
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
datadir=/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep
tasks=("trust" "ugr" "sharedreward" "doors" "socialdoors")

# Print header
echo -e "sub\t task\t echo\t run\t mean_stan\t vsmean_stan\t mean_nat\t vsmean_nat\t max"

# Define a function to process a single subject
process_subject() {
    sub=$1
    for task in "${tasks[@]}"; do
        for run in 1 2; do
        		for echo in  1 2 3 4; do
            stan_file="/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz"
            nat_file="/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_echo-${echo}_desc-preproc_bold.nii.gz"

            if [ -e "$stan_file" ]; then
                # Apply transformation using antsApplyTransforms
                antsApplyTransforms \
                -i /ZPOOL/data/projects/rf1-sra-trust/masks/VS-Imanova_2mm_re.nii \
                -r /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_part-mag_desc-coreg_boldref.nii.gz \
                -t /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/anat/sub-${sub}_from-MNI152NLin6Asym_to-T1w_mode-image_xfm.h5 \
                -t [/ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_from-boldref_to-T1w_mode-image_desc-coreg_xfm.txt, 1] \
                -n Linear \
                -o /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-${run}_space-native_roi-vs_mask.nii.gz
                
                fslmaths "$stan_file" -Tmean tmp_mean
                fslmaths "$stan_file" -Tstd tmp_std
                fslmaths tmp_mean -div tmp_std tmp_tsnr
                fslmaths tmp_tsnr -thr 2 thr_tmp_tsnr
                max=$(fslstats thr_tmp_tsnr -R | awk '{ print $2 }')
                mean_stan=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_space-MNI152NLin6Asym_desc-brain_mask.nii.gz -M)
                vsmean_stan=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-trust/masks/VS-Imanova_2mm_re.nii -M)
            else
                mean_stan="NA"
                vsmean_stan="NA"
                max="NA"
            fi

            if [ -e "$nat_file" ]; then
                fslmaths "$nat_file" -Tmean tmp_mean
                fslmaths "$nat_file" -Tstd tmp_std
                fslmaths tmp_mean -div tmp_std tmp_tsnr
                fslmaths tmp_tsnr -thr 2 thr_tmp_tsnr
                max=$(fslstats thr_tmp_tsnr -R | awk '{ print $2 }')
                mean_nat=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/func/sub-${sub}_task-${task}_run-${run}_desc-brain_mask.nii.gz -M)
                vsmean_nat=$(fslstats thr_tmp_tsnr -k /ZPOOL/data/projects/rf1-sra-data/derivatives/fmriprep/sub-${sub}/sub-${sub}_task-${task}_run-${run}_space-native_roi-vs_mask.nii.gz -M)
            else
                mean_nat="NA"
                vsmean_nat="NA"
            fi

            echo -e "$sub\t $task\t $echo\t $run\t $mean_stan\t $vsmean_stan\t $mean_nat\t $vsmean_nat\t $max"
        done
    	done
   done
}

# Read the subject list and process subjects one at a time
while IFS= read -r sub; do
    process_subject "$sub"
done < /ZPOOL/data/projects/rf1-sra-data/code/sublist_all.txt
