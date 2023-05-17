ReadWtFile <- function(wtFile) {

        ncid <- ncdf4::nc_open(wtFile)
        i_index <- ncdf4::ncvar_get(ncid, "i_index")
        j_index <- ncdf4::ncvar_get(ncid, "j_index")
        IDmask <- ncdf4::ncvar_get(ncid, "IDmask")
        weight <- ncdf4::ncvar_get(ncid, "weight")
        regridweight <- ncdf4::ncvar_get(ncid, "regridweight")
        data <- data.frame(i_index=i_index, j_index=j_index, IDmask=IDmask, weight=weight, regridweight=regridweight)

        polyid <- ncdf4::ncvar_get(ncid, "polyid")
        overlaps <- ncdf4::ncvar_get(ncid, "overlaps")
        polys <- data.frame(polyid=polyid, overlaps=overlaps)

        list(data, polys)

}

ReadLinkFile <- function(linkFile) {
        rtLinks <- GetNcdfFile(linkFile, variables=c("time"), exclude=TRUE, quiet=TRUE)
        rtLinks$site_no <- stringr::str_trim(rtLinks$gages)
	rtLinks
}

ReadGwbuckFile <- function(gwbuckFile) {
        gwBuck <- GetNcdfFile(gwbuckFile, quiet=TRUE)
        gwBuck
}

SubsetWts <- function(wts, rlids, istart, iend, jstart, jend) {

	wts.sub <- subset(wts[[1]], wts[[1]]$IDmask %in% rlids)
	wts.sub$i_index <- wts.sub$i_index-(istart-1)
	wts.sub$j_index <- wts.sub$j_index-(jstart-1)
	wts.sub.rect <- subset(wts.sub, wts.sub$i_index>0 & wts.sub$i_index<=(iend-istart+1) & wts.sub$j_index>0 & wts.sub$j_index<=(jend-jstart+1))
	polywts <- aggregate(wts.sub.rect$weight, by=list(wts.sub.rect$IDmask), sum)
	names(polywts)<-c("IDmask", "mult")
	wts.sub.rect <- plyr::join(wts.sub.rect, polywts, by="IDmask")
	wts.sub.rect$weight <- with(wts.sub.rect, weight/mult)
	wts.sub.rect$mult <- NULL

	poly.sub <- subset(wts[[2]], wts[[2]]$polyid %in% rlids)
	names(poly.sub) <- c("polyid", "kill")
	tmp <- plyr::count(wts.sub.rect$IDmask)
	names(tmp) <- c("polyid", "overlaps")
	poly.sub <- plyr::join(poly.sub, tmp, by="polyid")
	poly.sub$overlaps[is.na(poly.sub$overlaps)] <- 0
	poly.sub$kill <- NULL

	return(list(wts.sub.rect, poly.sub))
}

UpdateLinkFile <- function(linkFile, linkDf, subDim=TRUE) {
	if (subDim) {
#        	cmdtxt <- paste0("ncks -O -d linkDim,1,", nrow(linkDf), " ", linkFile, " ", linkFile)
               cmdtxt <- paste0("ncks -O -d feature_id,1,", nrow(linkDf), " ", linkFile, " ", linkFile)
		print(cmdtxt)
        	system(cmdtxt)
	}

        ncid <- nc_open(linkFile, write=TRUE)
        for (i in names(ncid$var)) {
		print(i)
                if (i %in% names(linkDf)) ncvar_put(ncid, i, linkDf[,i])
        }
        nc_close(ncid)
        return()

}

UpdateWtFile <- function(wtFile, wtdataDf, wtpolyDf, subDim=TRUE) {
	if (subDim) {
		cmdtxt <- paste0("ncks -O -d polyid,1,", nrow(wtpolyDf), " -d data,1,", nrow(wtdataDf), " ", wtFile, " ", wtFile)
		system(cmdtxt)
	}

        ncid <- nc_open(wtFile, write=TRUE)
        for (i in names(wtdataDf)) {
                if (i %in% names(ncid$var)) ncvar_put(ncid, i, wtdataDf[,i])
        }
        for (i in names(wtpolyDf)) {
                if ( (i %in% names(ncid$var)) | (i %in% names(ncid$dim)) ) ncvar_put(ncid, i, wtpolyDf[,i])
        }
        nc_close(ncid)
        return()

}

UpdateWtFile2 <- function(wtFile, wtdataDf) {

        ncid <- nc_open(wtFile, write=TRUE)
        for (i in names(wtdataDf)) {
                if (i %in% names(ncid$var)) ncvar_put(ncid, i, wtdataDf[,i])
        }
        nc_close(ncid)
        return()

}

UpdateGwbuckFile <- function(gwbuckFile, gwbuckDf, subDim=TRUE) {
	if (subDim) {
        	cmdtxt <- paste0("ncks -O -d BasinDim,1,", nrow(gwbuckDf), " ", gwbuckFile, " ", gwbuckFile)
        	system(cmdtxt)
	}

        ncid <- nc_open(gwbuckFile, write=TRUE)
        for (i in names(gwbuckDf)) {
                if (i %in% names(ncid$var)) ncvar_put(ncid, i, gwbuckDf[,i])
        }
        nc_close(ncid)
        return()

}


UpdateLakeFile <- function(lakeFile, lakeDf, subDim=TRUE) {
  if (subDim) {
#    cmdtxt <- paste0("ncks -O -d nlakes,1,", nrow(lakeDf), " ", lakeFile, " ", lakeFile)
  cmdtxt <- paste0("ncks -O -d feature_id,1,", nrow(lakeDf), " ", lakeFile, " ", lakeFile)

    print(cmdtxt)
    system(cmdtxt)
  }

  ncid <- nc_open(lakeFile, write=TRUE)
  for (i in names(ncid$var)) {
    print(i)
    if (i %in% names(lakeDf)) ncvar_put(ncid, i, lakeDf[,i])
  }
  nc_close(ncid)
  return()

}

