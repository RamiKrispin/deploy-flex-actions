# Deploy Flexdashboard on Github Pages with Github Actions and Docker

<img src="images/wip.png" width="10%" /> Work in progress, pre-spelling check...


This repo provides a step-by-step guide and a template for deploying and refreshing a [flexdashboard](https://pkgs.rstudio.com/flexdashboard/) dashboard on [Github Pages](https://pages.github.com/) with [Docker](https://www.docker.com/) and [Github Actions](https://github.com/features/actions).

<a href='https://github.com/RamiKrispin/coronavirus_dashboard'><img src="images/flexdashboard_example.png" width="100%" /></a> 

## TODO
- Set docker environment ✅ 
- Set Github Pages workflow
- Build an example dashboard
- Set automation with Github Actions
- Create documentations


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
* Simple
* Set the dashboard layout with the use of [rows and columns format](https://pkgs.rstudio.com/flexdashboard/articles/layouts.html)
* Customize the dashboard theme using CSS or the [bslib](https://pkgs.rstudio.com/flexdashboard/articles/theme.html) package
* Use built-in widgets such as [value boxes](https://pkgs.rstudio.com/flexdashboard/articles/using.html#value-boxes) and [gauges](https://pkgs.rstudio.com/flexdashboard/articles/using.html#gauges)
* Create interactive (and serverless) dashboards leveraging R data visualization tools (e.g., Plotly, highcharter, dychart, leaflet, etc.), tables (gt, reactable, reactablefrm, kable, etc.), and [htmlwidges](https://pkgs.rstudio.com/flexdashboard/articles/using.html#html-widgets) tools such as crosstalk.
* Build dynamic dashboards with [Shiny](https://pkgs.rstudio.com/flexdashboard/articles/shiny.html) 

This tutorial will focus on deploying flexdashboard to Github Pages and automating the dashboard data refresh with Github Actions and Docker. Github and Docker offer both enterprise and free tools. Throughout this tutorial, we will leverage the free versions.

### When to use Github Actions?

Github Actions is a CI/CD tool enabling scheduling and triggering jobs (or scripts). In the context of R, here are some useful use cases:
- Package testing - Triggering R CMD Check when pushing new code (see this [example](https://github.com/RamiKrispin/coronavirus/actions/workflows/main.yml)) 
- Data automation - Build data pipelines with [Rmarkdown](https://ramikrispin.github.io/coronavirus/data_pipelines/covid19_cases.html) or pull data from [APIs](https://github.com/RamiKrispin/USelectricity/blob/fe742c8756f885a9cbb6dcc9bcf24e1e1ede69ce/.github/workflows/main.yml#L19)
- Refresh data, rerender flexdashboard and redeploy on Github Pages (see [coronavirus](https://ramikrispin.github.io/coronavirus_dashboard/) and [covid19italy](https://ramikrispin.github.io/italy_dash/) packages supporting dashboards)

### Why Docker?

Docker is a CI/CD tool that enables seamless code deployment from dev to prod. By creating OS-level virtualization, it can package an application and its dependencies in a virtual container. Or in other words, the code that was developed and tested in the dev env will run with the exact same env (e.g., the same OS, compilers, packages, and other dependencies) on prod. Docker can run natively on Linux systems and with Docker Desktop (or equivalent) on macOS and Windows OS.

### Docker + R = ❤️❤️❤️

Docker is a great tool for automating tasks in R, in particular, when deploying R code with Github Actions (e.g., R CMD Check, Rmarkdown, Quarto, or Flexdashboard). In this tutorial, we will build a development environment and use it to build the dashboard and then leverage it to deploy it on Github Actions. There are two main approaches for developing with Docker in R:
- RStudio server 
- VScode

We will cover the two and discuss the pros and cons of each approach.

### Workflow

A typical workflow will include the following steps

- **Scope** - define the project requirements and derive dependencies
- **Prototype** - transform the scope into a sketch
- **Dockerize** - set initial development environment 
- **Develop** - build the dashboard functionality and data visualization
- **Deploy** - push the dashboard to Github Pages 
- **Automate** - build the dashboard refresh with Github Actions

Typically, you may update the Docker image throughout the development process if additional requirements (or dependencies) beyond the scope will be needed.


**TODO - add architect diagram**


## Dashboard scope

Create a worldwide COVID19 tracker which will include:
- Distribution of confirmed cases by continent
- Cases distribution by country:
    - Confirmed
    - Death

Expected dependencies:
- Dashboard - [flexdashboard](https://pkgs.rstudio.com/flexdashboard/index.html)
- Data - [coronavirus](https://github.com/RamiKrispin/coronavirus)
- Data visualization - [highcharter](https://jkunst.com/highcharter/index.html)
- Utility - [dplyr](https://dplyr.tidyverse.org/), [tidyr](https://tidyr.tidyverse.org/), [lubridate](https://lubridate.tidyverse.org/)

## Dashboard prototype

After setting a clear scope, I found it useful to prototype and put your thoughts on a piece of paper, [drow.io](https://www.diagrams.net/), iPad, or any other tool you find useful. The goal is to translate the scope into some sketches to understand the data inputs, required transformation, type of visualization, etc. In addition, a narrow scope with a good prototype will potentially save you some time and cycles when starting to code the dashboard. That being said, you should stay open-minded to changes in the final output, as what may look nice on the sketch may turn out less appealing on the final output. 

<img src="images/dash_prototype01.png" width="100%" />

<br>
As the focus of this tutorial is on the deployment itself and not on the data visualization, we will keep the dashboard simple and create the following three plots:

- Daily new cases (either by continent or worldwide), using scatter plot with trend line
- Daily death cases (either by continent or worldwide), using scatter plot with trend line
- Distribution of cases by country using treemap plot

We will leverage the [highcharter](https://jkunst.com/highcharter/index.html) package to create those plots.

<img src="images/dash_prototype02.png" width="100%" />

<br>

Once we have defined the scope and have a simple prototype, we better understand the dashboard requirements (e.g., data, packages, etc.), and we can move to the next step - setting the Docker environment. 

<br>

## Set Docker environment

There are multiple approaches for setting a Docker environment with the [Dockerfile](https://docs.docker.com/engine/reference/builder/). My approach is to minimize the `Dockerfile` by using utility files and automating the process with `bash` scrip. This makes the `Dockerfile` cleaner, yielding a smaller image size with fewer layers. Below is the tree of the `docker` folder in this tutorial:

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

Before diving into more details, let's review the `Dockerfile`.

### The Dockerfile

The `Dockerfile` provides a set of instructions for the docker engine to build the image. You can think about it as the image's recipe. It has its own unique and intuitive syntax following this structure:

``` dockerfile
COMMAND some instructions
```

Docker can build images automatically by reading the instructions from a Dockerfile. In this tutorial, we will use the following `Dockerfile`:

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
The above Dockerfile has the following five components:
- **Base image** - We will use the [rocker/rstudio:4.2`](https://hub.docker.com/r/rocker/rstudio/tags) image as the base image for this project. This image contains R version 4.2.0 and the RStudio server installed and will be used as the development environment.
- **Disabling the authentication** - By default, the RStudio server requires a user name and password. We will use the `ENV` command to define the environment variable `USER` and set it as `rstudio` and the `CMD` command to disable the authentication step. # TODO check if the first step is needed...
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

To build the Docker image, we will use `build_docker.sh` file, which builds and push the image to Docker Hub:

``` bash
#!/bin/bash

echo "Build the docker"

docker build . -t rkrispin/flex_dash_env:dev.0.0.0.9000

if [[ $? = 0 ]] ; then
echo "Pushing docker..."
docker push rkrispin/flex_dash_env:dev.0.0.0.9000
else
echo "Docker build failed"
fi
```

This `bash` script simply builds the docker and tags it as `rkrispin/flex_dash_env:dev.0.0.0.9000`, and then, if the build was successful, push it to Docker Hub. To execute this script from the command line:

```shell
bash build_docker.sh
```

### Lunching the development environment

There are multiple methods to spin a docker image into a running containter. Before going to the robust method using the `docker-compose`, let's review the basic method with the `run` command:

``` shell
docker run -d -p 8787:8787 rkrispin/flex_dash_env:dev.0.0.0.9000
```

The `docker run` command (or `run` in short) enables you to launch a container. In the above example, we used the following arguments:
* `-d` (or detach mode) to run the container in the background and 
* `-p` argument maps between the container and the local machine ports, where the right to the `:` symbol represents the port that is exposed on the container and the one on the left represents the port on the local machine. In the above example, we mapped port 8787 on the docker to port 8787 on the local machine

We close the `run` command with the name of the image we want to launch.


**Note:** If you got the following error, check if your Docker desktop is open:

``` shell
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?.
See 'docker run --help'.
```

If the image is unavailable locally, it will try to pull it from the default hub (make sure you logged in, it might take a few minutes to download it). If the image was successfully launched, it should return the container ID, for example:

``` shell
ac26ec61e71bc570a2ed769ba2b0dbef964d536f7d7cc51b61ea3e8542953cb1
```

You can use the `docker ps` command to check if the image is running:
``` shell
docker ps

CONTAINER ID   IMAGE                                   COMMAND                  CREATED         STATUS         PORTS                    NAMES
ac26ec61e71b   rkrispin/flex_dash_env:dev.0.0.0.9000   "/usr/lib/rstudio-se…"   4 minutes ago   Up 4 minutes   0.0.0.0:8787->8787/tcp   sweet_elion
```

Now you can go to your browser and use `http://localhost:8787` to access the Rstudio server from the browser:

<img src="images/rstudio01.png" width="100%" />

<br>

Does it sufficient to start developing our dashboard? The answer is **NO**! 

<br>

We have a functional environment, yet we are still missing a couple of elements to make this container fully functional as a development environment. For example, although we can access the container from the browser, it is still an isolated environment as we can't save or commit changes in the code. Let's add the `-v` argument to mount a local volume with the container. This will enable you to work inside the container and read and write data from your local machine. If the container is already running, use the `docker kill` (yes, not the best wording for a command...) following by the container ID (see the `docker ps` output for the container ID) to stop the running containers:

``` shell
docker kill ac26ec61e71b
```
Let's repeat the previous command and add the `-v` argument to mount the container to your local folder:

```shell
docker run -d -p 8787:8787 -v $TUTORIAL_WORKING_DIR:/home/rstudio/flexdash rkrispin/flex_dash_env:dev.0.0.0.9000
```

You can see now, after applying and refreshing the container, that the `flexdash` folder (marked with a green rectangle) is now available inside the container:

<img src="images/rstudio02.png" width="100%" />

Note that `$TUTORIAL_WORKING_DIR` is the environment variable that I set with the local folder path on my machine, and `/home/rstudio/` is the root folder on the container, and `flexdash` is the name of the mounted folder inside the container. To run it on your local machine, you should modify in the following example `YOUR_LOCAL_PATH` with your folder local path and `FOLDER_NAME` with the name you want to use for this mount volume inside the container:

``` shell
docker run -d -p 8787:8787 -v YOUR_LOCAL_PATH:/home/rstudio/FOLDER_NAME rkrispin/flex_dash_env:dev.0.0.0.9000
```

Does it sufficent to start develop our dashboard? Technicly, yes, we can now develop and text our code inside the container and save the changes on the local folder (and commit the changes with `git`).  But before we continue, let's mount our local RStudio config file with the one on the container. This will  mirror your local RStudio setting to the RStudio server running inside the container:

``` shell
docker run -d -p 8787:8787 \
 -v YOUR_LOCAL_PATH:/home/rstudio/FOLDER_NAME \
 -v $RSTUDIO_CONFIG_PATH:/home/rstudio/.config/rstudio \
 rkrispin/flex_dash_env:dev.0.0.0.9000
```

Now, I have inside the container the same setting (e.g., color theme, code snippets, etc.):

<img src="images/rstudio03.png" width="100%" />

**Note:** Your local R setting file should be, by default, under your root folder, for example, the path on my machine - `/Users/ramikrispin/.config/rstudio`.

As you add more elements to the `docker run`, it becomes convoluted to run it each time you want to spin the container. The `docker-compose` command provides a more concise method to launch a docker container using the `docker-compose.yml` file to set the docker run arguments and use the `docker-compose up` command to launch to the container (and `docker-compose down` to turn it off). Following the above example, here is how we customize those options with `docker-compose`: 

`docker-compose.yml`:
``` bash
version: "3.9"
services:
  rstudio:
    image: "$FLEX_IMAGE" 
    ports:
      - "8787:8787"
    volumes:
      - type: "bind"
        source: "$TUTORIAL_WORKING_DIR"
        target: "/home/rstudio"
      - type: "bind"
        source: "$RSTUDIO_CONFIG_PATH"
        target: "/home/rstudio/.config/rstudio"
```

Once you understand how `docker run` is working, it is straightforward to understand, set, and modify the above `docker-compose.yml` file according to your needs. As before, we set the image, ports, and volumes in the corresponding sections of the `yaml` file. Note that I am using three environment variables to set the docker image (`FELX_IMAGE`), the local folder to mount (`TUTORIAL_WORKING_DIR`), and the RStudio config file (`RSTUDIO_CONFIG_PATH`). Typically, this file is saved on the project/repository root folder. To launch the docker, from the path of the file, run on the command line:

``` shell
docker-compose up -d
```
Like before, we added the detach argument `-d` to keep the terminal free after launching the container. When you are done with the container, you can turn it off by using:

``` shell
docker-compose down
```

### Castumize the image

If the above packages (in the `packages.json` file) meet your requirements, then you are good to go and start to develop (with minimal effort in setting your global environment variables). If you have additional or different requirements, you can update the `packages.json` file according to your environment requirements and re-build the docker image using the `build_docker.sh` file. The only caveat for this is that for some packages, you may need to install additional **Debian** packages and may need to update the `Dockerfile` accordingly.



## Prototype the dashboard data visualization

## Dashboard development

## Deploy on Github Pages

## Set automation with Github Actions



