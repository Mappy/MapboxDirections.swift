#!/usr/bin/env bash

set -e

SIMULATOR_VERSION=11.4

xcodebuild test -scheme "MapboxDirections iOS" -destination "platform=iOS Simulator,name=iPhone 8,OS=${SIMULATOR_VERSION}" | xcpretty -r junit --output test-reports/TEST-MBDirections.xml && exit ${PIPESTATUS[0]}

