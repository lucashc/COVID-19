# COVID-19
Modelling of pandemics using EpiModel
We use the data from the german RKI

# Features
The features supported are:
* Exploration of RGG's as the infection spreads
  * Multi-core support
  * History recording
  * Graph diagnostics such as average degree and average distance over time
  * Persistent storage of result objects
  * Rich printing of returned objects
* Geographical sampling of initial infections by the use of population density data
* Heatmap of simulation, even through time

# How to run?
First of all install the required R packages. This can be done by running `install.R`, which installs the required packages. On Windows this should pull other binary dependencies, but for UNIX like systems, one should install at least: `gcc`, `gcc-fortran` and `gdal` to build them on demand.

The main code for RGG's is contained in the `scripts/RGG` folder. To run a scenario, head over to the `scripts/scenarios`-directory. Here one can run a simulation by using an RGG. See an example for the paremeters that can be set. In addition, the software supports multi-core machines by way of forking. This greatly improves simulations. However, this is only available on UNIX like systems, as Windows does not offer such a kernel call. For 8 concurrent processes at 1 million nodes it is advised to have 16 GB of RAM. 
