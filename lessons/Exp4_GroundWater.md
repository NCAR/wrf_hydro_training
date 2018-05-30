# Groundwater Bucket Model
Aquifer processes contributing baseflow often operate at depths well below ground surface. As such, there are often conceptual shortcomings in current land surface models in their representation of groundwater processes. WRF-Hydro has implemented a conceptual baseflow model, and it is particularly useful when WRF-Hydro is used for long-term streamflow simulation/prediction and baseflow or “low flow” processes must be properly accounted for. For more detailed on the this topic please refer to [WRF-Hydro V5 Technical Description](https://ral.ucar.edu/sites/default/files/public/WRF-HydroV5TechnicalDescription.pdf). Presently, WRF-Hydro uses either a direct output-equals-input "pass-through" relationship or an exponential storage-discharge function for estimating the bucket discharge as a function of a conceptual depth of water in the bucket "exponential bucket". Note that, because this is a highly conceptualized formulation, the depth of water in the bucket in no way infers the actual depth of water in a real aquifer system. However, the volume of water that exists in the bucket needs to be tracked in order to maintain mass conservation. Estimated baseflow discharged from the bucket model is then combined with lateral inflow from overland routing (if active) and input directly into the stream network as channel inflow.

Here, we would like to experiment the impact of turnning the groundwater bucket model on and off and also investigate the two available options of the groundwater bucket model. 

## Setting up the run with no groundwater routing
The groundwater option gets set using **GWBASESWCRT** option in the hydro.namelist. The only required change for this experiment is to set **GWBASESWCRT** to 0 in the hydro.namelist. Lets copy the template directory.

```
cp -r ~/wrf-hydro-training/output/lesson4/run_gridded_template ~/wrf-hydro-training/output/lesson4/noGWRouting
```

Set the groundwater bucket model option to zero in the hydro.namelist.

```
! Switch to activate baseflow bucket model...(0=none, 1=exp. bucket, 2=pass-through)
GWBASESWCRT = 0
```

Now that we have constructed our simulation directory and we made proper changes to the namelist, we can run our simulation.

```
cd ~/wrf-hydro-training/output/lesson4/noGWRouting
mpirun -np 4 ./wrf_hydro.exe >> run.log 2>&1
```
Make sure the run finished successfully.

## setting up the run with groundwater routing with pass-through option

Let s firt copy the template directory.

```
cp -r ~/wrf-hydro-training/output/lesson4/run_gridded_template ~/wrf-hydro-training/output/lesson4/passThroughGWRouting
```

set the **GWBASESWCRT** to 2 for the pass-through option in the hydro.namelist.

```
! Switch to activate baseflow bucket model...(0=none, 1=exp. bucket, 2=pass-through)
GWBASESWCRT = 2
```

Now run the simulation.

```
cd ~/wrf-hydro-training/output/lesson4/passThroughGWRouting
mpirun -np 4 ./wrf_hydro.exe >> run.log 2>&1
```
## Comparing streamflow simulations with different groundwater options

Lets plot the streamflow simulations with different groundwater options, along with the observed streamflow.
```R
# read the obs files
obs <- read.csv("~/wrf-hydro-training/example_case/USGS_obs.csv")
metadata <- read.csv("~/wrf-hydro-training/example_case/Gridded/croton_frxst_pts_csv")
obs <- merge(obs,  metadata, by.x = "site_no", by.y = "Site_No")
names(obs) <- c("site_no", "time", "streamflow", "feature_id", "LON", "LAT", "STATION")

library(foreach)

# list the CHANOBS files for the groundwater model off and read in all the files
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/noGWRouting",
                        glob2rx("*CHANOBS*"), full.names = TRUE)
noGW <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("feature_id", "streamflow"), quiet = TRUE)
  a$time <- as.POSIXct(substr(basename(f), 1, 12), format = "%Y%m%d%H%M", tz = "UTC")
  return(a)
}

# list the CHANOBS files for the groundwater model set to pass-through and read in all the files
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/passThroughGWRouting/",
                        glob2rx("*CHANOBS*"), full.names = TRUE)

GW_passThrough <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("feature_id", "streamflow"), quiet = TRUE)
  a$time <- as.POSIXct(substr(basename(f), 1, 12), format = "%Y%m%d%H%M", tz = "UTC")
  return(a)
}


# list the CHANOBS files for the groundwater model set to exponential and read in all the files
chrtFiles <- list.files("/glade2/scratch2/arezoo/wrf-hydro-training/output/lesson4/run_gridded_baseline/",
                        glob2rx("*CHANOBS*"), full.names = TRUE)

GW_Exp <- foreach(f = chrtFiles, .combine = rbind.data.frame) %do% {
  a <- rwrfhydro::GetNcdfFile(f, variables = c("feature_id", "streamflow"), quiet = TRUE)
  a$time <- as.POSIXct(substr(basename(f), 1, 12), format = "%Y%m%d%H%M", tz = "UTC")
  return(a)
}

# concatenate the two run and plot it
noGW$run <- "No Groundwater Routing"
GW_passThrough$run <- "With pass through GW Routing"
GW_Exp$run <- "With exponential GW routing"
obs$run <- "Observation"

merged <- rbind(noGW, GW_passThrough, GW_Exp, obs[, names(noGW)])

library(ggplot2)
ggplot(data = merged) + geom_line(aes(time, streamflow, color = run)) + facet_wrap(~feature_id)
```


hydro.namelist:
● GWBASESWCRT - Switch to activate groundwater bucket module.
● GWBUCKPARM_file - Path to groundwater bucket parameter file.
● gwbasmskfil (optional) - Path to netcdf groundwater basin mask file if using an explicit
groundwater basin 2d grid.
● UDMP_OPT (optional) - Switch to activate user-defined mapping between land surface model
grid and conceptual basins.
● udmap_file (optional) - If user-defined mapping is active, path to spatial-weights file.
