#' List all upstream gages from each of the specified gages in the Routlink file
#'
#' \code{GetUpStreamGages} Trace all the gages above a given gage in the Routlink file.
#'
#' @param routlinkFile Path to the Routlink file
#'
#'  @param downstreamReExpFile Path to the reexpression file provided by rwrfhydro, if not available leave it NULL
#'  and script will create the file for you, and place where the routlink file reside with an extension of "reExpTo.Rdb"
#'  therefore if left as NULL, make sure you have a write permission to that directory.
#' 
#' @param upstreamReExpFile Path to the reexpression file provided by rwrfhydro, if not available leave it NULL
#'  and script will create the file for you, and place where the routlink file reside with an extension of "reExpFrom.Rdb"
#'  therefore if left as NULL, make sure you have a write permission to that directory.
#' 
#' @param reIndFile Path to the reexpression file provided by rwrfhydro, if not available leave it NULL
#'  and script will create the file for you, and place where the routlink file reside with an extension of "reInd.Rdb"
#'  therefore if left as NULL, make sure you have a write permission to that directory.
#' 
#' @param .parallel Logical, DEFAULT is FALSE
#'
#' @return return a list of gages with all their upstream gages in the Routlink. 
#'
#' @examples
#' \dontrun{
#' Example 1:
#' routlinkFile <- "~/wrfHydroTestCases/04233300/DOMAIN/RouteLink.nc"
#' upStreamGages <- GetUpStreamGages(routlinkFile)
#' 
#' Example 2:
#' downstreamReExpFile <- "/glade/p/nwc/nwmv12_finals/DOMAIN//RouteLink_2017_04_24.reExpTo.Rdb"
#' upstreamReExpFile   <- "/glade/p/nwc/nwmv12_finals/DOMAIN//RouteLink_2017_04_24.reExpFrom.Rdb"
#' reIndFile           <- "/glade/p/nwc/nwmv12_finals/DOMAIN//RouteLink_2017_04_24.reInd.Rdb"
#' rlFile <- "/glade/p/nwc/adugger/NWM_V12/CONUS_CALIB/DOMAIN/RouteLink_2016_11_04_fixed_latlonalt_gagefix_topofix_NEWPARAMS_INDEXED.nc"
#' upStreamGages <- GetUpStreamGages(rlFile, downstreamReExpFile, upstreamReExpFile, reIndFile, .parallel = TRUE)
#' }
#' @keywords
#' @concept
#' @family
#' @export

