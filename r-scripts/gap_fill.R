gap_fill <- function(dataset, OUTPUT_DIR, NUM_PIXELS, SAMPLES_PER_YR, NUM_YRS) {
  # Mark time 
  t0 <- proc.time()
  library(biganalytics)

  gc()

  ROW_INDICES <- 1:nrow(dataset)
  
  ROWS_WITH_NA <- mwhich(dataset, 1:ncol(dataset), NA, 'eq', 'OR')
  
  if (length(ROWS_WITH_NA) == 0) {
    Z <- integer(0); ZP <- integer(0); ZPc <- integer(0)
    print('No missing values. Skipping imputation.')
  } else {
    print('Missing data found. Imputing.')
    # Row position (in 1:NUM_PIXELS cells) for cells with NA's
    miss <- unique(ROWS_WITH_NA%%NUM_PIXELS) 
    cnt1 <- 0; cnt2 <- 0
    for (I in miss) {
      gc()
      # Row indexes for all yrs of this MODIS cell
      ri <- ROW_INDICES[ROW_INDICES%%NUM_PIXELS == I]
      mu <- colMeans(dataset[ri,], na.rm=T) # Column means
      if (sum(is.na(mu))) { # If any NA's in colmeans then can't gap-fill
        gc()
        dataset[ ri, ] <- 0
        cnt1 <- cnt1+1
      } else { # Otherwise gap-fill this row
        gc()
        w <- which(is.na(dataset[ ri, ]), arr.ind=T)
        tmp <- dataset[ ri, ]
        for (J in 1:nrow(w)) {
          row <- w[J,1]
          col <- w[J,2]
          tmp[row,col] <- mu[col] # Replace NA element w/ corresp. mean
        }
        dataset[ ri, ] <- tmp # Update dataset
        cnt2 <- cnt2+1
      }
    }
    NUM_PIXELS2 <- nrow(dataset)/NUM_YRS # Update NUM_PIXELS
    if (NUM_PIXELS != NUM_PIXELS2) {
      print(paste(cnt1, 'rows cant be gap-filled & set to 0 because',
        'complete year of data cannot be built for these pixels'))
    }
    rm(NUM_PIXELS2)
    print(paste(cnt2, 'rows gap-filled'))
    # Z: Rows of dataset where 50% or more of the year (values) are zero 
    # ZP: Subset of Z representing pixels for which there are not at least
    # two years of >= 50% non-zero data. (Pixels are cannot be gap-filled)
    # ZC: The counterpart of ZP. Pixels with at least two years non-zero data
    Z <- which((rowSums(dataset[]==0) >= SAMPLES_PER_YR/2 ) == T) # Yrs with >= 50% or zero data
    Zmod <- Z %% NUM_PIXELS # Every occurrence of pixels that have zero yrs of data
    Zt <- table(Zmod) # Tabulation of zero occurrences for each pixel in Z
    ZPid <- as.integer(names(Zt[Zt > NUM_YRS-2])) # Problem pixels without at
                                              # least 2 yrs nonzero data
    ZP <- (1:nrow(dataset))[rep(1:NUM_PIXELS, NUM_YRS) %in% ZPid] # Rows w/ bad pixel data
    ZPc <- (1:nrow(dataset))[-ZP] # ZP counterpart (Rows w/ adequate sampling)

    print(paste(length(ZP), 'rows(yrs) with',
                'insufficient sampling will be witheld from clustering'))
    melap <- sprintf('%03.2f', (proc.time()-t0)[3]/60^1)
    print(paste(date(),' | Hours gap-filling data: ',melap,sep=''))
  }
  ### Save results
  save(list=c('Z', 'ZP', 'ZPc'),
    file=file.path(OUTPUT_DIR,'gap_fill.RData'))

  gc()

  return(dataset)
}
