# docker-research
docker-research for cloud processing data

This is a work in process

Note you will need to create a directory named data that contains needs the collection of raster (.img) files and is not provided...



## Docker Method
comming soon
### Build the images
```bash
 docker build -t nfs_d -f  DockerNFS .
 docker build -t r-server_d -f  DockerR .
```

### run servers
```bash

``

## Docker Compose Method
#### Build the images

```bash
docker-compose  -p ecloud -f docker-compose.yml build
```
#### Start docker-compose

```bash
docker-compose  -p ecloud -f docker-compose.yml up -d
```

#### you can check if the nfs mount worked
```bash
docker exec -i -t rserver ls /mnt/subset
```

#### run the
```bash
docker exec -i -t rserver ls /mnt/subset
```

End docker-compose
```bash
docker-compose  -p ecloud -f docker-compose.yml down
```

#### Checking if things go wrong
check if running
```bash
docker-compose -p ecloud -f docker-compose.yml  ps
```

#### check logs
```bash
docker-compose -p ecloud -f docker-compose.yml logs
```

#### running the data process
```bash
docker exec -i -t rserver Rscript /process/mk_phenoclasses.R

 used (Mb) gc trigger (Mb) max used (Mb)
Ncells  94895  5.1     350000 18.7   235732 12.6
Vcells 203091  1.6     786432  6.0   689728  5.3
Loading required package: iterators
[1] "###########################################################################"
[1] "Fri Oct  6 20:13:56 2017 | Clusters: 10"
[1] "Num seed trials: 100 | Max num trials: 100 | Num cores to use: 4"
Loading required package: methods
Loading required package: sp
Loading required package: bigmemory
Loading required package: bigmemory.sri
Loading required package: biglm
Loading required package: DBI
[1] "XY coordinates saved to /process/load_data.RData"
[1] "Populating array output[968400:46]"
Processing yr: 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 Done
[1] "Fri Oct  6 20:14:55 2017 | Minutes loading data: 0.98"
[1] "No missing values. Skipping imputation."
Loading required package: zoo

Attaching package: ‘zoo’

The following objects are masked from ‘package:base’:

as.Date, as.Date.numeric

[1] "Fri Oct  6 20:14:55 2017 | Calculating polar coords. (0 rows witheld)"
[1] "Fri Oct  6 20:15:02 2017 | Minutes loading data: 0.11"
Warning message:
In as.big.matrix(output) :
Coercing data.frame to matrix via factor level numberings.
[1] "Fri Oct  6 20:15:02 2017 | Clustering 10 PC phenoregions from 15000 pixel-years"
[1] "Fri Oct  6 20:15:04 2017: Minutes clustering data: 0.04"
[1] "Check if pixels were assigned to clusters (right-most col)."
pixel yr  es  ms  ls    s_avg    s_mag  ems_mag  lms_mag  
1     1  1 101 213 309 78.44444 43.91542 58.32550 79.68331 7
2     2  1 100 220 308 75.37037 42.50043 55.26148 79.22923 7
3     3  1  92 212 308 78.32143 40.15377 57.52826 78.92126 5
4     4  1  99 211 307 80.88889 44.92107 62.45692 80.10451 4
5     5  1  90 210 306 82.57143 42.93771 63.15309 80.55335 4
6     6  1  97 209 305 80.92593 45.51001 61.80302 80.57751 4
pixel yr  es  ms  ls    s_avg    s_mag  ems_mag  lms_mag  
14995   995 15  96 200 312 62.92857 35.67364 51.24706 55.66232 3
14996   996 15  95 199 311 63.03571 35.39723 50.91785 55.78972 3
14997   997 15  98 210 306 73.14815 40.49246 56.50094 70.35034 8
14998   998 15  98 210 306 73.14815 40.49246 56.50094 70.35034 8
14999   999 15 109 213 309 76.03846 45.84091 57.05051 77.54839 7
15000  1000 15 101 213 309 79.40741 44.48853 59.08620 80.53240 4
[1] "/process/kmoutput.RData"
[1] "Total program time: 1.14 minutes
```
