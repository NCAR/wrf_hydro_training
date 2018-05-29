# Experiment 1: Warm versus cold start. 
The goal of this lesson is to run the wrf-hydro model under cold start and warm start and examine the differences in the output files. The baseline run we performed was a warm start simulation since we used the restart files in both the namelists. Here we explain how to do a cold start simulation.

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
# plot the warm start vs the cold start

# list the cold start CHRTOUT files
```R 
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/cold_start",
                        glob2rx("*CHANOBS*"), 
                        full.names = TRUE)

library(foreach)
coldStart <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("time", "reference_time"), 
                              exclude = TRUE)
  a$time <- rwrfhydro::GetNcdfFile(f, variables = c("time"))$time
 # return(subset(a, feature_id %in% rtlink$link))
  return(a)
}

# list the warm start CHRTOUT files
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/run_gridded_baseline/",
                        glob2rx("*CHANOBS*"), 
                        full.names = TRUE)

warmStart <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("time", "reference_time"), 
                              exclude = TRUE)
  a$time <- rwrfhydro::GetNcdfFile(f, variables = c("time"))$time
  return(a)
}

# merge the cold and warm start and compare it together:
coldStart$run <- "ColdStart"
warmStart$run <- "warmStart"
merged <- rbind(coldStart, warmStart)
library(ggplot2)
ggplot(data = merged) + geom_line(aes(time, streamflow, color = run)) + facet_wrap(~feature_id)
```

