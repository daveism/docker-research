#!/bin/sh
#take a netcdf file of the smoothed NDVI and create the 46 seperate .img files.

#get the number of layers in the the netcdf file should correspond to the 46 This is manaul so for each new netcdf we have to actuall edit the script 
dimensions="$(gdalinfo MCD13.A2000.unaccum.nc --config CPL_DEBUG NO | grep NETCDF_DIM_record_DEF | sed 's/.*{\(.*\)}/\1/')"

IFS=', ' read -r -a array <<< "$dimensions"

#get start and end of arrayy so we can loop through and create each layer
start=${array[1]}
end=${array[0]}

#create spatail reference
gdalsrsinfo  -o wkt  MCD13.A2000.unaccum.nc > MCD13_A2000_unaccum_wkt.txt

#loop each layer and ouput the indidvudal file.
for (( c=$start; c<=$end; c++ ))
do
  #  echo "Welcome $c times"
  index=$(printf %02d $c)
  gdal_translate -of "HFA" -b $c MCD13.A2000.unaccum.nc A2000_$index.img -a_srs  MCD13_A2000_unaccum_wkt.txt
done

