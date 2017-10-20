rm(list=ls())
gc()

##############################################################################
### Program variables
os.env <- 'linux' # linux or windows
dpath <- '/data'
spath <- '/process'
subset <- TRUE # Should an even smaller subset be selected for clustering
nk <- 10 # Number of clusters centroids
yrs2proc <- seq(2000, 2002) # Calendar years of data to process
nyr <- length(yrs2proc)
iter.seed <- 10^2 # Number of iterations to find optimal cluster seed values
iter.trial <- 10^2 # During each clustering, what is the max number of
t_init <- proc.time()

### Custom functions
normaliz <- function(m){ # Normalize function
	(m - min(m, na.rm=T))/(max(m, na.rm=T)-min(m, na.rm=T))
}

### Load packages
library(parallel)
library(foreach) # Enables parallel loops
if (os.env == 'linux') {
	library(doMC) # Shared memory parallelism for Linux
} else if (os.env == 'windows') { # If using Windows start parallellism now
	library(doSNOW) # Shared memory parallelism for Windows
}
ncores <- detectCores() # library(parallel) Set num cores for parallel comp.

print(paste(rep('#', 75), collapse=''))
print(paste(date(), '| Clusters:', nk))
print(paste('Num seed trials:', iter.seed,
	'| Max num trials:', iter.trial,
	'| Num cores to use:',ncores))

##############################################################################
### STEP 1, LOAD DATA

source(file.path(spath, 'load_data.R'))
big.x <- load_data(dpath=dpath, opath=spath, f_prfx='NCB',
                   yrs2proc=yrs2proc)

load(file.path(spath,'load_data.RData')) # Load np, spy, xycoors

##############################################################################
### STEP 2, GAP-FILL MISSING NDVI DATA

source(file.path(spath, 'gap_fill.R'))
big.x <- gap_fill(input=big.x, opath=spath, np=np, spy=spy,
                  nyr=length(yrs2proc))

# Load output from gap_fill function. Variable ZPc indicates the rows of
#   acceptable data that can be analyzed. ZP is an array of row indices
#   where less than 50% of the values for a pixel were missing and that
#   pixel was not gap filled.
load(file.path(spath,'gap_fill.RData')) # Load gap_fill output

##############################################################################
### STEP 3, CALCULATE POLAR COORDINATE PARAMETERS FROM NDVI

source(file.path(spath, 'calc_pc.R'))
if (subset == TRUE) {
   np2 <- 10^3 # Number of pixels to run through PolarMetrics and clustering
   big.x <- big.x[1:(np2*16),] # Create subset
   big.pc <- calc_pc(input=big.x, ZP=ZP, ZPc=ZPc, spc=spy, np=np2, nyr=nyr)
} else {
  big.pc <- calc_pc(input=big.x, ZP=ZP, ZPc=ZPc, spc=spy, np=np, nyr=nyr)
}

##############################################################################
### STEP 4, CLUSTER PC DATA

t0 <- proc.time()
x <- big.pc[, 3:ncol(big.pc)]
x <- as.big.matrix(x) # Make into big.matrix object
x.std <- apply(x, 2, normaliz) # Normalize across vars
x.std <- as.big.matrix(x.std) # Make into big.matrix object
print(paste(date(), '| Clustering', nk,
	'PC phenoregions from',nrow(x.std),'pixel-years'))
if (os.env == 'linux') {
	registerDoMC(ncores) # Register CPU cores
} else if (os.env == 'windows') { # If using Windows start parallellism now
	cl=makeCluster(ncores)
	registerDoSNOW(cl) # Register CPU cores
}
km <- bigkmeans(x.std, centers=nk, iter.max = iter.trial,
	nstart = iter.seed, dist = 'euclid') # Cluster in parallel
melap <- sprintf('%03.2f', (proc.time()-t0)[3]/60^1) # Time elap
print(paste(date(),': Minutes clustering data: ',melap,sep=''))

# Check results
print('Check if pixels were assigned to clusters (right-most col).')
print(cbind(head(big.pc),head(km$cluster)))
print(cbind(tail(big.pc),tail(km$cluster)))

melap <- sprintf('%03.2f', (proc.time()-t_init)[3]/60^1) # Time elap
print(file.path(spath,"kmoutput.RData"))
saveRDS(km, file=file.path(spath,"kmoutput.RData"))
print(paste('Total program time:',melap,'minutes.'))
