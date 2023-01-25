FROM alpine as build
RUN apk add --no-cache git hugo

RUN git clone https://github.com/chrisb86/christianbaer.me /site

WORKDIR /site
RUN hugo --gc --enableGitInfo

FROM nginxinc/nginx-unprivileged
COPY --from=build /site/public /usr/share/nginx/html

EXPOSE 8080
