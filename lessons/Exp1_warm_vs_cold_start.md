The goal of this lesson is to run the wrf-hydro model under cold start and warm start and examine the differences in the output files.

## Step 1. Create simulation directory

We will create a directory for our simulation

```bash
mkdir -p ~/wrf-hydro-training/output/lesson4/cold_start
ls ~/wrf-hydro-training/output/lesson4/
```
## Step 2. Copy model files

We will copy the required model files from the ~/wrf-hydro-training/wrf_hydro_nwm_public/trunk/NDHMS/Run directory. These files are small so we will make actual copies rather than symbolic links in this case.

```bash
cp ~/wrf-hydro-training/wrf_hydro_nwm_public/trunk/NDHMS/Run/*.TBL \
~/wrf-hydro-training/output/lesson4/cold_start

cp ~/wrf-hydro-training/wrf_hydro_nwm_public/trunk/NDHMS/Run/wrf_hydro.exe \
~/wrf-hydro-training/output/lesson4/cold_start

ls ~/wrf-hydro-training/output/lesson4/cold_start
```

## Step 3. Copy DOMAIN files

We will copy the required domain files from the ~/wrf-hydro-training/DOMAIN/Gridded directory. These files can be large so we will make symbolic links rather than copying the actual files. NOTE: Because we are using symbolic links, the paths MUST be absolute and can't use ~

```bash
cp -as $HOME/wrf-hydro-training/example_case/FORCING \
~/wrf-hydro-training/output/lesson4/cold_start

cp -as $HOME/wrf-hydro-training/example_case/Gridded/DOMAIN \
~/wrf-hydro-training/output/lesson4/cold_start

cp -as $HOME/wrf-hydro-training/example_case/Gridded/RESTART \
~/wrf-hydro-training/output/lesson4/cold_start

ls ~/wrf-hydro-training/output/lesson4/cold_start
```

