###################################
# Author: Joe Mills <jmills@ucar.edu>
# Date:  9.27.2017
###################################
#
# This Dockerfile compiles WRF and WPS from source using the bare-bones requirements for training purposes.
# See https://ral.ucar.edu/projects/ncar-docker-wrf for more complete WRF and WPS docker builds with additional functionality

FROM ubuntu:16.04

MAINTAINER jmills@ucar.edu
USER root

#Set WRF and WPS version argument
ARG WRFWPS_VERSION="3.9"

#Install linux dependencies
RUN apt-get update \
  && apt-get install -y csh \
  m4 \
  wget \
  gcc \
  gfortran \
  make \
  libhdf5-dev \
  bzip2 \
  ncview \
  vim \
  nco \
  libswitch-perl \
  libxrender1 \
  libfontconfig1 \
  libxext6 \
  && apt-get clean

WORKDIR /

#############
# Build NETCDF libraries
# Build netcdf-C first, required by netcdf-fortran
RUN wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.4.1.1.tar.gz -P /tmp  
RUN tar -xf /tmp/netcdf-4.4.1.1.tar.gz -C /tmp
ENV H5DIR=/usr/lib/x86_64-linux-gnu/hdf5/serial
ENV NCDIR=/usr/local
RUN cd /tmp/netcdf-4.4.1.1 && CPPFLAGS=-I${H5DIR}/include LDFLAGS=-L${H5DIR}/lib ./configure --prefix=/usr/local
RUN cd /tmp/netcdf-4.4.1.1 && make
RUN cd /tmp/netcdf-4.4.1.1 && make install

# Build netcdf-Fortran second
RUN wget ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-fortran-4.4.4.tar.gz
RUN tar -xf netcdf-fortran-4.4.4.tar.gz -C /tmp
ENV NFDIR=/usr/local
ENV LD_LIBRARY_PATH=${NCDIR}/lib
RUN cd /tmp/netcdf-fortran-4.4.4/ && CPPFLAGS=-I${NCDIR}/include LDFLAGS=-L${NCDIR}/lib ./configure --prefix=${NFDIR}
RUN cd /tmp/netcdf-fortran-4.4.4 && make
RUN cd /tmp/netcdf-fortran-4.4.4 && make install

# Set NETCDF environment variable
ENV NETCDF=/usr/local

#################
#Install WRF AND WPS
WORKDIR /home/cuahsi/WRF_WPS
#
# Download sources for version specified by WRFWPS_VERSION argument
#
RUN wget http://www2.mmm.ucar.edu/wrf/src/WRFV${WRFWPS_VERSION}.TAR.gz \
	&& \
	mkdir WRFV${WRFWPS_VERSION} \
	&& tar -zxf WRFV${WRFWPS_VERSION}.TAR.gz \
	&& rm WRFV${WRFWPS_VERSION}.TAR.gz
RUN wget http://www2.mmm.ucar.edu/wrf/src/WPSV${WRFWPS_VERSION}.TAR.gz \
	&& mkdir WPSV${WRFWPS_VERSION} \
	&& tar -zxf WPSV${WRFWPS_VERSION}.TAR.gz \
	&& rm WPSV${WRFWPS_VERSION}.TAR.gz

# Build WRF first, required for WPS
WORKDIR /home/cuahsi/WRF_WPS/WRFV3
RUN printf '32\n0' | ./configure \
	&& ./compile em_real

# Build WPS second after WRF is built
WORKDIR /home/cuahsi/WRF_WPS/WPS
RUN printf '1' | ./configure \
	&& ./compile geogrid

# install NCL
RUN wget https://www.earthsystemgrid.org/download/fileDownload.html?logicalFileId=154af009-fa02-11e6-a976-00c0f03d5b7c \
  && mkdir /usr/local/ncl-6.4.0 \
  && tar -xzf fileDownload.html?logicalFileId=154af009-fa02-11e6-a976-00c0f03d5b7c -C /usr/local/ncl-6.4.0 \
  && rm fileDownload.html?logicalFileId=154af009-fa02-11e6-a976-00c0f03d5b7c

#Add cuahsi user
RUN useradd -ms /bin/bash cuahsi
RUN usermod -aG sudo cuahsi
RUN chown -R cuahsi /home/cuahsi

####################################
########## CUAHSI USER #############
####################################
USER cuahsi
WORKDIR /home/cuahsi
ENV NETCDF=/usr/local
ENV NCARG_ROOT=/usr/local/ncl-6.4.0
ENV PATH=$NCARG_ROOT/bin:$PATH
