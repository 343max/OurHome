#!/bin/sh

docker run --network=host --device=/dev/ttyUSB0:/dev/buzzer -it -v $PWD:$PWD -w $PWD node:20-alpine npm $@
