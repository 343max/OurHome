FROM denoland/deno:latest

WORKDIR /app

COPY src/deps.ts /app/src/deps.ts
RUN deno cache src/deps.ts

COPY . /app
RUN echo "export const buildInfo = {date: '$(date)'}" > /app/src/lib/buildinfo.ts

USER deno

RUN deno cache src/main.ts

CMD ["run", "--allow-net", "--allow-env", "src/main.ts"]
