


load_data <- function(dpath, opath, f_prfx, yrs2proc) {
  t0 <- proc.time() # Mark time
  ### Load packages
  library(raster)
  library(biganalytics)
  options(bigmemory.typecast.warning=FALSE) # Turn off bigmemory warnings

  ### Determine raster dimensions
  ras <- raster(list.files(path=dpath, pattern=f_prfx,
                full.names=TRUE)[1]) # Load rasters
  np <- ncell(ras) # No. of pixels
  spy <- length(list.files(path=dpath,
                       pattern=paste(f_prfx,'2000',sep=''))) # Samples per yr
  ### Save number of pixels and coordinate data
  ofname <- file.path(opath,'load_data.RData')
  xycoords <- xyFromCell(ras, 1:ncell(ras)) # Lambert x,y coords
  save(list=c('np', 'spy', 'xycoords'), file=ofname)
  print(paste('XY coordinates saved to', ofname))
  rm(ras) # Clean up
  ### Initialize output array
  output <- big.matrix(np*length(yrs2proc),spy, type='short')
  print(paste('Populating array output[',
    nrow(output),':',ncol(output),']',sep=''))

  cat('Processing yr:')
  for (I in 1:length(yrs2proc)) {
    gc()
    yr <- yrs2proc[I]
    cat(paste('',yr))
    a <- (I-1)*np+1
    b <- I*np
    files2proc <- list.files(path=dpath,
      pattern=paste(f_prfx,yrs2proc[I],sep=''),
      full.names=T) # Single spatial raster
    rasterlist <- lapply(files2proc, raster) # List of function calls
    for (index in 1:length(rasterlist)) {
      gc()
      ras <- rasterlist[index]
      ras.stack <- stack(ras)
      ras.as.matrix <- as.matrix(ras.stack, nrow=np, ncol=1)
      output[a:b,index] <- as.matrix(ras.stack, nrow=np, ncol=1)
    }
  }
  cat(' Done\n')

  melap <- sprintf('%03.2f', (proc.time()-t0)[3]/60^1) # Time elapsed
  print(paste(date(),' | Minutes loading data: ',melap,sep=''))

  return(output)
}
