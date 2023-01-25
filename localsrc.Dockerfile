FROM alpine as build
RUN apk add --no-cache hugo
WORKDIR /src
COPY ./data .
RUN hugo --minify --gc

FROM nginxinc/nginx-unprivileged
COPY --from=build /src/public /usr/share/nginx/html

EXPOSE 8080
