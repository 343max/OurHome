#!/bin/bash

convert () {
  qlmanage -t -s $1 -o . AppIcon.svg

  mv AppIcon.svg.png "$2"
}

mkdir Icons

# watchOS
convert 1024 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

# iOS & AppStore

convert 1024 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
