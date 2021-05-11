FROM rocker/shiny:4.0.0

RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev

ENV WORKON_HOME /opt/virtualenvs
ENV PYTHON_VENV_PATH $WORKON_HOME/ui

## Set up a user modifyable python3 environment
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpython3-dev \
        python3-venv && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv ${PYTHON_VENV_PATH}

ENV PATH ${PYTHON_VENV_PATH}/bin:${PATH}
## And set ENV for R! It doesn't read from the environment...
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron && \
    echo "WORKON_HOME=${WORKON_HOME}" >> /usr/local/lib/R/etc/Renviron && \
    echo "RETICULATE_PYTHON_ENV=${PYTHON_VENV_PATH}" >> /usr/local/lib/R/etc/Renviron

## Because reticulate hardwires these PATHs...
RUN ln -s ${PYTHON_VENV_PATH}/bin/pip /usr/local/bin/pip && \
    ln -s ${PYTHON_VENV_PATH}/bin/virtualenv /usr/local/bin/virtualenv

RUN pip3 install \
    requests \
    numpy

RUN Rscript -e "install.packages('dplyr', repos='http://cran.rstudio.com/')"
RUN Rscript -e "install.packages('shinyjs', repos='http://cran.rstudio.com/')"
RUN Rscript -e "install.packages('bs4Dash', repos='http://cran.rstudio.com/')"
RUN Rscript -e "install.packages('readbitmap', repos='http://cran.rstudio.com/')"
RUN Rscript -e "install.packages('magick', repos='http://cran.rstudio.com/')"
RUN Rscript -e "install.packages('reticulate', repos='http://cran.rstudio.com/')"

EXPOSE 3838

ADD ./app /app
WORKDIR /app
CMD ["R", "-e", "shiny::runApp('./', host = '0.0.0.0', port = 80)"]