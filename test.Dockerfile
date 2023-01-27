FROM alpine as build
RUN apk add --no-cache git hugo
RUN hugo --gc --enableGitInfo

FROM nginxinc/nginx-unprivileged
COPY --from=build ./public /usr/share/nginx/html

EXPOSE 8080
