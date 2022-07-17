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
- **Develop** - start to build the dashboard
- **Deploy** - push the dashboard to Github Pages 
- **Automate** - build the dashboard refresh with Github Actions

Typically, you may update the Docker image throughout the development process if additional requirements (or dependencies) beyond the scope will be needed.


**TODO - add architect diagram**


## Dashboard scope

## Set Docker environment


``` shell
.
├── Dockerfile
├── build_docker.sh
├── install_packages.R
└── packages.json
```

## Dashboard development

## Deploy on Github Pages

## Set automation with Github Actions


### Set environment with Docker


