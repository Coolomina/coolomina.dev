FROM jekyll/jekyll:3.8.5 as base
ENV WORKDIR /app
WORKDIR /app

FROM base as development
CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0"]

FROM base as release-build
COPY . ${WORKDIR}
RUN bundle install -j 10 --full-index && \
    chown -R jekyll "${WORKDIR}" && \
    jekyll build

FROM nginx:1.17-alpine as release

ENV USER deploy
ENV NGINX_HOME /etc/nginx

RUN addgroup -g 1000 -S ${USER} && \
    adduser -u 1000 -S ${USER} -G ${USER} && \
    touch /var/run/nginx.pid && \
    chown -R ${USER}:${USER} \
      /var/cache/nginx \
      /var/run/nginx.pid \
      /usr/share/nginx/html \
      /var/log/nginx

USER ${USER}

COPY nginx.conf /tmp/nginx.conf.tpl
COPY --from=release-build --chown=deploy:deploy /app/_site /usr/share/nginx/html/

CMD ["./cmd.sh"]