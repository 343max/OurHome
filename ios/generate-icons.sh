#!/bin/bash

convert () {
  qlmanage -t -s $1 -o . AppIcon.svg

  mv AppIcon.svg.png "Icons/AppIcon-$1.png"
}

mkdir Icons

# AppleWatch

# AppIcon
convert 48
convert 55
convert 66

# Notification Center
convert 58
convert 87

# Companion Settings
convert 80
convert 88
convert 92
convert 100
convert 102

# Home Screen
convert 172
convert 196
convert 216
convert 234

# AppStore
convert 1024