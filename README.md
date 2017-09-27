# IGZLocation

[![Twitter](https://img.shields.io/badge/contact-@intelygenz-0FABFF.svg?style=flat)](http://twitter.com/intelygenz)
[![Version](https://img.shields.io/cocoapods/v/IGZLocation.svg?style=flat)](http://cocoapods.org/pods/IGZLocation)
[![License](https://img.shields.io/cocoapods/l/IGZLocation.svg?style=flat)](http://cocoapods.org/pods/IGZLocation)
[![Platform](https://img.shields.io/cocoapods/p/IGZLocation.svg?style=flat)](http://cocoapods.org/pods/IGZLocation)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager Compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Build Status](https://travis-ci.org/intelygenz/IGZLocation.svg?branch=master)](https://travis-ci.org/intelygenz/IGZLocation)

CLLocationManager Swift 4 wrapper with multiple closure handlers and delegates allowed, notifications, sequential geofencing, self-authorization and, of course, everything is testable. #InCodeWeTrust

![IGZLocation Screenshot](https://raw.githubusercontent.com/intelygenz/IGZLocation/master/screenshot.gif)

## Installation

IGZLocation is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "IGZLocation"
```

For Swift 3 compatibility use:

```ruby
pod 'IGZLocation', '~> 1.0'
```

#### Or you can install it with [Carthage](https://github.com/Carthage/Carthage):

```ogdl
github "intelygenz/IGZLocation"
```

#### Or install it with [Swift Package Manager](https://swift.org/package-manager/):

```swift
dependencies: [
    .Package(url: "https://github.com/intelygenz/IGZLocation.git")
]
```

## Usage

```swift
_ = IGZLocation.shared.authorize(.authorizedAlways) { status in
	
}

IGZLocation.shared.requestLocation { location in
	
}

IGZLocation.shared.startRegionUpdates(region, sequential: true, notify: true, { region, state in
	
})

IGZLocation.shared.startVisitUpdates { visit, visiting in
	
}

IGZLocation.shared.startHeadingUpdates { heading in
	
}
```

## Etc.

* Contributions are very welcome.
* Attribution is appreciated (let's spread the word!), but not mandatory.

## Author

[alexruperez](https://github.com/alexruperez), alejandro.ruperez@intelygenz.com

## License

IGZLocation is available under the MIT license. See the LICENSE file for more info.
