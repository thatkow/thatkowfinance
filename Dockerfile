# Configure R image w/ dartR library installed + autoloaded.
FROM r-base:latest

# Install system packages required for dartR
RUN apt-get -yqq update 
RUN apt-get install -y curl
RUN apt-get install -y r-cran-ggplot2
RUN apt-get install -y r-cran-reshape2
RUN apt-get install -y r-cran-shiny
RUN apt-get install -y r-cran-curl
RUN apt-get clean

COPY . /thatkowfinance/
RUN R CMD build thatkowfinance
RUN R CMD INSTALL thatkowfinance_*.tar.gz
RUN rm -rf thatkowfinance*



RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site

RUN useradd -ms /bin/bash app

WORKDIR /home/app
COPY  australiansuperinvestmentswitchtest/app.R /home/app/australiansuperinvestmentswitchtest.R
RUN chown app -R /home/app
USER app
CMD ["R", "-e", "shiny::runApp(host = '0.0.0.0', port = 3838, '/home/app/australiansuperinvestmentswitchtest.R')"]
