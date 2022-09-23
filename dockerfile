FROM rocker/shiny:latest

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libudunits2-dev \
    libproj-dev \ 
    libpq-dev \ 
    gdal-bin

RUN sudo apt-get -y install libgdal-dev \
    default-libmysqlclient-dev \
    libmysqlclient-dev

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# copy necessary files
## app folder
COPY ./app ./app

## renv.lock file
# COPY /example-app/renv.lock ./renv.lock

# install renv & restore packages
RUN Rscript -e 'install.packages("leaflet")'
RUN Rscript -e 'install.packages("sf")'
# RUN Rscript -e 'install.packages("units")'
# RUN Rscript -e 'renv::consent(provided = TRUE)'
# RUN Rscript -e 'renv::restore()'

# expose port
EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]