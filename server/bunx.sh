#!/bin/sh
echo $@
docker run -v $PWD:/app -w /app oven/bun:latest $@
