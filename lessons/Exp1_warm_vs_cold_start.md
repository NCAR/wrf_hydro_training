# Experiment 1: Warm versus cold start. 
The goal of this lesson is to run the wrf-hydro model under cold start and warm start and examine the differences in the output files. The baseline run we performed was a warm start simulation since we used the restart files in both the namelists. Here we explain how to do a cold start simulation.

## Setting up a cold start run directory
The only changes required for this experiment is to change the namelist.hrldas and hydro.namelist. Therefore, we can copy the baseline run directory to start. Notice that for this experiment, you do not copy the RESTART directory.

```bash
# Make a new directory for our baseline simulation
mkdir -p ~/wrf-hydro-training/output/lesson4/cold_start

# Copy our model files to the simulation directory
cp ~/wrf-hydro-training/wrf_hydro_nwm_public/trunk/NDHMS/Run/*.TBL \
~/wrf-hydro-training/output/lesson4/cold_start
cp ~/wrf-hydro-training/wrf_hydro_nwm_public/trunk/NDHMS/Run/wrf_hydro.exe \
~/wrf-hydro-training/output/lesson4/cold_start

# Create symbolic links to large domain files
cp -as $HOME/wrf-hydro-training/example_case/FORCING \
~/wrf-hydro-training/output/lesson4/cold_start
cp -as $HOME/wrf-hydro-training/example_case/Gridded/DOMAIN \
~/wrf-hydro-training/output/lesson4/cold_start

# Copy namelist files
cp ~/wrf-hydro-training/example_case/Gridded/namelist.hrldas \
~/wrf-hydro-training/output/lesson4/cold_start
cp ~/wrf-hydro-training/example_case/Gridded/hydro.namelist \
~/wrf-hydro-training/output/lesson4/cold_start
```
## Commenting out the RESTART files in the namelists to have a cold start simulation

If one does not provide restart files in the namelist, the simulation would be a cold start. To do that make the following changes in the namelists. 
1.	Comment out this line **RESTART_FILENAME_REQUESTED = "RESTART/RESTART.2011082600_DOMAIN1"** in the namelist.hrldas by adding “!” to the start of the line. 
1.	Comment out this line **RESTART_FILE  = 'RESTART/HYDRO_RST.2011-08-26_00_00_DOMAIN1'** in the hydro.namelist by adding “!” to the start of the line. 

## Run the cold start simulation
Now that we have constructed our simulation directory, we can run our simulation. 
```
cd ~/wrf-hydro-training/output/lesson4/cold_start
mpirun -np 4 ./wrf_hydro.exe >> run.log 2>&1
```
If your simulation ran successfully, there should now be a large number of output files in the ~/wrf-hydro-training/output/lesson4/cold_start. 

# Comparison of the cold versus warm start
Now it is time to compare the result of the two runs in this experiments together. Let s take a look at the streamflow time series. Open the chanobs multi-file dataset We are going to use the *CHANOBS* files because it will limit the number of grid cells to only those which we have specified have a gage. 

NOTE: open_mfdataset supports wildcards for pattern matching but requires that the path be absolute with no tilde

We will use wildcards * to open all files that contain 'CHANOBS' in the name.

**NOTE: Because we are opening multiple files, we need to tell xarray how to concatenate them. Because this is a timeseries with time dimension called 'time' we will specify 'time' as the concatenation dimension.

