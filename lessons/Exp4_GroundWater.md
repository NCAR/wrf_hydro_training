# Groundwater Bucket Model
Aquifer processes contributing baseflow often operate at depths well below ground surface. As such, there are often conceptual shortcomings in current land surface models in their representation of groundwater processes. WRF-Hydro has implemented a conceptual baseflow model, and it is particularly useful when WRF-Hydro is used for long-term streamflow simulation/prediction and baseflow or “low flow” processes must be properly accounted for. For more detailed on the this topic please refer to [WRF-Hydro V5 Technical Description](https://ral.ucar.edu/sites/default/files/public/WRF-HydroV5TechnicalDescription.pdf). Presently, WRF-Hydro uses either a direct output-equals-input "pass-through" relationship or an exponential storage-discharge function for estimating the bucket discharge as a function of a conceptual depth of water in the bucket "exponential bucket". Note that, because this is a highly conceptualized formulation, the depth of water in the bucket in no way infers the actual depth of water in a real aquifer system. However, the volume of water that exists in the bucket needs to be tracked in order to maintain mass conservation. Estimated baseflow discharged from the bucket model is then combined with lateral inflow from overland routing (if active) and input directly into the stream network as channel inflow.

Here, we would like to experiment the impact of turnning the groundwater bucket model on and off and also investigate the two available options of the groundwater bucket model. 

## Setting up a run directory
The only required change for this experiment is to turn off the terrain routing switch in the hydro.namelist. We can copy the template run directory for starter.
```
cp -r ~/wrf-hydro-training/output/lesson4/run_gridded_template ~/wrf-hydro-training/output/lesson4/noGWRouting
```

cp -r ~/wrf-hydro-training/output/lesson4/run_gridded_template ~/wrf-hydro-training/output/lesson4/passThroughGWRouting

## Turning off the groundwater routing
There are few peices in the hydro.namelist which are related to the groundwater flow routing. First thing is a switch to turn the overland flow routing on and off. For this experiment, let's set the OVRTSWCRT to zero which means there will not be any terrain routing in the run.

```
! Switch to activate baseflow bucket model...(0=none, 1=exp. bucket, 2=pass-through)
GWBASESWCRT = 0
```

Run the simulation
Now that we have constructed our simulation directory, we can run our simulation.
```
cd ~/wrf-hydro-training/output/lesson4/noGWRouting
mpirun -np 4 ./wrf_hydro.exe >> run.log 2>&1
```



```
! Switch to activate baseflow bucket model...(0=none, 1=exp. bucket, 2=pass-through)
GWBASESWCRT = 2
```

Run the simulation
Now that we have constructed our simulation directory, we can run our simulation.
```
cd ~/wrf-hydro-training/output/lesson4/passThroughGWRouting
mpirun -np 4 ./wrf_hydro.exe >> run.log 2>&1
```

hydro.namelist:
● GWBASESWCRT - Switch to activate groundwater bucket module.
● GWBUCKPARM_file - Path to groundwater bucket parameter file.
● gwbasmskfil (optional) - Path to netcdf groundwater basin mask file if using an explicit
groundwater basin 2d grid.
● UDMP_OPT (optional) - Switch to activate user-defined mapping between land surface model
grid and conceptual basins.
● udmap_file (optional) - If user-defined mapping is active, path to spatial-weights file.
