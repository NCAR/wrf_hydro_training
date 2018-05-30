
Aquifer processes contributing baseflow often operate at depths well below ground surface. As such, there are often conceptual shortcomings in current land surface models in their representation of groundwater processes. WRF-Hydro has implemented a conceptual baseflow model, and it is particularly useful when WRF-Hydro is used for long-term streamflow simulation/prediction and baseflow or “low flow” processes must be properly accounted for. For more detailed on the this topic please refer to [WRF-Hydro V5 Technical Description](https://ral.ucar.edu/sites/default/files/public/WRF-HydroV5TechnicalDescription.pdf). 



hydro.namelist:
● GWBASESWCRT - Switch to activate groundwater bucket module.
● GWBUCKPARM_file - Path to groundwater bucket parameter file.
● gwbasmskfil (optional) - Path to netcdf groundwater basin mask file if using an explicit
groundwater basin 2d grid.
● UDMP_OPT (optional) - Switch to activate user-defined mapping between land surface model
grid and conceptual basins.
● udmap_file (optional) - If user-defined mapping is active, path to spatial-weights file.
