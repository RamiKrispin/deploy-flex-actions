# Pulling Rocker image with RStudio and R version 4.2
FROM rocker/rstudio:4.2

# Setting environment variables
ARG CONDA_ENV=flex_dashboard
ENV CONDA_ENV=$CONDA_ENV

ARG PYTHON_VER=3.8
ENV PYTHON_VER=$PYTHON_VER


# Disabling the authentication step
ENV USER="rstudio"
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "0", "--auth-none", "1"]

# Install jq to parse json files
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    libxml2-dev \
    zlib1g \
    g++-11 \
    libz-dev \
    freetype2-demos \
    libpng-dev \
    libtiff-dev \
    libjpeg-dev \
    make \
    fontconfig \
    libfribidi-dev \
    libharfbuzz-dev \
    libfontconfig1-dev \
    && rm -rf /var/lib/apt/lists/*

# installing R packages
RUN mkdir packages
COPY install_packages.R packages/
COPY install_python.R packages/
COPY packages.json packages/
RUN Rscript packages/install_packages.R

# Install miniconda
RUN sudo apt update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && sudo add-apt-repository -y ppa:deadsnakes/ppa \
    && sudo apt update 

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh \
    && /bin/bash ~/miniconda.sh -b -p /opt/conda \
    && export PATH=/opt/conda/bin:$PATH \
    && conda init bash \
    && conda install conda-build

# Set environment
RUN . /root/.bashrc \
    && conda create -y --name $CONDA_ENV python=$PYTHON_VER 

RUN Rscript packages/install_python.R

EXPOSE 8787
