Pod::Spec.new do |spec|
  # Spec Metadata
  spec.name                = "HyperTrackViews"
  spec.version             = "0.7.0"
  spec.summary             = "Get HyperTrack data directly on your iOS app to build views"
  spec.description         = "The iOS Views SDK is used for getting live location and movement data for devices and trips directly to your iOS app."
  spec.homepage            = "https://hypertrack.com"
  spec.license             = { :type => "Copyright", :text => "Copyright (c) 2018 HyperTrack, Inc. (https://www.hypertrack.com)" }
  spec.author              = "HyperTrack Inc."
  # Platform Specifics
  spec.platform            = :ios, "9.0"
  # Source Location
  spec.source              = { :http => "https://github.com/hypertrack/views-ios/releases/download/#{spec.version}/#{spec.name}.zip" }
  # Source Code

  spec.subspec "Core" do |subspec|
    subspec.source_files   = "*"
    subspec.exclude_files  = "MapKit.swift"
  end

  spec.subspec "MapKit" do |subspec|
    subspec.dependency       "HyperTrackViews/Core"
    subspec.source_files   = "MapKit.swift"
    subspec.ios.frameworks = 'MapKit'
  end

  spec.default_subspec     = "Core"


  spec.swift_versions      = ['4.2', '5.0']
  # Project Settings
  spec.dependency            "AWSAppSync", "3.0.2"
end
