FROM node:10.12.0-alpine

RUN apk --update add \
      git && \
    npm i -g yarn @vue/cli npm-check-updates

WORKDIR /web
