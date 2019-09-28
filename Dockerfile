FROM jekyll/jekyll:3.8.5
WORKDIR /app

CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0"]