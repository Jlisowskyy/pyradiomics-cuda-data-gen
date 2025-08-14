import sys
import nibabel as nib
import numpy as np

def analyze_mask(mask_path):
    try:
        mask_img = nib.load(mask_path)
        mask_data = mask_img.get_fdata()
    except FileNotFoundError:
        print(f"  Error: Mask file not found at {mask_path}")
        return

    roi_labels = np.unique(mask_data)
    roi_labels = roi_labels[roi_labels > 0]

    if len(roi_labels) == 0:
        print("  No ROIs found in this mask.")
        return

    print(f"  Found {len(roi_labels)} ROI(s).")
    for label in roi_labels:
        label_mask = (mask_data == label)
        
        coords = np.argwhere(label_mask)
        if coords.shape[0] == 0:
            continue

        min_coords = coords.min(axis=0)
        max_coords = coords.max(axis=0)
        dimensions = max_coords - min_coords + 1
        
        roi_name = "Unknown"
        if label == 1:
            roi_name = "Kidney"
        elif label == 2:
            roi_name = "Tumor"

        size = dimensions[0]*dimensions[1]*dimensions[2]/1024/1024
        print(f"  - ROI: '{roi_name}' (Label: {int(label)})")
        print(f"    Bounding size MB: {size}")
        print(f"    Bounding Box Dimensions (voxels): {dimensions[0]} x {dimensions[1]} x {dimensions[2]}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python get_roi_info.py <path_to_segmentation_nii.gz>")
        sys.exit(1)
    
    mask_file_path = sys.argv[1]
    analyze_mask(mask_file_path)