GetUpStreamGages <- function(routlinkFile, downstreamReExpFile = NULL, upstreamReExpFile = NULL, reIndFile = NULL, .parallel = FALSE) {
  
  # if downstreamReExpFile, upstreamReExpFile and reIndFile are specified above then check all of them 
  # to make sure the files exist and if they donot exist throw an error
  #if they are all NULL, then create the files 
  if (all(is.null(downstreamReExpFile), is.null(upstreamReExpFile), is.null(reIndFile))) {
 
    # create the re expression files and then read them into memory
    rwrfhydro::ReExpressRouteLink(routlinkFile, parallel = .parallel)
    
    load(paste0(substr(routlinkFile, 1, nchar(routlinkFile) - 2), "reInd.Rdb"))
    load(paste0(substr(routlinkFile, 1, nchar(routlinkFile) - 2), "reExpFrom.Rdb"))
    load(paste0(substr(routlinkFile, 1, nchar(routlinkFile) - 2), "reExpTo.Rdb"))
    
  } else {
    
    if (!file.exists(downstreamReExpFile)) stop(paste0("This file does not exist : "), downstreamReExpFile)
    if (!file.exists(upstreamReExpFile)) stop(paste0("This file does not exist : "), upstreamReExpFile)
    if (!file.exists(reIndFile)) stop(paste0("This file does not exist : "), reIndFile)
    
    # load the reexpressions files 
    load(downstreamReExpFile)
    load(upstreamReExpFile)
    load(reIndFile)
  }
  
  # get the list of all the existing gages and their corresponding comIds from Routlink file
  rlGage <- rwrfhydro::ncdump(routlinkFile,'gages', q=TRUE)
  rlComid <- rwrfhydro::ncdump(routlinkFile,'link', q=TRUE)
  
  # Find all the gages in the Routlink 
  gageInds <- which(trimws(rlGage) != '')
  names(gageInds) <- rlGage[gageInds]
  
  ## make this a list of pairs: gageId, gageInd
  dumList <- 1:length(gageInds)
  names(dumList) <- trimws(names(gageInds))
  gageIndsList <- plyr::llply(dumList, function(ii) list(gageId=names(gageInds)[ii],
                                                         gageInd=gageInds[[ii]]) )
  
  
  ## Get the neighboring (next up or down) stream gages
  GetGageNeighborsUp <- function(gageIdInd) {
    rwrfhydro:::GatherNeighborStreamGages(from, gageIdInd$gageInd,
                                          linkLength=reInd$length,
                                          gageIndices=which(trimws(rlGage)!=''),
                                          intervening=TRUE)
  }
  
  upNeighborGages <- plyr::llply(gageIndsList, GetGageNeighborsUp, .parallel=.parallel)
  
  for(ll in 1:length(upNeighborGages)) upNeighborGages[[ll]]$thisGage$startInd <- gageIndsList[[ll]]$gageInd
  
  upNeighborGages <-
    plyr::llply(upNeighborGages,
          function(ll) { ll$upGages$comId =rlComid[ll$upGages$ind]
          ll$upGages$gageId= rlGage[ll$upGages$ind]
          ll$thisGage$comId =rlComid[ll$thisGage$startInd]
          ll$thisGage$gageId= rlGage[ll$thisGage$startInd]
          ll$intervening$comId= rlComid[ll$intervening$ind]
          attributes(ll$intervening$ind) <- NULL
          attributes(ll$intervening$dist) <- NULL
          attributes(ll$intervening$tip) <- NULL
          ll })
  
  #*******************************
  # Find all the upstream gages to a given gage
  getUpGaues <- function(g) {
    upGages <- trimws(upNeighborGages[[trimws(g)]]$upGages$gageId)
    if (identical(upGages, character(0))){
      return(NULL)
    }else{
      return(c(upGages, unlist(plyr::llply(upGages, getUpGaues))))
    }
  }
  
  gages <- as.list(names(upNeighborGages))
  names(gages) <- gages
  
  upStreamGages <- plyr::llply(gages, getUpGaues)
  return(upStreamGages)
}


#' List all upstream gages from each of the specified gages in the Routlink file
#'
#' \code{GetinterveningNHD} Trace all the gages above a given gage in the Routlink file.
#'
#' @param routlinkFile Path to the Routlink file
#' 
#' @param spatialWeightFile Path to the spatial weight file
#'
#' @param downstreamReExpFile Path to the reexpression file provided by rwrfhydro, if not available leave it NULL
#'  and script will create the file for you, and place where the routlink file reside with an extension of "reExpTo.Rdb"
#'  therefore if left as NULL, make sure you have a write permission to that directory.
#' 
#' @param upstreamReExpFile Path to the reexpression file provided by rwrfhydro, if not available leave it NULL
#'  and script will create the file for you, and place where the routlink file reside with an extension of "reExpFrom.Rdb"
#'  therefore if left as NULL, make sure you have a write permission to that directory.
#' 
#' @param reIndFile Path to the reexpression file provided by rwrfhydro, if not available leave it NULL
#'  and script will create the file for you, and place where the routlink file reside with an extension of "reInd.Rdb"
#'  therefore if left as NULL, make sure you have a write permission to that directory.
#' 
#' @param .parallel Logical, DEFAULT is FALSE
#'
#' @return return a data.table with three fields, ID (the comID), 
#' gage (The immediate downstream that the corresponding comID drains into),
#' Area (the number/fraction of pixels covered by the NHD catchment, for NWM 16 means 1sqkm since 
#' the spatial resolution of overland flow routing is 205 meter)
#'
#' @examples
#' \dontrun{
#' Example 1:
#' routlinkFile <- "~/wrfHydroTestCases/04233300/DOMAIN/RouteLink.nc"
#' spatialWeightFile <- "~/wrfHydroTestCases/04233300/DOMAIN/spatialweights.nc"
#' interveningNHD <- GetInterveningNHD(routlinkFile, spatialWeightFile)
#' 
#' Example 2:
#' downstreamReExpFile <- "/glade/p/nwc/nwmv12_finals/DOMAIN//RouteLink_2017_04_24.reExpTo.Rdb"
#' upstreamReExpFile   <- "/glade/p/nwc/nwmv12_finals/DOMAIN//RouteLink_2017_04_24.reExpFrom.Rdb"
#' reIndFile           <- "/glade/p/nwc/nwmv12_finals/DOMAIN//RouteLink_2017_04_24.reInd.Rdb"
#' rlFile <- "/glade/p/nwc/adugger/NWM_V12/CONUS_CALIB/DOMAIN/RouteLink_2016_11_04_fixed_latlonalt_gagefix_topofix_NEWPARAMS_INDEXED.nc"
#' spatialWeightFile = "/glade/p/nwc/adugger/NWM_V12/NWMV12_FINALS/DOMAIN//spatialweights_1km_v1_2_all_basins_20170320.nc"
#' interveningNHD <- GetInterveningNHD(rlFile, spatialWeightFile, downstreamReExpFile, upstreamReExpFile, reIndFile, .parallel = TRUE)
#' }
#' @keywords
#' @concept
#' @family
#' @export
#' 


