rm(list=ls())
gc()

##############################################################################
### Setup

os.env <- 'linux' # linux or windows

DATA_IN_FILE_PREFIX <- Sys.getenv('DATA_IN_FILE_PREFIX') # prefix used in data filenames
DATA_IN_DIR <- Sys.getenv('DATA_IN_DIR')
DATA_OUT_DIR <- Sys.getenv('DATA_OUT_DIR')
DATA_TEMPLATE_DIR <- Sys.getenv('DATA_TEMPLATE_DIR')
DATA_CACHE_DIR <- Sys.getenv('DATA_CACHE_DIR')
SCRIPTS_DIR <- Sys.getenv('SCRIPTS_DIR')
CACHE_PREFIX <- Sys.getenv('CACHE_FILE_PREFIX')

YEAR_START <- Sys.getenv('YEAR_START')
YEAR_END <- Sys.getenv('YEAR_END')

YRS_TO_PROCESS <- seq(YEAR_START, YEAR_END) # Calendar years of data to process

SMALL_CLUSTERS <- TRUE # Should an even smaller subset be selected for clustering
NUM_CLUSTER_CENTROIDS <- 10 # Number of clusters centroids

NUM_YEARS <- length(YRS_TO_PROCESS)
NUM_SEED_TRIALS <- 10^2 # Number of iterations to find optimal cluster seed values
NUM_CLUSTER_TRIALS <- 10^2 # During each clustering, what is the max number of

time_init <- proc.time()

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
print(paste(date(), '| Clusters:', NUM_CLUSTER_CENTROIDS))
print(paste('Num seed trials:', NUM_SEED_TRIALS,
	'| Max num trials:', NUM_CLUSTER_TRIALS,
	'| Num cores to use:',ncores))

##############################################################################
### STEP 1, LOAD DATA

source(file.path(SCRIPTS_DIR, 'load_data.R'))
big.x <- load_data(dpath=DATA_IN_DIR,
				   opath=DATA_OUT_DIR,
				   f_prfx=DATA_IN_FILE_PREFIX,
                   yrs2proc=YRS_TO_PROCESS)

gc()
load(file.path(DATA_OUT_DIR,'load_data.RData')) # Load np, spy, xycoors

##############################################################################
### STEP 2, GAP-FILL MISSING NDVI DATA

source(file.path(SCRIPTS_DIR, 'gap_fill.R'))
big.x <- gap_fill(
  dataset=big.x,
  OUTPUT_DIR=DATA_OUT_DIR,
  NUM_PIXELS=np,
  SAMPLES_PER_YR=spy,
  NUM_YRS=length(YRS_TO_PROCESS)
)
# gap_fill <- function(dataset, OUTPUT_DIR, NUM_PIXELS, SAMPLES_PER_YR, NUM_YRS) {

# Load output from gap_fill function. Variable ZPc indicates the rows of
# acceptable data that can be analyzed. ZP is an array of row indices
#   where less than 50% of the values for a pixel were missing and that
#   pixel was not gap filled.
load(file.path(DATA_OUT_DIR,'gap_fill.RData')) # Load gap_fill output

##############################################################################
### STEP 3, CALCULATE POLAR COORDINATE PARAMETERS FROM NDVI

gc()
source(file.path(SCRIPTS_DIR, 'calc_pc.R'))
if (SMALL_CLUSTERS == TRUE) {
   np2 <- 10^3 # Number of pixels to run through PolarMetrics and clustering
   big.x <- big.x[1:(np2*16),] # Create subset
   big.pc <- calc_pc(input=big.x, ZP=ZP, ZPc=ZPc, spc=spy, np=np2, ny=NUM_YEARS)
} else {
  big.pc <- calc_pc(input=big.x, ZP=ZP, ZPc=ZPc, spc=spy, np=np, ny=NUM_YEARS)
}

##############################################################################
### STEP 4, CLUSTER PC DATA

t0 <- proc.time()
x <- big.pc[, 3:ncol(big.pc)]
x <- as.big.matrix(x) # Make into big.matrix object
x.std <- apply(x, 2, normaliz) # Normalize across vars
x.std <- as.big.matrix(x.std) # Make into big.matrix object
print(paste(date(), '| Clustering', NUM_CLUSTER_CENTROIDS,
	'PC phenoregions from',nrow(x.std),'pixel-years'))
if (os.env == 'linux') {
	registerDoMC(ncores) # Register CPU cores
} else if (os.env == 'windows') { # If using Windows start parallellism now
	cl=makeCluster(ncores)
	registerDoSNOW(cl) # Register CPU cores
}
km <- bigkmeans(x.std, centers=NUM_CLUSTER_CENTROIDS, iter.max=NUM_CLUSTER_TRIALS,
	nstart = NUM_SEED_TRIALS, dist = 'euclid') # Cluster in parallel
melap <- sprintf('%03.2f', (proc.time()-t0)[3]/60^1) # Time elap
print(paste(date(),': Minutes clustering data: ',melap,sep=''))


################################################################################
####### MAKE RASTER OUTPUTS, USING INPUT TEMPLATE
library(rgdal)
library(raster)
file.list <- list.files(DATA_TEMPLATE_DIR, pattern='template')	# place where input data live (modify 'pattern' as needed)
r <- raster(paste(DATA_TEMPLATE_DIR,file.list[1], sep="/"))	# use first one as template

years<-big.pc[unique(big.pc[,2]),2]  #make a unique list of years

# function
rstr.frm.vals <- function(template, dat, rast.format="GTiff"){
	temp <- template				# copy raster template
	vals <- getValues(temp)					# raster values vector
	# for(y in year){  # raster for each year
		for(i in 1:ncol(dat)){							# create a raster for each dat column
				vals[which(!is.na(vals))] <- dat[,i]					# set values for raster
				newrast <- setValues(temp, vals)					# feed values to raster
				extn <- ifelse(rast.format=="HFA", ".img", ".tif")
				file.name <- paste(colnames(dat)[i], extn, sep="")
				writeRaster(newrast, filename=file.name, format=rast.format, overwrite=TRUE)	#save raster
			}
		# }
	}

# run function on output data: specify template, data, and raster format.
#rstr.frm.vals(r,years[,1:1],big.pc[,3:9],"GTiff")		# specify parameters (template, data, and output format)
rstr.frm.vals(r,big.pc[,3:9],"GTiff")		# specify parameters (template, data, and output format)

# Check results
print('Check if pixels were assigned to clusters (right-most col).')
print(cbind(head(big.pc),head(km$cluster)))
print(cbind(tail(big.pc),tail(km$cluster)))

melap <- sprintf('%03.2f', (proc.time()-time_init)[3]/60^1) # Time elap
print(file.path(DATA_OUT_DIR,"kmoutput.RData"))
saveRDS(km, file=file.path(DATA_OUT_DIR,"kmoutput.RData"))
print(paste('Total program time:',melap,'minutes.'))
