# Experiment 1: Warm versus cold start. 
When you start the model as a ‘cold start’ (meaning that it is starting with the default values at the very beginning), it takes time for the model to warm up and reach an equilibrium state. For example, consider simulating streamflow values for a stream which has a base flow of at least 10 cms during the year, and you have a ‘cold start’. The default values of the streamflow might be zeros at the start of the modeling. It then takes time for the simulated streamflow within the model to reach the 10 cms. In contrast, a ‘warm start’ is when the model simulation begins with the simulated values of a given time step (starting time step) from a previous run. This eliminates the processing time the model would take to reach an equilibrium state. Depending on which variable of the model you are looking at, the time required to reach to the warm state may differ. For example, groundwater requires a large time period to reach to equilibrium as it has a longer memory compared to other components of the hydrologic model. Refer to this [file](https://ral.ucar.edu/sites/default/files/public/Using%20Restart%20Files%20in%20WRF-Hydro%20Simulations_1.pdf) for more information. It is recommnended to spin up the model always to reach to a realistic state. 

The goal of this experiment is to run the wrf-hydro model under cold start and warm start and examine the differences in the output files. The baseline run we performed was a warm start simulation since we used the restart files in both the namelists. Here we explain how to do a cold start simulation.

## Setting up a cold start run directory
The only changes required for this experiment is to change the namelist.hrldas and hydro.namelist. We can copy the template run directory to star first, and then remove the symb 

```bash
cp -r ~/wrf-hydro-training/output/lesson4/run_gridded_template ~/wrf-hydro-training/output/lesson4/cold_start
```
## Commenting out the RESTART files in the namelists
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

### Joe needs to change this part to python:
```R
# plot the warm start vs the cold start
library(foreach)

# list the cold start CHANOBS files and read in all the files
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/cold_start",
                        glob2rx("*CHANOBS*"), 
                        full.names = TRUE)
coldStart <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("time", "reference_time"), 
                              exclude = TRUE)
  a$time <- rwrfhydro::GetNcdfFile(f, variables = c("time"))$time
  return(a)
}

# list the warm start CHANOBS files and read in all the files
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/run_gridded_baseline/",
                        glob2rx("*CHANOBS*"), 
                        full.names = TRUE)

warmStart <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("time", "reference_time"), 
                              exclude = TRUE)
  a$time <- rwrfhydro::GetNcdfFile(f, variables = c("time"))$time
  return(a)
}

# concatenate the cold and warm start and compare it together and then plot it
coldStart$run <- "ColdStart"
warmStart$run <- "warmStart"
merged <- rbind(coldStart, warmStart)
library(ggplot2)
ggplot(data = merged) + geom_line(aes(time, streamflow, color = run)) + facet_wrap(~feature_id)
```
Now lets investigate why do we see this difference between the two. There is one option in the hydro.namelist to output the starting state of the simulation which was set to 1 at the two model simulations. This allows us to compare the two runs at the initial time step.

```
! Option to write output files at time 0 (restart cold start time): 0=no, 1=yes (default)
t0OutputFlag = 1
```

Note that in the above hydrographs the streamflow for the cold start run is zero while in the warm start run the streams are not empty. Now let s take a look at the soil moisture content at the inirial time step as one of the important state variabels impacting the streamflow values. 

```R
# Read the soil moisture content at the start of the cold start run, and convert it to a data.frame
coldStartS <- rwrfhydro::GetNcdfFile("~/wrf-hydro-training/output/lesson4/cold_start/201108260000.LDASOUT_DOMAIN1",
                                     variables = "SOIL_M", quiet = TRUE)$SOIL_M
coldStartS_df <- data.frame(soilM = c(coldStartS), 
                            x = rep(1:dim(coldStartS)[1], dim(coldStartS)[2]*dim(coldStartS)[3]), 
                            soilColumn = rep(rep(1:dim(coldStartS)[2], each = dim(coldStartS)[1]), dim(coldStartS)[3]),
                            y = rep(1:dim(coldStartS)[3], each = dim(coldStartS)[1]*dim(coldStartS)[2]))
coldStartS_df$run <- "Cold Start"

# Read the soil moisture content at the start of the warm start run, and convert it to a data.frame
warmStartS <- rwrfhydro::GetNcdfFile("~/wrf-hydro-training/output/lesson4/run_gridded_baseline/201108260000.LDASOUT_DOMAIN1", 
                                     variables = "SOIL_M", quiet = TRUE)$SOIL_M
warmStartS_df <- data.frame(soilM = c(warmStartS), 
           x = rep(1:dim(warmStartS)[1], dim(warmStartS)[2]*dim(warmStartS)[3]), 
           soilColumn = rep(rep(1:dim(warmStartS)[2], each = dim(warmStartS)[1]), dim(warmStartS)[3]),
           y = rep(1:dim(warmStartS)[3], each = dim(warmStartS)[1]*dim(warmStartS)[2]))
warmStartS_df$run <- "Warm Start"

# concatenate the two runs
merged <- rbind(coldStartS_df, warmStartS_df)

# Plot the soil moiture state at the start of the run between the two runs
library(ggplot2)
ggplot(data = merged, aes(x = x, y = y)) + 
  geom_raster(aes(fill = soilM)) + facet_grid(soilColumn~run) 
  ```
  As you would see in this plot, for the cold start the soil is almost dry while for the warm start run, there is considerable amount of water in soil. As a result they have different response to the rainfall event and in the cold start run. Since the soil is dry, it has a higher capacity to store water and therefore it does not run off. This experiments is just to emphasize on the impact of a spin up for any simulation, here WRF-Hydro simulations. 