GetInterveningNHD <- function(routlinkFile, spatialWeightFile, downstreamReExpFile = NULL, upstreamReExpFile = NULL, reIndFile = NULL, .parallel = FALSE) {
  
  # if downstreamReExpFile, upstreamReExpFile and reIndFile are specified above then check all of them 
  # to make sure the files exist and if they donot exist throw an error
  #if they are all NULL, then create the files 
  if (all(is.null(downstreamReExpFile), is.null(upstreamReExpFile), is.null(reIndFile))) {
    
    # create the re expression files and then read them into memory
    rwrfhydro::ReExpressRouteLink(routlinkFile, parallel = .parallel)
    
    load(paste0(substr(routlinkFile, 1, nchar(routlinkFile) - 2), "reInd.Rdb"))
    load(paste0(substr(routlinkFile, 1, nchar(routlinkFile) - 2), "reExpFrom.Rdb"))
    load(paste0(substr(routlinkFile, 1, nchar(routlinkFile) - 2), "reExpTo.Rdb"))
    
  } else {
    
    if (!file.exists(downstreamReExpFile)) stop(paste0("This file does not exist : "), downstreamReExpFile)
    if (!file.exists(upstreamReExpFile)) stop(paste0("This file does not exist : "), upstreamReExpFile)
    if (!file.exists(reIndFile)) stop(paste0("This file does not exist : "), reIndFile)
    
    # load the reexpressions files 
    load(downstreamReExpFile)
    load(upstreamReExpFile)
    load(reIndFile)
  }
  
  # get the list of all the existing gages and their corresponding comIds from Routlink file
  rlGage <- rwrfhydro::ncdump(routlinkFile,'gages', q=TRUE)
  rlComid <- rwrfhydro::ncdump(routlinkFile,'link', q=TRUE)
  
  # Find all the gages in the Routlink 
  gageInds <- which(trimws(rlGage) != '')
  names(gageInds) <- rlGage[gageInds]
  
  ## make this a list of pairs: gageId, gageInd
  dumList <- 1:length(gageInds)
  names(dumList) <- trimws(names(gageInds))
  gageIndsList <- plyr::llply(dumList, function(ii) list(gageId=names(gageInds)[ii],
                                                         gageInd=gageInds[[ii]]) )
  
  
  ## Get the neighboring (next up or down) stream gages
  GetGageNeighborsUp <- function(gageIdInd) {
    rwrfhydro:::GatherNeighborStreamGages(from, gageIdInd$gageInd,
                                          linkLength=reInd$length,
                                          gageIndices=which(trimws(rlGage)!=''),
                                          intervening=TRUE)
  }
  
  upNeighborGages <- plyr::llply(gageIndsList, GetGageNeighborsUp, .parallel=.parallel)
  
  for(ll in 1:length(upNeighborGages)) upNeighborGages[[ll]]$thisGage$startInd <- gageIndsList[[ll]]$gageInd
  
  upNeighborGages <-
    plyr::llply(upNeighborGages,
                function(ll) { ll$upGages$comId =rlComid[ll$upGages$ind]
                ll$upGages$gageId= rlGage[ll$upGages$ind]
                ll$thisGage$comId =rlComid[ll$thisGage$startInd]
                ll$thisGage$gageId= rlGage[ll$thisGage$startInd]
                ll$intervening$comId= rlComid[ll$intervening$ind]
                attributes(ll$intervening$ind) <- NULL
                attributes(ll$intervening$dist) <- NULL
                attributes(ll$intervening$tip) <- NULL
                ll })
  
  # read the spatial weight file and then add the necessary information to the upNighborGages 
  
  swDT <- data.table::as.data.table(rwrfhydro::GetNcdfFile(spatialWeightFile, variables = c("IDmask", "i_index", "j_index", "regridweight"), quiet = TRUE))
  # this area is actually number of pixels that is covered by the catchment, for example area of 16 here means 1 sqkm since the  grid is 250m*250m
  nhdInfo <- swDT[, .(Area = sum(regridweight)), by = "IDmask"]
  data.table::setnames(nhdInfo,"IDmask", "ID")
  data.table::setkey(nhdInfo, "ID")
  
  # I need to arrange the info to a data.table with all the comIDs, and the gages which each comID belongs to.
  
  vec <- names(upNeighborGages)
  names(vec) <- vec
  interveningNHD <- data.table::as.data.table(plyr::ldply(vec, function(x) {
    data.frame(comId = c(upNeighborGages[[x]]$thisGage$comId, upNeighborGages[[x]]$intervening$comId))
  }))
  data.table::setnames(interveningNHD, ".id", "gage")  # change the name of the field from .id to gage
  data.table::setkey(interveningNHD, "comId")
  
  # merge the Area to all the comIds which are in the corresponding basins for the desired gauges
  
  interveningNHD <- nhdInfo[interveningNHD, .(ID,gage,Area)]
  
  # There are some links which does not have any catchment assigned to them (around 51963 of them)
  # remove those links form the calculation, doing so may remove some of the gages from the calculation
  # (in the IOC 6 gauges "09309600" "05288580" "03314000" "01378500" "10260855" "11045700")
  
  interveningNHD <- interveningNHD[!(is.na(Area))]
  return(interveningNHD)
}

