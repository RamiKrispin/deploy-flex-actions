# Deploy Flexdashboard on Github Pages with Github Actions and Docker

<img src="images/wip.png" width="10%" /> Work in progress...


This repo provides a step-by-step guide and a template for deploying and refreshing a [flexdashboard](https://pkgs.rstudio.com/flexdashboard/) on [Github Pages](https://pages.github.com/) with [Docker](https://www.docker.com/) and [Github Actions](https://github.com/features/actions).

<a href='https://github.com/RamiKrispin/coronavirus_dashboard'><img src="images/flexdashboard_example.png" width="100%" /></a> 

## TODO
- Set docker environment ✅ 
- Set Github Pages workflow
- Build example dashboard
- Set automation with Github Actions
- Create documenations


### Folder structure

``` shell
.
├── README.md
├── docker
│   ├── Dockerfile
│   ├── build_docker.sh
│   ├── install_packages.R
│   └── packages.json
├── docker-compose.yml
└── images
    ├── flexdashboard_example.png
    └── wip.png
```

## Motivation

As its name implies, the flexdashboard package provides a flexible framework for creating dashboards. It is part of the [Rmarkdown](https://rmarkdown.rstudio.com/) ecosystem, and it has the following features:
* Set the dashboard layout with the use of [rows and columns format](https://pkgs.rstudio.com/flexdashboard/articles/layouts.html)
* Customize the dashboard theme using CSS or the [bslib](https://pkgs.rstudio.com/flexdashboard/articles/theme.html) package
* Use built-in widgets such as [value boxes](https://pkgs.rstudio.com/flexdashboard/articles/using.html#value-boxes) and [gauges](https://pkgs.rstudio.com/flexdashboard/articles/using.html#gauges)
* Create interactive (and serverless) dashboards leveraging R data visualization tools (e.g., Plotly, highcharter, dychart, leaflet, etc.), tables (gt, reactable, reactablefrm, kable, etc.), and [htmlwidges](https://pkgs.rstudio.com/flexdashboard/articles/using.html#html-widgets) tools such as crosstalk.
* Build dynamic dashboards with [Shiny](https://pkgs.rstudio.com/flexdashboard/articles/shiny.html) 

This tutorial will focus on deploying flexdashboard to Github Pages and automating the dashboard data refresh with Github Actions and Docker. Github and Docker offer both enterprise and free tools, we will leverage for this tutorial the free versions.

### When to use Github Actions?

Github Actions is a CI/CD tool enabling scheduling and triggering jobs (or scripts). In the context of R, here are some useful use cases:
- Package tests - Triggering R CMD Check when pushing new code (see this [example](https://github.com/RamiKrispin/coronavirus/actions/workflows/main.yml)) 
- Data automation - Build data pipelines with [Rmarkdown](https://ramikrispin.github.io/coronavirus/data_pipelines/covid19_cases.html) or pull data from [APIs](https://github.com/RamiKrispin/USelectricity/blob/fe742c8756f885a9cbb6dcc9bcf24e1e1ede69ce/.github/workflows/main.yml#L19)
- Refresh data, rerender flexdashboard and redeploy on Github Pages (see [coronavirus](https://ramikrispin.github.io/coronavirus_dashboard/) and [covid19italy](https://ramikrispin.github.io/italy_dash/) packages supproting dashboards)

### Why Docker?

Docker is a CI/CD tool that enables seamless code deployment from dev to prod. By creating OS-level virtualization, it can package an application and its dependencies in a virtual container. Or in other words, the code that was developed and tested in the dev env will run with the exact same env (e.g., the same OS, compilers, packages, and other dependencies) on prod. Docker can run natively on Linux systems and with Docker Desktop (or equivalent) on macOS and Windows OS.

### Docker + R = ❤️❤️❤️

Docker is a great tool for automating tasks in R, in particular, when deploying R code with Github Actions (e.g., R CMD Check, Rmarkdown or Flexdashboard). In this tutorial, we will build a development environment and use it to build the dashboard and then leverage it to deploy it on Github Actions. There are two main approaches for developing with Docker in R:
- RStudio server 
- VScode

We will cover the two and discuss the pros and cons of each approach.

### Workflow

A typical workflow will include the following steps

- **Scope** - define the project requirements and derive dependencies
- **Dockerize** - set initial development environment 
- **Prototype** - build the functions and plots on Rmarkdown
- **Develop** - start to build the dashboard
- **Deploy** - push the dashboard to Github Pages 
- **Automate** - build the dashboard refresh with Github Actions

Typically, you may update the Docker image throughout the development process if additional requirements (or dependencies) beyond the scope will be needed.


**TODO - add architect diagram**


## Dashboard scope

Create a worldwide COBID19 tracker which will include:
- Confirmed cases distribution by contenant
- Cases distribution by country:
    - Confirmed
    - Death

Expected dependencies:
- Dashboard - [flexdashboard](https://pkgs.rstudio.com/flexdashboard/index.html)
- Data - [coronavirus](https://github.com/RamiKrispin/coronavirus)
- Data visualization - [highcharter](https://jkunst.com/highcharter/index.html)
- Utility - [dplyr](https://dplyr.tidyverse.org/), [tidyr](https://tidyr.tidyverse.org/), [lubridate](https://lubridate.tidyverse.org/)

## Set Docker environment

There are multiple approaches to setting a Docker environment using the `Dockerfile`. My approach is to minimize the `Dockerfile` by using utility files and automating the process with `bash` scrip. This makes the `Dockerfile` cleaner with fewer layers, yielding a smaller image size.  Below is the tree of the `docker` folder:

``` shell
.
├── Dockerfile
├── build_docker.sh
├── install_packages.R
└── packages.json
```

This includes the following four files:
- `Dockerfile` - the image manifest provides a set of instructions for the docker engine about how to build the image
- `build_docker.sh` - a bash script to automate the build of the image and push to Docker Hub
- `install_packages.R` - an R script that installs the dependencies of the project as set in the `packages.json` file
- `packages.json` - a JSON file with a list of the project packages and their version


### The Dockerfile

Let's now review the `Dockerfile`:

``` Dockerfile
# Pulling Rocker image with RStudio and R version 4.2
FROM rocker/rstudio:4.2

# Disabling the authentication step
ENV USER="rstudio"
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "0", "--auth-none", "1"]

# Install jq to parse json files
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# installing R packages
RUN mkdir packages
COPY install_packages.R packages/
COPY packages.json packages/
RUN Rscript packages/install_packages.R

EXPOSE 8787

```
This Dockerfile has the following five components:
- **Base image** - We will use the [rocker/rstudio:4.2`](https://hub.docker.com/r/rocker/rstudio/tags) image as the base image for this project. This image contains R version 4.2.0 and the RStudio server installed and will be used as the development environment.
- **Disabling the authentication** - By default, the RStudio server requires a user name and password. We will use the `ENV` command to define the environment variable `USER` and set it as `rstudio` and the `CMD` command to disable the authentication step. # TODO check if first step is needed...
- **Installing Dependencies** - Generally, rocker images will have most of the Debian packages, C/C++ compliers, and other dependencies. However, often you may need to install additional requirements based on the packages you add to the image. In our case, we will use the `RUN` command to install [jq](https://stedolan.github.io/jq/), a command line tool for parsing `JSON` files, and the [libxml2](https://packages.debian.org/search?keywords=libxml2) Debian package that is required to install the [lubridate](https://lubridate.tidyverse.org/) package.
- **Installing the R packages** - To install additional R packages, we will make a new directory inside the image called `packages` and copy the `install_packages.R` and `packages.json` files that will be used to install the required R packages. 
- **Expose port** - Last but not least, we will use the `EXPOSE` command to expose port 8787 (default) for the RStudio server (as set on the base docker).

We will define all required packages and their versions on the `packages.json` file:
``` json
{
    "packages": [
        {
            "package": "cpp11",
            "version":"0.4.2"
        },
        {
            "package": "flexdashboard",
            "version":"0.5.2"
        },
        {
            "package": "dplyr",
            "version":"1.0.9"
        },
        {
            "package": "tidyr",
            "version":"1.2.0"
        },
        {
            "package": "highcharter",
            "version":"0.9.4"
        },
        {
            "package": "coronavirus",
            "version":"0.3.32"
        },
        {
            "package": "lubridate",
            "version":"1.8.0"
        }
        
       
    ]
}

```

## Prototype the dashboard data visualization

## Dashboard development

## Deploy on Github Pages

## Set automation with Github Actions


### Set environment with Docker


