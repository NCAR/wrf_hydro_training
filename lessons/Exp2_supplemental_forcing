#Providing supplemental forcing

There are certain times that the user wants to combine atmospheric analyses from reanalysis products or other models with a separate analysis of precipitation (e.g. a gridded gauge product, radar QPE, nowcasts, satellite QPE, etc). To enable such behaviour, the user can change the forcing option to 6 to use supplementary precipiation files.

```
&WRF_HYDRO_OFFLINE

! Specification of forcing data:  1=HRLDAS-hr format, 2=HRLDAS-min format, 3=WRF,
!    4=Idealized, 5=Ideal w/ Spec.Precip., 6=HRLDAS-hrl y fomat w/ Spec. Precip,
FORC_TYP = 1

/
```

If the FORC_TYP is set to 6, the model reads in the meteorological forcing data fields on each hour and then holds those values constant for the entire hour. Precipitation can be read in more frequently based on the user-specified FORCING_TIMESTEP namelist parameter in the namelist.hrldas file. For example, the user can have ‘hourly’ meteorology with ‘5-minute’ precipitation analyses. These supplementary precipitation files are netCDF files containing a single gridded field with either the name “precip” and units of mm or “precip_rate” with unit a unit of mm/s. When using this forcing type, the WRF-Hydro system will look for a new precipitation input file based on the user-specified FORCING_TIMESTEP namelist option set in the namelist.hrldas file. Scripts provided on the WRF-Hydro website will generate files in this format (specifically the MRMS regridding scripts). Here, we have prepared Stage IV data as the supplementary precipitation forcing. 


