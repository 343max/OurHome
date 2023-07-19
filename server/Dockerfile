FROM node:20

WORKDIR /app

COPY tsconfig.json ./
COPY src ./src
COPY package*.json ./

RUN npm ci --omit=dev

ENV NODE_PATH=/app
RUN npm run build
RUN find /app