#' Calculate the Mean Areal values over the NHDPlus Catchments
#'
#' \code{CalcMeanAreal} is designed to calculate the mean areal values
#' (e.g. Mean Areal Precipitation).
#'
#' @param spatialWeightFile Path to the Spatial Weight file 
#' (This is the spatial weight file for the Fuldom reslution, for the NWM 250m).
#'
#' @param gridVar A matrix of the gridded variable.
#' Note that the matrix should be matching either the Geo Domain or the Fuldom Domian. 
#' 
#' @param highRes Logical, DEFAULT is FALSE meaning that the gridVar is matching 
#' The resolution of the GeoDomain file (1km for NWM), if TRUE means gridVar matches the resolution
#' of the Fuldom file (250 meter for NWM)
#'
#' @return A data.table containing the IDmask (which is what is called ComID or featureID)
#' and meanAreal (the Mean Areal values for each basin (unique ComIDs)).
#'
#' @examples
#' \dontrun{
#'
#' spatialWeightFile <- "~/wrfHydroTestCases/04233300/DOMAIN/spatialweights.nc"
#' forcFile = "~/wrfHydroTestCases/04233300/FORCING/2013092121.LDASIN_DOMAIN1"
#' rain <- rwrfhydro::ncdump(forcFile, "RAINRATE", quiet = TRUE)
#' meanP <- CalcMeanAreal(spatialWeightFile, rain)
#' }
#' @keywords
#' @concept
#' @family
#' @export

CalcMeanAreal <- function(spatialWeightFile, gridVar, highRes = FALSE) {
  
  spatialWeight <- data.table::as.data.table(rwrfhydro::GetNcdfFile(spatialWeightFile, variables = c("IDmask", "i_index", "j_index", "regridweight"), quiet = TRUE))

  # set the key to i and j 
  data.table::setkeyv(spatialWeight,c("i_index", "j_index"))
  
  # convert the matrix to a dataframe with i and j indexes for rows and columns
  # first since the spatial weight file if for the 250 meter tile and not the 1km geoDomain 
  # we need to divide each pixel to 16 
  if (!highRes) gridVar <- gridVar[rep(1:nrow(gridVar), each = 4),][, rep(1:ncol(gridVar), each = 4)]

  varDT <- data.table::data.table(i_index = rep(1:dim(gridVar)[1], dim(gridVar)[2]),
                                  j_index = rep(1:dim(gridVar)[2], each = dim(gridVar)[1]),
                                  var = c(gridVar))
  
  data.table::setkeyv(varDT,c("i_index", "j_index"))
  
  # merge the varDT and the swDF by the i and j index, in other word add a column to the swDT data.table which has
  # the variable information over each pixel
  merged <- data.table:::merge.data.table(spatialWeight, varDT, by = c("i_index", "j_index"))
  
  # calculate the Mean Areal values for each polygon (unique ComID or IDmask)
  meanAreal <- merged[, .(meanAreal = (sum(regridweight*var)/sum(regridweight))), by = .(IDmask)]
  return(meanAreal)
}

