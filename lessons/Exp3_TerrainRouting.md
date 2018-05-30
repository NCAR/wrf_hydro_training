# Overland Flow Routing:
Overland flow in WRF-Hydro is calculated using a fully-unsteady, explicit, finite-difference, diffusive wave formulation similar to that of Julien et al. (1995) and Ogden et al. (1997). The diffusive wave equation, while slightly more complicated, is, under some conditions, superior to the simpler and more traditionally used kinematic wave equation, because it accounts for backwater effects and allows for flow on adverse slopes. For more detailed information refer to [WRF-Hydro V5 Technical Description](https://ral.ucar.edu/sites/default/files/public/WRF-HydroV5TechnicalDescription.pdf). Here, we would like to turn the overland flow routing on and off and investigate the imapact of doing so on the streamflow simulations. The baseline run was with overland flow routing on, so we just need to create another run directory and turn off the terrain routing and compare it with the baseline run.

## Setting up a run directory
The only required change for this experiment is to turn off the terrain routing switch in the hydro.namelist. We can copy the template run directory for starter.

```
cp -r ~/wrf-hydro-training/output/lesson4/run_gridded_template ~/wrf-hydro-training/output/lesson4/noTerrainRouting
```

## Turning off the overland flow routing
There are few peices in the hydro.namelist which are related to the overland flow routing. First thing is a switch to turn the overland flow routing on and off. For this experiment, let's set the *OVRTSWCRT* to zero which means there will not be any terrain routing in the run. 
```
! Switch to activate surface overland flow routing...(0=no, 1=yes)
OVRTSWCRT = 0
```
There are four other pieces of information in the hydro.namelist which are related to the overland flow routing. The *DXRT* and *AGGFACTRT* control the relative spatial resolution of the terrain routing grid compared to the land model. The *rt_option* and *DTRT_TER* which specify the type of the terrain routing and  the terrain routing model timestep, repectively. When you user turns off the switch, there is no need to change these options, just leave it as is. 

```
! Specify the grid spacing of the terrain routing grid...(meters)
DXRT = 250.0

! Specify the integer multiple between the land model grid and the terrain routing grid...(integer)
AGGFACTRT = 4

! Specify overland flow routing option: 1=Steepest Descent (D8) 2=CASC2D (not active)
! NOTE: Currently subsurface flow is only steepest descent
rt_option = 1

! Specify the terrain routing model timestep...(seconds)
DTRT_TER = 10
```
## Run the simulation
Now that we have constructed our simulation directory, we can run our simulation.
```bash
cd ~/wrf-hydro-training/output/lesson4/noTerrainRouting
mpirun -np 4 ./wrf_hydro.exe >> run.log 2>&1
```
Check to make sure the run has finished successfully.

## Comparing the streamflow simulations
Let s look at the streamflow simulations with and without the overland flow routing. We list all the CHANOBS files and plot the streamflow time series.

```R
# Plot the streamflow simulation with overland flow routing on and off
library(foreach)

# list the CHANOBS files for the overland flow routing off and read in all the files
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/noTerrainRouting",
                        glob2rx("*CHANOBS*"), full.names = TRUE)
noTerrainR <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("feature_id", "streamflow"))
  a$time <- as.POSIXct(substr(basename(f), 1, 12), format = "%Y%m%d%H%M", tz = "UTC")
  return(a)
}

# list the CHANOBS files for the overland flow routing on and read in all the files
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/run_gridded_baseline/",
                        glob2rx("*CHANOBS*"), 
                        full.names = TRUE)

withTerrainR <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("feature_id", "streamflow"))
  a$time <- as.POSIXct(substr(basename(f), 1, 12), format = "%Y%m%d%H%M", tz = "UTC")
  return(a)
}

# concatenate the two run and plot it
noTerrainR$run <- "No Terrain Routing"
withTerrainR$run <- "With Terrain Routing"
merged <- rbind(noTerrainR, withTerrainR)

library(ggplot2)
ggplot(data = merged) + geom_line(aes(time, streamflow, color = run)) + facet_wrap(~feature_id)
```
The streamflow values without terrain routing are a lot higher than the simulated streamflow with the terrain routing on. The immediate impact of overland flow routing is attenuating the flow and providing enough time to infilterate into ground instead of dumping all the runoff into the main channel stem and routing it there. Therefore, in the absence of the overland flow routing, the streamflow values are considerably higher and it becomes a flashy system. We expect a more realistic streamflow response with the overland flow routing turned on. 
