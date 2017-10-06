gap_fill <- function(input, opath, np, spy, nyr) {
  t0 <- proc.time() # Mark time
  library(biganalytics)
  RI <- 1:nrow(input) # Vector of row indices of input
  MISS <- mwhich(input, 1:ncol(input), NA, 'eq', 'OR') # Rows with NA's
  if (length(MISS) == 0) {
    Z <- integer(0); ZP <- integer(0); ZPc <- integer(0)
    print('No missing values. Skipping imputation.')
  } else {
    print('Missing data found. Imputing.')
    miss <- unique(MISS%%np) # Row position (in 1:np cells) for cells with NA's
    cnt1 <- 0; cnt2 <- 0
    for (I in miss) {
      ri <- RI[RI%%np == I] # Row indexes for all yrs of this MODIS cell
      mu <- colMeans(input[ri,], na.rm=T) # Column means
      if (sum(is.na(mu))) { # If any NA's in colmeans then can't gap-fill
        input[ ri, ] <- 0
        cnt1 <- cnt1+1
    } else { # Otherwise gap-fill this row
        w <- which(is.na(input[ ri, ]), arr.ind=T)
        tmp <- input[ ri, ]
        for (J in 1:nrow(w)) {
          row <- w[J,1]
          col <- w[J,2]
          tmp[row,col] <- mu[col] # Replace NA element w/ corresp. mean
        }
        input[ ri, ] <- tmp # Update input
        cnt2 <- cnt2+1
      }
    }
    np2 <- nrow(input)/nyr # Update np
    if (np != np2) {
      print(paste(cnt1,	'rows cant be gap-filled & set to 0 because',
        'complete year of data cannot be built for these pixels'))
    }
    rm(np2)
    print(paste(cnt2, 'rows gap-filled'))
    # Z: Rows of input where 50% or more of the year (values) are zero 
    # ZP: Subset of Z representing pixels for which there are not at least
    #	two years of >= 50% non-zero data. (Pixels are cannot be gap-filled)
    # ZC: The counterpart of ZP. Pixels with at least two years non-zero data
    Z <- which((rowSums(input[]==0) >= spy/2 ) == T) # Yrs with >= 50% or zero data
    Zmod <- Z %% np # Every occurrence of pixels that have zero yrs of data
    Zt <- table(Zmod) # Tabulation of zero occurrences for each pixel in Z
    ZPid <- as.integer(names(Zt[Zt > nyr-2])) # Problem pixels without at
                                              # least 2 yrs nonzero data
    ZP <- (1:nrow(input))[rep(1:np, nyr) %in% ZPid] # Rows w/ bad pixel data
    ZPc <- (1:nrow(input))[-ZP] # ZP counterpart (Rows w/ adequate sampling)

    print(paste(length(ZP), 'rows(yrs) with',
                'insufficient sampling will be witheld from clustering'))
    melap <- sprintf('%03.2f', (proc.time()-t0)[3]/60^1)
    print(paste(date(),' | Hours gap-filling data: ',melap,sep=''))
  }
  ### Save results
  save(list=c('Z', 'ZP', 'ZPc'),
    file=file.path(opath,'gap_fill.RData'))

  return(input)
}
