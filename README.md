# HyperTrack Views for iOS

![GitHub](https://img.shields.io/github/license/hypertrack/views-ios.svg)
![Cocoapods platforms](https://img.shields.io/cocoapods/p/HyperTrackViews.svg)
[![HyperTrackViews](https://img.shields.io/cocoapods/v/HyperTrackViews)](https://cocoapods.org/pods/HyperTrackViews)


HyperTrack Views library is used for getting live location and movement data for devices and trips directly to your iOS app. Library subscribes to HyperTrack's GraphQL server endpoints to get data streams and then renders it in useful callbacks for app developers to build beautiful tracking experiences. This helps developers create live location views and go serverless. Their app users can directly get data securely and privately from the HyperTrack servers.

## Run example app

This example app has Views library integrated and is ready to show your device's location on a map.

### Step 1: Clone this repo
```bash
git clone https://github.com/hypertrack/views-ios.git
cd views-ios
```

### Step 2: Install the SDK dependency

Example app uses [CocoaPods](https://cocoapods.org) dependency manager to install the latest version of the HyperTrackViews library. Using the latest version of CocoaPods is advised.

If you don't have CocoaPods, [install it first](https://guides.cocoapods.org/using/getting-started.html#installation).

Run `pod install` inside the cloned directory. After CocoaPods creates the `ViewsExample.xcworkspace` workspace file, open it with Xcode.

### Step 3: Set your Publishable Key and Device ID

Open the ViewsExample project inside the workspace and set your Publishable Key and Device ID inside the placeholder in the `ViewController.swift` file.

### Step 4: Run the ViewsExample app

Run the app on your phone or simulator and you should see the map with your device on it. You can see the subscription status and full MovementStatus data structure in Console logs inside Xcode (for apps built in DEBUG mode).

## Integrate HyperTrackViews library

### Requirements

HyperTrackViews supports iOS 11.2 and above, using Swift language.

#### Step 1: Add HyperTrackViews to your project

We use [CocoaPods](https://cocoapods.org) to distribute the library, you can [install it here](https://guides.cocoapods.org/using/getting-started.html#installation).

Using command line run `pod init` in your project directory to create a Podfile. Put the following code (changing target placeholder to your target name) in the Podfile:

```ruby
platform :ios, '11.2'
inhibit_all_warnings!

target '<Your app name>' do
  use_frameworks!
  pod 'HyperTrackViews'
end
```

Run `pod install`. CocoaPods will build the dependencies and create a workspace (`.xcworkspace`) for you.

#### Step 2: Create an instance

To create an instance of HyperTrackViews, pass it your publishable key:

```swift
let hyperTrackViews = HyperTrackViews(publishableKey: publishableKey)
```

You can initialize the library wherever you want. If reference gets out of scope, library will cancel all subscriptions and network state after itself.

#### Step 3: Get movement status of your device

You can get a snapshot of your device movement status with `movementStatus(for:completionHandler:)` function:

```swift
let cancel = hyperTrackViews.movementStatus(for: "Paste_Your_Device_ID_Here") { [weak self] result in
    guard let self = self else { return }

    switch result {
    case let .success(movementStatus):
        // Update your UI with movementStatus structure
    case let .failure(error):
        // React to errors
    }
}
```

Update your UI using data from MovementStatus structure.

You can use `cancel` function to cancel the request if you want, just run `cancel()` to cancel the request. You can ignore the return value from `movementStatus(for:completionHandler:)` by using `let _ = moveme...` pattern (The use of the pattern is needed until Apple will fix [SR-7297](https://bugs.swift.org/browse/SR-7297) bug).

#### Step 4: Subscribe to movement status updates

You can get movement status continuously every time it updates (device moves or if there are updates in other fields in MovementStatus structure). This function makes a `movementStatus(for:completionHandler:)` call under the hood, so you'll get initial status right away.

```swift
let cancel = hyperTrackViews.subscribeToMovementStatusUpdates(for: "Paste_Your_Device_ID_Here") { [weak self] result in
    guard let self = self else { return }

    switch result {
    case .success(let movementStatus):
        // Update your UI with movementStatus structure
    case .failure(let error):
        // React to subscription errors
    }
}
```

You need to hold on to the `cancel()` function until you don't need subscription results. If this function gets out of scope, subscription will automatically cancel and all network resources and memory will be released. This is useful if subscription is needed only while some view or controller is in scope.

#### You are all set
