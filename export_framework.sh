#!/bin/sh

xcodebuild -project LakestoneCore.xcodeproj -sdk iphoneos
cp -r build/Release-iphoneos/LakestoneCore.framework ../GeoBingAnKit/Frameworks/Device/
xcodebuild -project LakestoneCore.xcodeproj -sdk iphonesimulator
cp -r build/Release-iphonesimulator/LakestoneCore.framework ../GeoBingAnKit/Frameworks/Simulator/