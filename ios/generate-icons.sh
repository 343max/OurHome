#!/bin/bash

convert () {
  qlmanage -t -s $1 -o . AppIcon.svg

  mv AppIcon.svg.png "$2"
}

mkdir Icons

# AppleWatch
convert 48 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-48.png"
convert 55 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-55.png"
convert 58 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-58.png"
convert 66 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-66.png"
convert 80 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-80.png"
convert 87 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-87.png"
convert 88 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-88.png"
convert 92 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-92.png"
convert 100 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-100.png"
convert 102 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-102.png"
convert 172 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-172.png"
convert 196 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-196.png"
convert 216 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-216.png"
convert 234 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-234.png"
convert 1024 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

# iOS & AppStore

convert 1024 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
