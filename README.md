# pixi-rstudio-docker

An attempt at a Docker container that:
- Runs RStudio server
- Reads pixi.toml from outside the container and creates that environment inside the container, where this is the working package environment for the RStudio user (`rstudio`). 