#' Calculate the Mean Areal values over the intervening
#' as well as contributing area for each gage
#'
#' \code{CalcMeanArealCont} is designed to calculate the mean areal values
#' (e.g. Mean Areal Precipitation) for the intervening area (the area between a gage and
#' the immeidate upstream gages) and contributig area.
#'
#' @param meanArealDT A data.table or data.frame having mean areal values calculated from \code{CalcMeanAreal}
#'
#' @param interveningNHD A data.table or data.frame (output of \code{GetInterveningNHD}) having four fields.
#' ID   : ComID of the reach which dains to the gage
#' gage : Name of the USGS (or any local gage), there could be multiple reaches which
#' drain into the gage, in which case there will be multiple rows for each reach
#' Area : Area of the corresponsing ID
#'
#' @param upStreamGages A list of gages with all their upstream gages in the Routlink. 
#' This is the output of function \code{GetUpStreamGages}
#'
#' @return A data.table containing the three fields:
#' 1. gage  2. meanContributing 3. meanIntervening
#'
#' @examples
#' \dontrun{
#' 
#' routlinkFile <- "~/wrfHydroTestCases/04233300/DOMAIN/RouteLink.nc"
#' upStreamGages <- GetUpStreamGages(routlinkFile)
#' 
#' spatialWeightFile <- "~/wrfHydroTestCases/04233300/DOMAIN/spatialweights.nc"
#' interveningNHD <- GetInterveningNHD(routlinkFile, spatialWeightFile)
#' 
#' spatialWeightFile <- "~/wrfHydroTestCases/04233300/DOMAIN/spatialweights.nc"
#' forcFile = "~/wrfHydroTestCases/04233300/FORCING/2013092121.LDASIN_DOMAIN1"
#' rain <- rwrfhydro::ncdump(forcFile, "RAINRATE", quiet = TRUE)
#' meanP <- CalcMeanAreal(spatialWeightFile, rain)
#' 
#' contP <- CalcMeanArealCont(meanArealDT = meanP, interveningNHD, upStreamGages)
#' }
#' @keywords
#' @concept
#' @family
#' @export

CalcMeanArealCont <- function(meanArealDT, interveningNHD, upStreamGages) {
  # Function for calculating the MAP over the intervening area between the two gage and also the MAP over the contrbuting area
  
  # Convert the list of upstreamGages to a data.frame
  a <- data.frame(gage = character(), upGages = character())
  for (i in names(upStreamGages)) {
    a <- rbind(a, data.frame(gage = i, upGages = i))
    if (!is.null(upStreamGages[[i]])) {
      for (j in length(upStreamGages[[i]])) {
        a <- rbind(a, data.frame(gage = i, upGages = upStreamGages[[i]][j]))
      }
    }
  }
  upStreamGages <- data.table::as.data.table(a)
  data.table::setkey(upStreamGages, "upGages")
  
  # set the ket for the meanArealDT
  if (!data.table::is.data.table(meanArealDT)) meanArealDT <- data.table::as.data.table(meanArealDT)
  data.table::setkeyv(meanArealDT, "IDmask")  # set the key to sort the data.table of the MAP values over the NHDPlus catchments
  
  # set the key for the NHD
  # Add the precipitation information to the data.table, melt the data.table based on the gage and then calculate the
  if (!data.table::is.data.table(interveningNHD)) interveningNHD <- data.table::as.data.table(interveningNHD)
  data.table::setkey(interveningNHD, "ID")
  
  interveningMAP <- meanArealDT[interveningNHD][,.(meanIntervening = sum(meanAreal*Area)/sum(Area), meanA = sum(Area)),by=gage]
  data.table::setnames(interveningMAP, "gage", "upGages")
  data.table::setkey(interveningMAP, "upGages")
  
  # Add the upstreamComIds calculate the MAP for all the contributing area
  
  contributingMAP <- interveningMAP[upStreamGages][,.(meanContributing = sum(meanIntervening*meanA)/sum(meanA)), by=gage]
  contributingMAP <- data.table:::merge.data.table(contributingMAP, interveningMAP, by.x = "gage", by.y = "upGages")[, meanA := NULL]
  return(contributingMAP)
}


