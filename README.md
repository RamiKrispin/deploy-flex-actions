## Deploy Flexdashboard on Github Pages with Github Actions and Docker

<img src="images/wip.png" width="10%" /> Work in progress...


This repo provides a guide and a template for deploying and refreshing a [flexdashboard](https://pkgs.rstudio.com/flexdashboard/) on Github Pages with Docker and Github Actions.

<a href='https://github.com/RamiKrispin/coronavirus_dashboard'><img src="images/flexdashboard_example.png" width="100%" /></a> 

### Motivation

As its name implies, the flexdashboard package provides a flexible framework for creating dashboards. It is part of the Rmarkdown ecosystem, and it enables the following:
* Easy layout customization based on rows and columns format
* Customize the dashboard view using CSS or the bslib package
Use value boxes
* Create interactive (and serverless) dashboards leveraging R data visualization tools (e.g., Plotly, highcharter, dychart, leaflet, etc.), tables (gt, reactable, reactablefrm, kable, etc.), and htmlwidges tools such as crosstalk.
* Build dynamic dashboards with Shiny 

This tutorial will focus on deploying flexdashboard to Github Pages and automating the dashboard data refresh with Github Actions and Docker. Both Github and Docker offer both enterprise and free tools, in this tutorial, we will use the free versions.

#### When to use Github Actions?

Github Actions is a CI/CD tool enabling scheduling and triggering jobs. In the context of R, there are many use cases:
- Triggering R CMD Check when pushing new code
- Data automation
- Scheduling R jobs
- Flexdashboard refreshing and automation