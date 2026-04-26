FROM rocker/rstudio:latest

# Install system tools as root
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    git \
    vim \
    python3 \
    python3-pip \
    ca-certificates \
    && update-ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch to the built-in rstudio user
USER rstudio
WORKDIR /home/rstudio

# Install Pixi as the rstudio user
RUN curl -fsSL https://pixi.sh/install.sh | bash

# Ensure Pixi is on PATH for non-interactive shells
ENV PATH="/home/rstudio/.pixi/bin:${PATH}"

# Copy only the Pixi environment files first (cache-friendly)
COPY --chown=rstudio:rstudio project/pixi.toml project/pixi.lock* /home/rstudio/project/

# Build the Pixi environment for linux-64 only, and build .pixi in the project folder
WORKDIR /home/rstudio/project
RUN PIX_PLATFORM=linux-64 pixi install

EXPOSE 8787

# Uncomment this if you get a warning similar to this:
#
#  WARN Skipped running the post-link scripts because `run-post-link-scripts` = `false`
#
# RUN pixi config set --local run-post-link-scripts insecure

USER root
RUN echo "rsession-which-r=/home/rstudio/.pixi/envs/default/bin/R" \
    > /etc/rstudio/rserver.conf

# CMD ["bash"]
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0"]
