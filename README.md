# docker-research
docker-research for cloud processing data

This is a work in process

Note you will need to create a directory named data that contains needs the collection of raster (.img) files and is not provided...


## Docker Compose Method
#### Build the images

```bash
docker-compose  -p ecloud -f docker-compose.yml build --force-rm
```
#### Start docker-compose

```bash
docker-compose  -p ecloud -f docker-compose.yml up -d
```

#### you can check if the nfs mount worked
```bash
docker exec -i -t rserver ls /data/

NCB2000_01.img	NCB2000_29.img	NCB2001_11.img	NCB2001_39.img	NCB2002_21.img
NCB2000_02.img	NCB2000_30.img	NCB2001_12.img	NCB2001_40.img	NCB2002_22.img
NCB2000_03.img	NCB2000_31.img	NCB2001_13.img	NCB2001_41.img	NCB2002_23.img
NCB2000_04.img	NCB2000_32.img	NCB2001_14.img	NCB2001_42.img	NCB2002_24.img
NCB2000_05.img	NCB2000_33.img	NCB2001_15.img	NCB2001_43.img	NCB2002_25.img
NCB2000_06.img	NCB2000_34.img	NCB2001_16.img	NCB2001_44.img	NCB2002_26.img
NCB2000_07.img	NCB2000_35.img	NCB2001_17.img	NCB2001_45.img	NCB2002_27.img
NCB2000_08.img	NCB2000_36.img	NCB2001_18.img	NCB2001_46.img	NCB2002_28.img
NCB2000_09.img	NCB2000_37.img	NCB2001_19.img	NCB2002_01.img	NCB2002_29.img
NCB2000_10.img	NCB2000_38.img	NCB2001_20.img	NCB2002_02.img	NCB2002_30.img
NCB2000_11.img	NCB2000_39.img	NCB2001_21.img	NCB2002_03.img	NCB2002_31.img
NCB2000_12.img	NCB2000_40.img	NCB2001_22.img	NCB2002_04.img	NCB2002_32.img
NCB2000_13.img	NCB2000_41.img	NCB2001_23.img	NCB2002_05.img	NCB2002_33.img
NCB2000_14.img	NCB2000_42.img	NCB2001_24.img	NCB2002_06.img	NCB2002_34.img
NCB2000_15.img	NCB2000_43.img	NCB2001_25.img	NCB2002_07.img	NCB2002_35.img
NCB2000_16.img	NCB2000_44.img	NCB2001_26.img	NCB2002_08.img	NCB2002_36.img
NCB2000_17.img	NCB2000_45.img	NCB2001_27.img	NCB2002_09.img	NCB2002_37.img
NCB2000_18.img	NCB2000_46.img	NCB2001_28.img	NCB2002_10.img	NCB2002_38.img
NCB2000_19.img	NCB2001_01.img	NCB2001_29.img	NCB2002_11.img	NCB2002_39.img
NCB2000_20.img	NCB2001_02.img	NCB2001_30.img	NCB2002_12.img	NCB2002_40.img
NCB2000_21.img	NCB2001_03.img	NCB2001_31.img	NCB2002_13.img	NCB2002_41.img
NCB2000_22.img	NCB2001_04.img	NCB2001_32.img	NCB2002_14.img	NCB2002_42.img
NCB2000_23.img	NCB2001_05.img	NCB2001_33.img	NCB2002_15.img	NCB2002_43.img
NCB2000_24.img	NCB2001_06.img	NCB2001_34.img	NCB2002_16.img	NCB2002_44.img
NCB2000_25.img	NCB2001_07.img	NCB2001_35.img	NCB2002_17.img	NCB2002_45.img
NCB2000_26.img	NCB2001_08.img	NCB2001_36.img	NCB2002_18.img	NCB2002_46.img
NCB2000_27.img	NCB2001_09.img	NCB2001_37.img	NCB2002_19.img
NCB2000_28.img	NCB2001_10.img	NCB2001_38.img	NCB2002_20.img
```

