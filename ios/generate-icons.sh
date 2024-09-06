#!/bin/bash

convert () {
  sips -s format png $1.svg --resampleWidth $2 --resampleHeight $2 --out $3
}

mkdir Icons

# watchOS
convert AppIcon 1024 "Watch/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"

# iOS & AppStore

convert AppIcon 1024 iOS/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png
convert AppIconDark 1024 iOS/Assets.xcassets/AppIcon.appiconset/AppIconDark-1024.png
convert AppIconTinted 1024 iOS/Assets.xcassets/AppIcon.appiconset/AppIconTinted-1024.png
