FROM alpine as build

ARG HUGO_VERSION=0.110.0
ARG GITHUB_USER=chrisb86
ARG GITHUB_REPOSITORY=christianbaer.me

ADD https://github.com/gohugoio/hugo/releases/download/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /hugo.tar.gz
RUN tar -zxvf hugo.tar.gz
RUN /hugo version

RUN apk add --no-cache git

COPY ./ /site

WORKDIR /site
RUN ls /site
RUN cp hugo.toml config.toml ## Backwards compatibility

# Cache Bust upon new commits
ADD https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPOSITORY}/git/refs/heads/master /.git-hashref

RUN /hugo --gc --enableGitInfo

FROM nginxinc/nginx-unprivileged
COPY --from=build /site/public /usr/share/nginx/html

EXPOSE 8080