#### running the data process
```bash

docker exec -i -t rserver Rscript /process/mk_phenoclasses.R         used (Mb) gc trigger (Mb) max used (Mb)
Ncells  94895  5.1     350000 18.7   235732 12.6
Vcells 203091  1.6     786432  6.0   689728  5.3
Loading required package: iterators
[1] "###########################################################################"
[1] "Wed Oct 25 12:41:59 2017 | Clusters: 10"
[1] "Num seed trials: 100 | Max num trials: 100 | Num cores to use: 4"
Loading required package: methods
Loading required package: sp
Loading required package: bigmemory
Loading required package: bigmemory.sri
Loading required package: biglm
Loading required package: DBI
[1] "XY coordinates saved to /process/load_data.RData"
[1] "Populating array output[181575:46]"
Processing yr: 2000 2001 2002 Done
[1] "Wed Oct 25 12:42:14 2017 | Minutes loading data: 0.26"
[1] "No missing values. Skipping imputation."
Loading required package: zoo

Attaching package: ‘zoo’

The following objects are masked from ‘package:base’:

    as.Date, as.Date.numeric

[1] "Wed Oct 25 12:42:14 2017 | Calculating polar coords. (0 rows witheld)"
[1] "Wed Oct 25 12:42:16 2017 | Minutes loading data: 0.04"
Warning message:
In as.big.matrix(output) :
  Coercing data.frame to matrix via factor level numberings.
[1] "Wed Oct 25 12:42:17 2017 | Clustering 10 PC phenoregions from 2000 pixel-years"
[1] "Wed Oct 25 12:42:17 2017: Minutes clustering data: 0.01"
[1] "Check if pixels were assigned to clusters (right-most col)."
  pixel yr  es  ms  ls    s_avg    s_mag  ems_mag  lms_mag  
1     1  1 100 212 308 78.44444 43.91542 58.32550 79.68331 3
2     2  1  98 218 306 75.37037 42.50043 55.26148 79.22923 1
3     3  1  92 212 308 78.32143 40.15377 57.52826 78.92126 1
4     4  1  99 211 307 80.88889 44.92107 62.45692 80.10451 3
5     5  1  86 206 302 82.57143 42.93771 63.15309 80.55335 6
6     6  1  96 208 304 80.92593 45.51001 61.80302 80.57751 3
     pixel yr  es  ms  ls    s_avg    s_mag  ems_mag  lms_mag  
1995   995  2  96 208 304 73.81481 40.20805 60.39562 68.44379 1
1996   996  2  94 206 302 74.00000 40.21837 60.67798 68.34685 1
1997   997  2  84 196 300 73.82143 37.48659 60.05057 66.86553 2
1998   998  2  95 207 303 74.74074 40.54709 58.60925 72.96518 1
1999   999  2  99 211 307 73.96296 40.08689 57.26446 73.27660 1
2000  1000  2 101 213 309 73.96296 40.08689 57.26446 73.27660 4
[1] "/process/kmoutput.RData"
[1] "Total program time: 0.31 minutes."
```


#### Checking if things go wrong
check if running
```bash
docker-compose -p ecloud -f docker-compose.yml  ps

Name                Command               State                   Ports                 
-----------------------------------------------------------------------------------------
nfs       bash -c ./mount-main.sh ${ ...   Up      111/tcp, 20048/tcp, 2049/tcp          
nfs2000   /run-mountd.sh /exports/data     Up      111/tcp, 20048/tcp, 2049/tcp          
nfs2001   /run-mountd.sh /exports/data     Up      111/tcp, 20048/tcp, 2049/tcp          
nfs2002   /run-mountd.sh /exports/data     Up      111/tcp, 20048/tcp, 2049/tcp          
rserver   /bin/sh -c bash -c  '/wait ...   Up      111/tcp, 20048/tcp, 2049/tcp, 8787/tcp

```

#### check the docker compose logs
```bash
docker-compose -p ecloud -f docker-compose.yml logs

nfs2001    | rpc.mountd: Version 1.3.3 starting
nfs2002    | rpc.mountd: Version 1.3.3 starting
nfs2002    | rpc.mountd: authenticated mount request from 10.5.0.3:809 for /exports/data (/exports/data)
nfs        | Export list for 10.5.0.200:
rserver    | clnt_create: RPC: Port mapper failure - Unable to receive: errno 0 (Success)
nfs2001    | rpc.mountd: authenticated mount request from 10.5.0.3:913 for /exports/data (/exports/data)
nfs        | /exports/data *
nfs2000    | rpc.mountd: Version 1.3.3 starting
rserver    | NFS mount is unavailable - sleeping
rserver    | clnt_create: RPC: Program not registered
rserver    | NFS mount is unavailable - sleeping
nfs2000    | rpc.mountd: authenticated mount request from 10.5.0.3:930 for /exports/data (/exports/data)
nfs        | NFS mount is up - executing command
nfs        | Export list for 10.5.0.201:
nfs        | /exports/data *
...
```
