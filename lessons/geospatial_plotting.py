"""
Functions used to run the geospatial plotting for the WRF-Hydro Training Jupyter Notebooks
"""

# Import python core modules
import os
import warnings
warnings.filterwarnings("ignore")

# Import additional libraries
import xarray as xr
import netCDF4
import numpy as np
import matplotlib
from matplotlib import pyplot
import ipywidgets as widgets

# Set paths to known input and output directories and files
geogrid = '~/DOMAIN/geo_em.d0x.nc'
fulldom = '~/DOMAIN/Fulldom_hires.nc'
wrfinput = '~/DOMAIN/wrfinput_d0x.nc'
soil_properties = '~/DOMAIN/soil_properties.nc'
hydro2D = '~/DOMAIN/hydro2dtbl.nc'
routelink = '~/DOMAIN/Route_Link.nc'

def cmap_options(var_name):
    '''
    Define various color ramps for certain gridded variables.
    Includes variables from geo_em, wrfinput, and fulldom_hires
    '''
    # Default plot options
    cmap = pyplot.get_cmap('Blues')
    norm = None

    var_name = var_name.lower()
    if var_name in ['latitude', 
                    'longitude', 
                    'channelgrid', 
                    'frxst_pts', 
                    'xlat_m', 
                    'xlong_m', 
                    'clat', 
                    'clong', 
                    'cosalpha', 
                    'e', 
                    'f', 
                    'landmask',
                    'sinalpha',
                    'xlat',
                    'xlong',
                   'albedo12m']:
        #cmap = 'binary'
        cmap = pyplot.get_cmap('binary')
    elif var_name in ['topography', 
                      'hgt_m',
                      'hgt']:
        #cmap = 'BrBG'  # 'gist_earth'
        cmap = pyplot.get_cmap('BrBG')
    elif var_name in ['lai12m', 'lai', 'greenfrac']:
        cmap = pyplot.get_cmap('Greens')
    elif var_name in ['flowdirection']:
        colors = ['#ff0000', '#5959a6', '#806c93', '#a65959', '#a68659', '#a6a659', '#93a659', '#669966', '#669988',
                  '#999999']
        scale = [0, 1, 2, 4, 8, 16, 32, 64, 128, 255]
        cmap = matplotlib.colors.ListedColormap(colors)
        norm = matplotlib.colors.BoundaryNorm(scale, len(colors))
    elif var_name in ['landuse', 
                      'lu_index',
                      'ivgtyp']:
        colors = ['#ed0000', '#dbd83d', '#aa7028', '#fbf65d', '#e2e2c1', '#ccba7c', '#dcca8f', '#fde9aa', '#68aa63',
                  '#85c724', '#38814e', '#1c6330', '#b5c98e', '#476ba0', '#70a3ba', '#bad8ea', '#b2ada3', '#c9c977',
                  '#a58c30', '#d1ddf9']
        scale = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23]
        cmap = matplotlib.colors.ListedColormap(colors)
        norm = matplotlib.colors.BoundaryNorm(scale, len(colors))
    elif var_name in ['streamorder']:
        colors = ['blue', 'green', 'red', 'yellow', '#000000']
        scale = [.9, 1.9, 2.9, 3.9, 4]
        #         scale = [1, 2, 3, 4, 5]
        cmap = matplotlib.colors.ListedColormap(colors)
        norm = matplotlib.colors.BoundaryNorm(scale, len(colors))
    elif var_name in ['impervfrac', 'imperv']:
        cmap = pyplot.get_cmap('Reds')
    return cmap, norm

def drop_down(opt_list, default_val):
    drop_input = widgets.Dropdown(options=opt_list,
                                value=default_val,
                                description='Variable:')
    return drop_input
        
def populate_dropdown(file_type='geogrid', default_val='HGT_M'):
    # Populate the drop-down menu
    if file_type == 'geogrid':
        ds = xr.open_dataset(geogrid)
        drop_opts = [(item, item) for item in ds.data_vars if 'south_north' in ds[item].dims and 'west_east' in ds[item].dims]
    elif file_type == 'fulldom':
        ds = xr.open_dataset(fulldom)
        drop_opts = [(item, item) for item in ds.data_vars if 'y' in ds[item].dims or 'x' in ds[item].dims]
    elif file_type == 'wrfinput':
        ds = xr.open_dataset(wrfinput)
        drop_opts = [(item, item) for item in ds.data_vars if 'south_north' in ds[item].dims and 'west_east' in ds[item].dims]
    elif file_type == 'soil_properties':
        ds = xr.open_dataset(soil_properties)
        drop_opts = [(item, item) for item in ds.data_vars if 'south_north' in ds[item].dims or 'west_east' in ds[item].dims]
    elif file_type == 'hydro2D':
        ds = xr.open_dataset(hydro2D)
        drop_opts = [(item, item) for item in ds.data_vars if 'south_north' in ds[item].dims or 'west_east' in ds[item].dims]
    elif file_type == 'routelink':
        ds = xr.open_dataset(routelink)
        drop_opts = [(item, item) for item in ds.data_vars if 'feature_id' in ds[item].dims]
    return drop_down(drop_opts, default_val)

