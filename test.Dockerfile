FROM alpine as build

ADD . /site

RUN apk add --no-cache git hugo

WORKDIR /site
RUN hugo --gc --enableGitInfo

FROM nginxinc/nginx-unprivileged
COPY --from=build /site/public /usr/share/nginx/html

EXPOSE 8080