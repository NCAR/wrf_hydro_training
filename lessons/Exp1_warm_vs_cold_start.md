The goal of this lesson is to run the wrf-hydro model under cold start and warm start and examine the differences in the output files.

for this experiment we use the gridded routing option. 

# Setting up a warm start run
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

## Step 4. Copy namelist files

Because we are using the default prepared namelists from the example WRF-Hydro domain, we will copy those in as well. If you were using your own namelists, they would likely be edited and copied from elsewhere. These are simple text files so we will make actual copies rather than symbolic links.

```bash
cp ~/wrf-hydro-training/example_case/Gridded/namelist.hrldas \
~/wrf-hydro-training/output/lesson4/cold_start

cp ~/wrf-hydro-training/example_case/Gridded/hydro.namelist \
~/wrf-hydro-training/output/lesson4/cold_start

ls ~/wrf-hydro-training/output/lesson4/cold_start | tail -40
```
## Step 5. Running WRF-Hydro using default run-time options
Now that we have constructed our simulation directory, we can run our simulation. For this we will be using the mpi run command, which has a number of arguments. For this simple case, we only need to supply one argument, the number of cores. This is done with the -np argument, and we will set it to 4 cores.

Because running a simulation can generate a lot of standard output, we will pipe the output to a log file.

```bash
cd ~/wrf-hydro-training/output/lesson4/cold_start
mpirun -np 4 ./wrf_hydro.exe >> run.log 2>&1
```
If your simulation ran successfully, there should now be a large number of output files in the ~/wrf-hydro-training/output/lesson4/cold_start. We will cover what each of these files are in more depth in Lesson 4. Additionally, detailed descriptions of the output files can be found in the Technical Description.

