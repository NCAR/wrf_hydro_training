#!/bin/bash
set -u  # Treat unset vars as error
red='\033[0;31m'
green='\033[0;32m'
nc='\033[0m'  # No Color

# List of notebook directory and filenames
notebook_dir="../lessons/training"
training_notebooks=(
"Lesson-0-start.ipynb"
"Lesson-1-compile.ipynb"
"Lesson-2-run.ipynb"
"Lesson-3-visualize.ipynb"
"Lesson-4-run-options.ipynb"
"Lesson-5-land-surface.ipynb"
"Lesson-6-lakes.ipynb"
"Lesson-7-configurations.ipynb"
)
supplemental_notebooks=(
"Lesson-S1-wps.ipynb"
"Lesson-S2-GIS-pre-processing.ipynb"
"Lesson-S3-regridding.ipynb"
)


# test training notebooks
has_failure=0
for nb in "${training_notebooks[@]}"; do
  notebook_path="${notebook_dir}/${nb}"
  echo "Testing: $notebook_path"
  echo "$ jupyter nbconvert --to notebook --execute --inplace $notebook_path"
  if jupyter nbconvert --to notebook --execute --inplace "$notebook_path"; then
    echo -e "${green}success: $nb${nc}"
  else
    echo -e "${red}failed: $nb${nc}"
    has_failure=1
  fi
done

# test supplemental notebooks
for nb in "${supplemental_notebooks[@]}"; do
  notebook_path="${notebook_dir}/${nb}"
  echo "Testing: $notebook_path"
  echo "$ jupyter nbconvert --to notebook --execute --inplace $notebook_path"
  if jupyter nbconvert --to notebook --execute --inplace "$notebook_path"; then
    echo -e "${green}success: $nb${nc}"
  else
    echo -e "${red}failed: $nb${nc}"
  fi
done

# Final exit
if [ "$has_failure" -eq 1 ]; then
  echo -e "${red}One or more notebooks failed${nc}"
  exit 1
else
  echo -e "${green}All training notebooks executed successfully${nc}"
  exit 0
fi
