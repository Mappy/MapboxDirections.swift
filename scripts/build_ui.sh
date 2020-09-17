#!/usr/bin/env bash

set -e

xcodebuild clean build -scheme "Example (Swift)" -destination "platform=iOS Simulator,name=iPhone 8" | xcpretty && exit ${PIPESTATUS[0]}
