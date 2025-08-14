#!/bin/bash

readonly DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
readonly REPO_PATH="https://github.com/PiotrTyrakowski/pyradiomics-CUDA.git"
readonly TEST_SET_REPO="https://github.com/neheller/kits19.git"
readonly PYTHON_COMMAND="python3.9"
readonly BUILD_DIR="${DIR}/build"
readonly NUM_TEST_INPUT_POINTS=2
readonly NUM_TEST_REPEATS_PER_INPUT_POINT=2

# 1. Setup build directory
mkdir build
cd build
$PYTHON_COMMAND -m venv .venv
source .venv/bin/activate
pip install "numpy<2"
pip install pyradiomics

# 2. Get the repo
git clone "${REPO_PATH}"
cd pyradiomics-CUDA
git checkout dev
cd radiomics/src/cuda/

# 3. Build Test framework
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=RELEASE
make -j$(nproc)

# 4. Copy artefacts to build dir
cp TEST_APP ${BUILD_DIR}
cd ..
cp ./test/data_transform.py ${BUILD_DIR}

# 5. Get the dataset
cd ${BUILD_DIR}
git clone ${TEST_SET_REPO}

# 6. Prepare data set
cd kits19
pip install -r requirements.txt
sed -i "s/for i in range(300):/for i in range(${NUM_TEST_INPUT_POINTS}):/g" starter_code/get_imaging.py
python -m starter_code.get_imaging

# 7. Convert input data to test framework input
cd ${BUILD_DIR}
for (( i=0; i<$NUM_TEST_INPUT_POINTS; i++ ))
do
    case_name=$(printf "case_%05d" "$i")
    case_path="./kits19/data/${case_name}"

    python data_transform.py -m "${case_path}/segmentation.nii.gz" -s "${case_path}/imaging.nii.gz" -n 2 -p "kits19_${case_name}"
done

# 8. Run the tests
files_str=""
for (( i=0; i<$NUM_TEST_INPUT_POINTS; i++ ))
do
    case_name=$(printf "case_%05d" "$i")
    data_path="./data/kits19_${case_name}"

    files_str="${files_str} ${data_path}_1 ${data_path}_2"
done

./TEST_APP -r ${NUM_TEST_REPEATS_PER_INPUT_POINT} -o ./out -f ${files_str} --csv
