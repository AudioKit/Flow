#!/bin/bash

# Our first argument is the scheme.
scheme=$1

xcodebuild clean build -project Demo/FlowDemo.xcodeproj -scheme 'FlowDemo (iOS)' CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

# -sdk iphonesimulator -scheme FlowDemo -arch x86_64 ONLY_ACTIVE_ARCH=YES CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" clean build | xcpretty -c
