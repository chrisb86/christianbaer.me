FROM alpine as build

## Set some variables
ARG HUGO_VERSION=0.110.0
ARG GITHUB_USER=chrisb86
ARG GITHUB_REPOSITORY=christianbaer.me

RUN apk update && apk add tzdata
ENV TZ="Europe/Berlin"

## Download Hugo from github
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /hugo.tar.gz
RUN tar -zxvf hugo.tar.gz

## Install git for gitInfo support in Hugo 
RUN apk add --no-cache git

## Copy site sources to /site
COPY ./ /site
WORKDIR /site

# Cache Bust upon new commits
ADD https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPOSITORY}/git/refs/heads/master /.git-hashref

## Run Hugo
RUN /hugo --gc

## Copy rendered site to nginx image
FROM nginxinc/nginx-unprivileged
COPY --from=build /site/public /usr/share/nginx/html

## Expose port 8080 to docker
EXPOSE 8080