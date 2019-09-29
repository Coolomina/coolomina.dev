#!/bin/sh

envsubst < /tmp/nginx.conf.tpl > /etc/nginx/conf.d/default.conf

nginx -g daemon off
