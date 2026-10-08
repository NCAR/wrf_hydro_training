# Input processing and preparation for WRF-Hydro/MODFLOW coupling model set up.

This repository contains three Jupyter Notebooks that process and prepare WRF-Hydro and MODFLOW model inputs to be used for a coupled simulation.
See WRF-Hydro documentation [A20. Introduction to the Basic Model Interface (BMI)](https://wrf-hydro.readthedocs.io/en/latest/appendices.html#a20-introduction-to-the-basic-model-interface-bmi) for more detail.

## Notebooks

1. **`nb01v01_wrfhydro_cutout_wps_wrfgeogrid.ipynb`**
   Preparing and generating the WRF-Hydro domain and input files.

2. **`nb02v01_modflow_cutout_reproj2wrfhydro.ipynb`**
   Preparing and generating the MODFLOW domain and input files. Adding projection.

3. **`nb03v01_modflow_cutout_addmodflowPacks.ipynb`**
   Preparing and generating the MODFLOW domain and input files. Adding modflow packages.
