FROM rocker/geospatial
MAINTAINER "Dave Micheson" dmichels@unca.edu

ARG WORK_DIR='/docker'
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

COPY $CONFIG_FILE /home/rstudio/.Renviron

RUN chown -R rstudio:rstudio $WORK_DIR

