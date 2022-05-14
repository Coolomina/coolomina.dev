FROM node:18-slim
WORKDIR /app
RUN apt update -y && apt install -y curl git
RUN curl -fsSL https://raw.github.com/Cveinnt/LiveTerm/main/install/install.sh | sh
WORKDIR /app/LiveTerm
