Pod::Spec.new do |spec|
  # Spec Metadata
  spec.name         = "HyperTrackViews"
  spec.version      = "0.1.0"
  spec.summary      = "Get HyperTrack data directly on your iOS app to build views"
  spec.description  = "The iOS Views SDK is used for getting live location and movement data for devices and trips directly to your iOS app."
  spec.homepage     = "https://hypertrack.com"
  spec.license      = { :type => "Copyright", :text => "Copyright (c) 2018 HyperTrack, Inc. (https://www.hypertrack.com)" }
  spec.author       = "HyperTrack Inc."
  # Platform Specifics
  spec.platform     = :ios, "11.2"
  # Source Location
  spec.source       = { :http => "https://github.com/hypertrack/views-ios/releases/download/#{spec.version}/#{spec.name}.zip" }
  # Source Code
  spec.source_files  = "#{spec.name}"
  # Resources
  spec.resources = "#{spec.name}/*.graphql", "#{spec.name}/*.json"
  # Project Settings
  spec.dependency "AWSAppSync", "2.14.1"
end