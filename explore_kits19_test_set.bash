#!/bin/bash

readonly DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly REPO_PATH="https://github.com/PiotrTyrakowski/pyradiomics-CUDA.git"
readonly TEST_SET_REPO="https://github.com/neheller/kits19.git"
readonly PYTHON_COMMAND="python3.9"
readonly BUILD_DIR="${DIR}/build"
readonly NUM_TEST_INPUT_POINTS=100

# 1. Setup build directory
mkdir build
cd build
$PYTHON_COMMAND -m venv .venv
source .venv/bin/activate
pip install nibabel

# 2. Get the dataset
cd ${BUILD_DIR}
git clone ${TEST_SET_REPO}

# 3. Prepare data set
cd kits19
pip install -r requirements.txt
sed -i "s/for i in range(300):/for i in range(${NUM_TEST_INPUT_POINTS}):/g" starter_code/get_imaging.py
python -m starter_code.get_imaging

# 4. Explore
cd ${BUILD_DIR}
for (( i=0; i<$NUM_TEST_INPUT_POINTS; i++ ))
do
    case_name=$(printf "case_%05d" "$i")
    case_path="./kits19/data/${case_name}"
    mask_path="${case_path}/segmentation.nii.gz"

    echo "======================== ${case_name} ========================"
    python "${DIR}/get_roi_info.py" "${mask_path}"
done
