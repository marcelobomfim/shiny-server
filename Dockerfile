FROM rocker/shiny

MAINTAINER Marcelo Bomfim (marcelo.bomfim@tesouro.gov.br)

## install R package dependencies (and clean up)

RUN apt-get update && apt-get install -y gnupg2 \
    libssl-dev \
	libcurl4-openssl-dev \
	libcurl4-openssl-dev \
	libxml2-dev \
	libudunits2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## install packages from CRAN (and clean up)

RUN Rscript -e "install.packages(c('tidyverse', 'sandwich', 'forecast', 'strucchange', 'lubridate', 'tableHTML', 'dygraphs', 'RCurl', 'ckanr', 'Rcpp', 'shiny', 'rmarkdown', 'tm', 'wordcloud', 'memoise', 'plotly', 'readxl','devtools','dplyr','tidyr','fuzzyjoin','stringr','ggthemes','quantmod','ggplot2','shinydashboard','shinythemes', 'shinyTree', 'DT', 'flexdashboard', 'kableExtra', 'rvest', 'data.table', 'slickR', 'tidytext', 'igraph', 'units', 'ggforce', 'ggraph', 'widyr'), repos='https://cran.rstudio.com/')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## install packages from github (and clean up)

RUN Rscript -e "devtools::install_github('rstudio/shinytest','rstudio/webdriver')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## install phantomjs

RUN Rscript -e "webdriver::install_phantomjs()"

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

RUN chmod +x /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
