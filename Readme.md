#  WRF-Hydro <img src="https://ral.ucar.edu/sites/default/files/public/wrf_hydro_symbol_logo_2017_09_150pxby63px.png" width=100 align="left" />

## Overview
This repository contains lessons in understanding the basic functionality of WRF-Hydro as used in the National Water Model (NWM).

### Requirements
The easiest and recommended way to run these lessons is via the [wrfhydro/nwm-training](https://cloud.docker.com/u/wrfhydro/repository/docker/wrfhydro/nwm-training) Docker container, which has all software dependencies and data pre-installed.

* Docker >= v.17.12
* Web browser (Google Chrome recommended)

### Where to get help and/or post issues
If you have general questions about Docker, there are ample online resourves including the excellent Docker documentation at https://docs.docker.com/.

If you have questions about WRF-Hydro or these lessons please use the contact form on our website: https://ral.ucar.edu/projects/wrf_hydro/contact. 

If you have found a bug in these lessons please log an issue on the Issues page of the GitHub repository at https://github.com/NCAR/wrf_hydro_training/issues.


## How to run
Make sure you have Docker installed and that it can access your localhost ports. Most out-of-the-box Docker installations accepting all defaults will have this configuration.

**Step 1: Open a terminal or PowerShell session**

**Step 2: Pull the wrfhydro/nwm-training Docker container for the desired version**

Issue the following command in your terminal to pull a specific version of the training. In this example, we will pull the training container for v2.0.

`docker pull wrfhydro/nwm-training:v2.0`

**Step 3: Start the training container**

Issue the following commnand in your terminal session to start the training Docker container.

`docker run --name nwm-training -p 8888:8888 -it wrfhydro/nwm-training:v2.0`

The container will start and perform a number of actions before starting the training. 

**Note:** If you have already started the training once you will need to remove the previous container using the command `docker rm nwm-training`

**Step 4: Connect to Jupyter Notebook server using your browser**

At the end of the container startup process an address and password will be printed to the terminal. The address and password are used to connect to the container Jupyter Notebook server. All training lesson notebooks in this container are in the `/home/docker/nwm-training/lessons` directory and can be opened in your browser using Jupyter.

## What is included

* The model code corresponding to the specified version, in this case v2.0
* An example test case compatible with the included model code
* WRF-Hydro training lessons as Jupyter Notebooks
* Jupyter Notebook server

**Note:** Port forwarding is setup with the `-p 8888:8888` argument, which maps your localhost port to the container port. If you already have something running on port 8888 on your localhost you will need to change this number
