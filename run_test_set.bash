#!/bin/bash

REPO_PATH="https://github.com/PiotrTyrakowski/pyradiomics-CUDA.git"
PYTHON_COMMAND="python3.9"

# 1. Get The repo working
mkdir build
cd build
git clone "${REPO_PATH}"
