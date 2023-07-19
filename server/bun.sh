#!/bin/sh
echo $@
docker run -v $PWD:/app -w /app node:20-alpine node $@
