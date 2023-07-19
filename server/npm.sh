#!/bin/sh

docker run --network=host -it -v $PWD:$PWD -w $PWD node:20-alpine npm $@
