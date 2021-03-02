#!/usr/bin/env bash

set -e

xcodebuild test -scheme "MapboxDirections iOS" -destination "platform=iOS Simulator,name=iPhone 8" | xcpretty -r junit --output test-reports/TEST-MBDirections.xml && exit ${PIPESTATUS[0]}
