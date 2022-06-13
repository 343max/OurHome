#!/bin/bash

convert () {
  qlmanage -t -s $1 -o . AppIcon.svg

  mv AppIcon.svg.png "$2"
}

mkdir Icons

# AppleWatch
convert 48 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-48.png"
convert 55 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-55.png"
convert 58 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-58.png"
convert 66 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-66.png"
convert 80 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-80.png"
convert 87 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-87.png"
convert 88 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-88.png"
convert 92 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-92.png"
convert 100 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-100.png"
convert 102 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-102.png"
convert 172 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-172.png"
convert 196 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-196.png"
convert 216 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-216.png"
convert 234 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-234.png"
convert 1024 "WatchKit App/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

# iOS & iPadOS

convert 20 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-20.png
convert 29 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-29.png
convert 40 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-40.png
convert 58 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-58.png
convert 60 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-60.png
convert 76 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-76.png
convert 80 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-80.png
convert 87 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-87.png
convert 120 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-120.png
convert 152 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-152.png
convert 167 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-167.png
convert 180 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-180.png

# AppStore

convert 1024 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
