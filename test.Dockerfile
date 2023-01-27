FROM alpine as build
RUN apk add --no-cache git hugo

#RUN git clone https://github.com/chrisb86/christianbaer.me /site

COPY ./ /site

WORKDIR /site
RUN ls /site
RUN cp hugo.toml config.toml ## Backwards compatibility

# Cache Bust upon new commits
ADD https://api.github.com/repos/chrisb86/christianbaer.me/git/refs/heads/master /.git-hashref

RUN hugo --gc --enableGitInfo

FROM nginxinc/nginx-unprivileged
COPY --from=build /site/public /usr/share/nginx/html

EXPOSE 8080