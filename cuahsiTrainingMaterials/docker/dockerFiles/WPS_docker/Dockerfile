####################
###Docker file for basic WPS use for WRF-Hydro training
###Borrows heavily from rdccosmo images

FROM ubuntu:latest
MAINTAINER Joe Mills <jmills@ucar.edu>

RUN apt-get update
RUN apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    vim \
    ncview \
    libhdf5-dev \
    gfortran \
    gfortran-5-multilib \
    build-essential \
    libcloog-ppl1 \
    make \
    m4 \
    libswitch-perl \
    ncl-ncarg \
    ncview \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /home/cuahsi && \
    useradd -ms /bin/bash cuahsi && \
    usermod -aG sudo cuahsi

#USER cuahsi
ENV HOME /home/cuahsi

RUN mkdir $HOME/Build_WRF 
RUN mkdir $HOME/Build_WRF/LIBRARIES

ENV PREFIX $HOME/Build_WRF
ENV DEBIAN_FRONTEND noninteractive

ENV BUILDDIR $HOME/Build_WRF

ENV DIR $HOME/Build_WRF/LIBRARIES
WORKDIR $DIR

ENV CC gcc

ENV CXX g++

ENV FC gfortran

ENV FCFLAGS -m64

ENV F77 gfortran

ENV FFLAGS -m64

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

#Set more environment variables
ENV LD_LIBRARY_PATH_WRF $PREFIX/lib/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH_WRF:$LD_LIBRARY_PATH
ENV NCARG_ROOT=$PREFIX
ENV PATH=$NCARG_ROOT/bin:$PATH
#ENV NETCDF $PREFIX
RUN ulimit -s unlimited

# 32.  serial
ENV WRF_CONFIGURE_OPTION 32
ENV WRF_EM_CORE 1
ENV WRF_NMM_CORE 0

#Compile wrf
ENV WRF_VERSION 3.7.1
RUN mkdir /tmp/WRF \
	&& cd /tmp/WRF \
	&& wget http://www2.mmm.ucar.edu/wrf/src/WRFV$WRF_VERSION.TAR.gz \
	&& tar -xzf WRFV$WRF_VERSION.TAR.gz \
	&& cd WRFV3 
	#\
	#&& echo $WRF_CONFIGURE_OPTION | ./configure \
	#&& ./compile 
#RUN mkdir /tmp/WPS \
#	&& cd /tmp/WPS \
#	&& wget http://www2.mmm.ucar.edu/wrf/src/WPSV$WRF_VERSION.TAR.gz \
#	&& tar -xzf WPSV$WRF_VERSION.TAR.gz
