calc_pc <- function(input, ZP, ZPc, spc, np, nyr) {
  t0 <- proc.time() # Mark time
  library(PolarMetrics)
  print(paste(date(), ' | Calculating polar coords. (',
        length(ZP),' rows witheld)',sep=''))
  nr <- np*(nyr-1)
  output <- data.frame(pixel=rep(1:np, times=(nyr-1)), yr=rep(NA,nr),
                es=rep(NA,nr), ms=rep(NA,nr), ls=rep(NA,nr),
                s_avg=rep(NA,nr), s_mag=rep(NA,nr), ems_mag=rep(NA,nr),
                lms_mag=rep(NA,nr)) # Initialize output array
  seq <- np*seq(from=0, to=nyr-1)
  if (length(ZPc) > 0) {
    px2proc <- unique(ZPc %% np)
    px2proc[px2proc==0]=np # Pixels with good data
  } else {
    px2proc <- 1:np
  }
  t <- rep(seq(3, 365, by=8), nyr) + 365*rep(0:(nyr-1), each=46)
  for (I in px2proc) { # Loop over good pixels
    idx <- rep(I, nyr) + seq
    input_idx <- input[idx,]
    tmp <- calc_metrics(as.vector(t(input_idx)), t = t, yr_type='cal_yr',
                        spc=spc, lcut=0.15, hcut=0.8,
                        return_vecs=FALSE,
                        sin_cos=FALSE) # Calculate PC's
    output[idx[-length(idx)], c(2:ncol(output))] <- tmp[,c(1,2,4,6,8,10,11,12)]
  }
  output <- as.big.matrix(output)
  melap <- sprintf('%03.2f', (proc.time()-t0)[3]/60^1) # Time elapsed
  print(paste(date(),' | Minutes loading data: ',melap,sep=''))

  return(output)
}
