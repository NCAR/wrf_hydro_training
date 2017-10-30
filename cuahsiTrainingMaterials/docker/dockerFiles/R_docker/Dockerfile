FROM rocker/verse:3.4.0
MAINTAINER jmills@ucar.edu
####################################
###Once running R-studio can be accessed using browser and navigating to localhost:8787
###Make sure to map the port on local host to the container using -p 8787:8787
###For example, docker run --name rwrfhydro -d -p 8787:8787 -v /Volumes/d1/jmills/cuahsiTrainingMaterials:/home/rstudio/cuahsiTrainingMaterials rwrfhydro

####################################
########## ROOT USER  ##############
####################################
#Install system dependencies for rwrfhydro
RUN apt-get update
RUN apt-get install -yq --no-install-recommends \
    wget \
    libhdf5-dev \
    nco \
    m4 \
	libgdal-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
#For ggmap
RUN apt-get install libjpeg-dev 

#For ncdf4
# install netcdf-C
RUN wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.1.tar.gz -P /tmp  
RUN tar -xf /tmp/netcdf-4.4.1.1.tar.gz -C /tmp
ENV H5DIR=/usr/lib/x86_64-linux-gnu/hdf5/serial
ENV NCDIR=/usr/local
RUN cd /tmp/netcdf-4.4.1.1 && CPPFLAGS=-I${H5DIR}/include LDFLAGS=-L${H5DIR}/lib ./configure --prefix=/usr/local
RUN cd /tmp/netcdf-4.4.1.1 && make
RUN cd /tmp/netcdf-4.4.1.1 && make install

####################################
# Install rwrfhydro
RUN Rscript -e "devtools::install_github('NCAR/rwrfhydro')"

# Install doMC and foreach
RUN Rscript -e "install.packages('doMC')"
RUN Rscript -e "install.packages('foreach')"

#Install rgdal and rgeos
RUN Rscript -e "install.packages('rgdal')"
RUN Rscript -e "install.packages('rgeos')"
