# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny:latest

# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# copy necessary files
## app folder
COPY ./app /srv/shiny-server/app/

## shiny-server.sh
COPY ./Docker/shiny/shiny-server.sh /usr/bin/shiny-server.sh

# replace default index.html
RUN mv /srv/shiny-server/index.html /srv/shiny-server/index.html.original
RUN cp -r /srv/shiny-server/sample-apps/hello/ /srv/shiny-server/hello/
COPY ./Docker/shiny/index.html /srv/shiny-server/index.html

# delete example apps that comes with rocker image
## folder names => 01_app1 02_app2; rm *_* deletes all folders with _ in the 
RUN rm -r /srv/shiny-server/*_*
RUN rm -r /srv/shiny-server/sample-apps/*

# install packages
RUN R -e "install.packages('shinydashboard')"

# add "shiny" as the owner
RUN sudo chown -R shiny:shiny /srv/shiny-server

# expose port
EXPOSE 3838

# run shiny server shell script
CMD ["/usr/bin/shiny-server.sh"]