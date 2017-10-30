###################################
# Author: Tony Castronova <acastronova@cuahsi.org>
# Author: Joe Mills <jmills@ucar.edu>
# Date:  9.27.2017
###################################

FROM ubuntu:16.04

MAINTAINER jmills@ucar.edu
USER root

####################################
########## ROOT USER  ##############
####################################
ARG MPICH_VERSION="3.2"
ARG MPICH_CONFIGURE_OPTIONS="--disable-cxx"
ARG MPICH_MAKE_OPTIONS

#Get all library dependencies for NCL, wrf_hydro, and mpich
RUN apt-get update
RUN apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    vim \
    ncview \
    libhdf5-dev \
    gfortran \
    m4 \
    make\
    libswitch-perl \
    libxrender1 \
    libfontconfig1 \
    libxext6 \
    nco \
	nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*



# Download, build, and install MPICH
RUN mkdir /tmp/mpich-src
WORKDIR /tmp/mpich-src
RUN wget http://www.mpich.org/static/downloads/${MPICH_VERSION}/mpich-${MPICH_VERSION}.tar.gz \
      && tar xfz mpich-${MPICH_VERSION}.tar.gz  \
      && cd mpich-${MPICH_VERSION}  \
      && ./configure ${MPICH_CONFIGURE_OPTIONS}  \
      && make ${MPICH_MAKE_OPTIONS} && make install \
      && rm -rf /tmp/mpich-src

#### TEST MPICH INSTALLATION ####
#RUN mkdir /tmp/mpich-test
#WORKDIR /tmp/mpich-test
#COPY mpich-test .
#RUN sh test.sh
#RUN rm -rf /tmp/mpich-test


#### CLEAN UP ####
WORKDIR /
#RUN rm -rf /tmp/*

# install netcdf-C
RUN wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.1.tar.gz -P /tmp  
RUN tar -xf /tmp/netcdf-4.4.1.1.tar.gz -C /tmp
ENV H5DIR=/usr/lib/x86_64-linux-gnu/hdf5/serial
ENV NCDIR=/usr/local
RUN cd /tmp/netcdf-4.4.1.1 && CPPFLAGS=-I${H5DIR}/include LDFLAGS=-L${H5DIR}/lib ./configure --prefix=/usr/local
RUN cd /tmp/netcdf-4.4.1.1 && make
RUN cd /tmp/netcdf-4.4.1.1 && make install

# install netcdf-Fortran
RUN wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.4.tar.gz
RUN tar -xf netcdf-fortran-4.4.4.tar.gz -C /tmp
ENV NFDIR=/usr/local
ENV LD_LIBRARY_PATH=${NCDIR}/lib
RUN cd /tmp/netcdf-fortran-4.4.4/ && CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib ./configure --prefix=${NFDIR}
RUN cd /tmp/netcdf-fortran-4.4.4 && make
RUN cd /tmp/netcdf-fortran-4.4.4 && make install

ENV NETCDF=/usr/local

# install NCL
RUN wget https://www.earthsystemgrid.org/download/fileDownload.html?logicalFileId=154af009-fa02-11e6-a976-00c0f03d5b7c \
  && mkdir /usr/local/ncl-6.4.0 \
  && tar -xzf fileDownload.html?logicalFileId=154af009-fa02-11e6-a976-00c0f03d5b7c -C /usr/local/ncl-6.4.0 \
  && rm fileDownload.html?logicalFileId=154af009-fa02-11e6-a976-00c0f03d5b7c

#Get the model code from https://github.com/NCAR/wrf_hydro_nwm/archive/master.zip
ADD wrf_hydro_source /home/cuahsi/wrf_hydro_source
RUN chmod 777 -R /home/cuahsi/wrf_hydro_source

#Add cuahsi user
RUN useradd -ms /bin/bash cuahsi
RUN usermod -aG sudo cuahsi

####################################
########## CUAHSI USER #############
####################################
USER cuahsi
WORKDIR /home/cuahsi
ENV NETCDF=/usr/local
ENV NCARG_ROOT=/usr/local/ncl-6.4.0
ENV PATH=$NCARG_ROOT/bin:$PATH