def see_grid(ds, x, file_type='geogrid'): 
    if file_type in ['hydro2D', 'fulldom']:
        src = ds[x].data
    elif len(ds[x].dims) > 3:
        print('Found more than 2 dimensions. Selecting first level from dimension {0}'.format(ds[x].dims[1]))
        src = ds[x].data.squeeze()
        src = src[0]
    elif len(ds[x].dims) <= 3:
        src = ds[x].data.squeeze()
        
    # Flip south-north
    if file_type in ['geogrid', 'hydro2D', 'soil_properties', 'wrfinput']:
        src = src[::-1]
        
    cmap, norm = cmap_options(x)
    if x in ['HGT_M', 'HGT', 'TOPOGRAPHY']:
        pyplot.imshow(src, cmap=cmap,  aspect='auto', norm=norm, interpolation='nearest', vmin=src.min(), vmax=src.max())
    else:
        pyplot.imshow(src, cmap=cmap,  aspect='auto', norm=norm, interpolation='nearest')
    cbar = pyplot.colorbar(label='{0} ({1})'.format(x, ds[x].attrs.get('units', '?')))
    
    # Keep the automatic aspect while scaling the image up in size
    fig = pyplot.gcf()
    fig.suptitle(ds[x].attrs.get('description', ''), fontsize=12)
    w, h = fig.get_size_inches()
    fig.set_size_inches(w * 2.0, h * 2.0)
    
    # Show image
    pyplot.show() 
    
def see_geogrid(x):
    ds = xr.open_dataset(geogrid)
    see_grid(ds, x, file_type='geogrid')

def see_wrfinput(x):
    ds = xr.open_dataset(wrfinput)
    see_grid(ds, x, file_type='wrfinput')

def see_soil_properties(x):
    ds = xr.open_dataset(soil_properties)
    see_grid(ds, x, file_type='soil_properties')
    
def see_hydro2D(x):
    ds = xr.open_dataset(hydro2D)
    see_grid(ds, x, file_type='hydro2D')

def see_fulldom(x):
    ds = xr.open_dataset(fulldom)
    see_grid(ds, x, file_type='fulldom')

def see_routelink(x):
    ds = xr.open_dataset(routelink)   
    fig, ax = pyplot.subplots(figsize=(15, 12))
    kwargs = {}
    if x.lower() in ['alt']:
        cmap = 'terrain'
        kwargs['vmin'] = 0.0
    else:
        cmap = 'viridis'

    # Alter plot marker size
    if x.lower() in ['btmwdth', 'topwdth', 'topwdthcc']:
        kwargs['s'] = [n for n in ds['TopWdth'].data]
    else:
        kwargs['s'] = 2
    return xr.plot.scatter(ds, x='lon', y='lat', hue=x, ax=ax, cmap=cmap, **kwargs)

def visualize_weights(in_nc, basinID=1, nrows=1, ncols=1, spatialweight=True, regridweight=False, trimRaster=False):
    '''
    Plot the weight grid from a WRF-Hydro spatial weight file.
    '''
    assert os.path.exists(in_nc)

    # Find if the spatial weights sum to 1
    rootgrp = netCDF4.Dataset(in_nc, 'r', format='NETCDF4_CLASSIC')                         # 'NETCDF4'

    # Get the variable
    IDmask_arr = rootgrp.variables['IDmask'][:]
    i_index_arr = rootgrp.variables['i_index'][:]
    j_index_arr = rootgrp.variables['j_index'][:]

    # Read weights and IDs into arrays
    if spatialweight:
        weights_arr = rootgrp.variables['weight'][:]
    elif regridweight:
        weights_arr = rootgrp.variables['regridweight'][:]

    # Build empty raster to store weights
    weight_grid = np.zeros((ncols, nrows), dtype='f4')

    # Mask the array to just this basin ID
    basin_mask = IDmask_arr==basinID

    i_index_arr_masked = i_index_arr[basin_mask]-1
    j_index_arr_masked = j_index_arr[basin_mask]-1
    for weight,i,j in zip(weights_arr[basin_mask], i_index_arr_masked, j_index_arr_masked):
        weight_grid[i,j] = weight

    # Flip the y axis because NWM grid is south-north
    weight_grid = np.flip(weight_grid, axis=1)

    # Transpose so that order is y,x
    weight_grid = weight_grid.transpose()

    if trimRaster:
        # Find the new indices on the flipped and transposed grid.
        # Y should be the only one that is different
        y_min_new = (nrows-1)-j_index_arr_masked.min()
        y_max_new = (nrows-1)-j_index_arr_masked.max()
        x_min_new = i_index_arr_masked.min()
        x_max_new = i_index_arr_masked.max()
        weight_grid = weight_grid[y_max_new:y_min_new+1, x_min_new:x_max_new+1]
        
    # Set values of 0 to nodata so they wont show
    weight_grid[weight_grid == 0.0] = np.nan
    
    cmap = matplotlib.cm.Reds
    cmap.set_bad('lightgrey')
    
    # Setup plot
    pyplot.imshow(weight_grid, cmap=cmap,  aspect='auto', interpolation='nearest', vmin=0.00000001)
    cbar = pyplot.colorbar()

    # Keep the automatic aspect while scaling the image up in size
    fig = pyplot.gcf()
    fig.suptitle('Gridded Spatial Weights for basin {0}'.format(basinID), fontsize=12)
    w, h = fig.get_size_inches()
    fig.set_size_inches(w * 2.0, h * 2.0)

    # Show image
    pyplot.show()