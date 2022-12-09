#!/bin/bash

cd $( dirname -- "${BASH_SOURCE[0]}" )

docker run \
    --interactive \
    --tty \
    --rm \
    --volume $PWD:/app \
    --volume $HOME/.deno:/deno-dir \
    --workdir /app \
    denoland/deno:latest \
    deno $@