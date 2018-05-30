# Overland Flow Routing:
Overland flow in WRF-Hydro is calculated using a fully-unsteady, explicit, finite-difference, diffusive wave formulation similar to that of Julien et al. (1995) and Ogden et al. (1997). The diffusive wave equation, while slightly more complicated, is, under some conditions, superior to the simpler and more traditionally used kinematic wave equation, because it accounts for backwater effects and allows for flow on adverse slopes. For more detailed information refer to [WRF-Hydro V5 Technical Description](https://ral.ucar.edu/sites/default/files/public/WRF-HydroV5TechnicalDescription.pdf). Here, we would like to turn the overland flow routing on and off and investigate the imapact of doing so on the streamflow simulations. The baseline run was with overland flow routing on, so we just need to create another run directory and turn off the terrain routing.

## Setting up a run directory
The only changes required for this experiment is to change the namelist.hrldas and hydro.namelist. We can copy the template run directory to star first, and then remove the symb

```
cp -r ~/wrf-hydro-training/output/lesson4/run_gridded_template ~/wrf-hydro-training/output/lesson4/noTerrainRouting
```

## Turning off the overland flow routing
There are few peices in the hydro.namelist which are related to the overland flow routing. First thing is a switch to turn the overland flow routing on and off. For this experiment, let s set the *OVRTSWCRT* to zero which means there will not be any terrain routing in the run. 
```
! Switch to activate surface overland flow routing...(0=no, 1=yes)
OVRTSWCRT = 0
```
There are two other piece of information in the hydro.namelist which are related to the overland flow routing, the *rt_option* and *DTRT_TER* which specify the type of the terrain routing and  the terrain routing model timestep, repectively. When you user turns off the switch, there is no need to change these options, just leave it as is. 

```
! Specify overland flow routing option: 1=Steepest Descent (D8) 2=CASC2D (not active)
! NOTE: Currently subsurface flow is only steepest descent
rt_option = 1

! Specify the terrain routing model timestep...(seconds)
DTRT_TER = 10
```





