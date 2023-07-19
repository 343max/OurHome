FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY tsconfig.json ./
COPY src ./src

RUN echo "export const buildInfo = { date: '$(date)' }" > ./src/lib/buildinfo.ts

ENV NODE_PATH=/app
RUN npm run build
RUN find /app