FROM rocker/geospatial
MAINTAINER "Dave Michelson" dmichels@unca.edu

ARG USER='rstudio'
ARG WORK_DIR='/project'
ARG CONFIG_FILE='sample.env'

RUN apt-get clean autoclean
RUN apt-get autoremove -y

RUN install2.r --error zoo
RUN install2.r --error sp
RUN install2.r --error raster
RUN install2.r --error biganalytics
RUN install2.r --error doMC
RUN install2.r --error rgdal
RUN install2.r --error devtools
RUN Rscript -e "devtools::install_github('bjornbrooks/PolarMetrics')"

COPY . $WORK_DIR

RUN chown -R $USER:$USER $WORK_DIR

COPY $CONFIG_FILE /home/$USER/.Renviron

# Set the working directory upon R session startup
RUN echo setwd\(\'$WORK_DIR\'\) >> /home/$USER/.Rprofile

