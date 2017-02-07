//
//  IGZLocationManagerExtension.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

extension IGZLocation: IGZLocationManager {

    public static var shared: IGZLocationManager = IGZLocation()

    public var authorized: Bool {
        return authorized(authorization)
    }

    public var locationAvailable: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    public var headingAvailable: Bool {
        return CLLocationManager.headingAvailable()
    }
    public var significantLocationAvailable: Bool {
        return CLLocationManager.significantLocationChangeMonitoringAvailable()
    }
    public var deferredLocationAvailable: Bool {
        return CLLocationManager.deferredLocationUpdatesAvailable()
    }
    public var authorization: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    public var location: CLLocation? {
        return locationManager.location
    }
    public var heading: CLHeading? {
        return locationManager.heading
    }
    public var maximumRegionDistance: CLLocationDistance {
        return locationManager.maximumRegionMonitoringDistance
    }
    public var regions: Set<CLRegion> {
        return locationManager.monitoredRegions
    }

    public var activity: CLActivityType {
        get {
            return locationManager.activityType
        }
        set {
            locationManager.activityType = newValue
        }
    }
    public var distanceFilter: CLLocationDistance {
        get {
            return locationManager.distanceFilter
        }
        set {
            locationManager.distanceFilter = newValue
        }
    }
    public var accuracy: CLLocationAccuracy {
        get {
            return locationManager.desiredAccuracy
        }
        set {
            locationManager.desiredAccuracy = newValue
        }
    }
    public var pausesAutomatically: Bool {
        get {
            return locationManager.pausesLocationUpdatesAutomatically
        }
        set {
            locationManager.pausesLocationUpdatesAutomatically = newValue
        }
    }
    public var background: Bool {
        get {
            if #available(iOS 9.0, *) {
                return locationManager.allowsBackgroundLocationUpdates
            } else {
                return false
            }
        }
        set {
            guard #available(iOS 9.0, *) else {
                let error = NSError(domain: kCLErrorDomain, code: CLError.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Background location updates is only available on iOS 9 or newer."])
                let backgroundError = IGZLocationError(error)
                for delegate in delegates {
                    delegate.didFail?(backgroundError)
                }
                for errorHandler in errorHandlers {
                    errorHandler(backgroundError)
                }
                return
            }
            if let backgroundModes = Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String], backgroundModes.contains("location") {
                locationManager.allowsBackgroundLocationUpdates = newValue
            }
            else {
                let error = NSError(domain: kCLErrorDomain, code: CLError.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "The app's Info.plist must contain an UIBackgroundModes key with \"location\" value."])
                let backgroundError = IGZLocationError(error)
                for delegate in delegates {
                    delegate.didFail?(backgroundError)
                }
                for errorHandler in errorHandlers {
                    errorHandler(backgroundError)
                }
            }
        }
    }
    public var headingFilter: CLLocationDegrees {
        get {
            return locationManager.headingFilter
        }
        set {
            locationManager.headingFilter = newValue
        }
    }
    public var orientation: CLDeviceOrientation {
        get {
            return locationManager.headingOrientation
        }
        set {
            locationManager.headingOrientation = newValue
        }
    }

    public func shouldDisplayHeadingCalibration(_ display: Bool = true) {
        displayHeadingCalibration = display
    }

    public func dismissHeadingCalibration() {
        locationManager.dismissHeadingCalibrationDisplay()
    }

    public func regionAvailable(_ regionClass: CLRegion.Type) -> Bool {
        return CLLocationManager.isMonitoringAvailable(for: regionClass)
    }

    public func authorized(_ status: CLAuthorizationStatus) -> Bool {
        return status.rawValue >= CLAuthorizationStatus.authorizedAlways.rawValue
    }

    public func authorize(_ status: CLAuthorizationStatus, _ handler: IGZAuthorizationHandler? = nil) -> Bool {
        guard status != authorization else {
            if let handler = handler {
                handler(status)
            }
            return true
        }
        if let handler = handler {
            authorizationTemporaryHandlers.append(handler)
        }
        switch status {
        case .authorizedAlways:
            locationManager.requestAlwaysAuthorization()
            return true
        case .authorizedWhenInUse:
            locationManager.requestWhenInUseAuthorization()
            return true
        default:
            let error = NSError(domain: kCLErrorDomain, code: CLError.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "This app has attempted to access location data without user's authorization."])
            let authorizationError = IGZLocationError(error)
            for delegate in delegates {
                delegate.didFail?(authorizationError)
            }
            for errorHandler in errorHandlers {
                errorHandler(authorizationError)
            }
            return false
        }
    }

    public func startLocationUpdates(_ handler: IGZLocationsHandler? = nil) {
        guard authorized && locationAvailable else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    if let handler = handler {
                        self.locationsTemporaryHandlers.append(handler)
                    }
                    self.locationManager.startUpdatingLocation()
                }
            })
            return
        }

        if let handler = handler {
            locationsTemporaryHandlers.append(handler)
        }
        locationManager.startUpdatingLocation()
    }

    public func stopLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationTemporaryHandlers.removeAll()
        locationManager.stopUpdatingLocation()
    }

    public func requestLocation(_ handler: IGZLocationHandler? = nil) {
        guard #available(iOS 9.0, *) else {
            let error = NSError(domain: kCLErrorDomain, code: CLError.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Request location is only available on iOS 9 or newer."])
            let backgroundError = IGZLocationError(error)
            for delegate in delegates {
                delegate.didFail?(backgroundError)
            }
            for errorHandler in errorHandlers {
                errorHandler(backgroundError)
            }
            return
        }

        guard authorized && locationAvailable else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    if let handler = handler {
                        self.locationTemporaryHandlers.append(handler)
                    }
                    self.locationManager.requestLocation()
                }
            })
            return
        }

        if let handler = handler {
            locationTemporaryHandlers.append(handler)
        }
        locationManager.requestLocation()
    }

    public func startHeadingUpdates(_ handler: IGZHeadingHandler? = nil) {
        guard authorized && headingAvailable else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    if let handler = handler {
                        self.headingTemporaryHandlers.append(handler)
                    }
                    self.locationManager.startUpdatingHeading()
                }
            })
            return
        }

        if let handler = handler {
            headingTemporaryHandlers.append(handler)
        }
        locationManager.startUpdatingHeading()
    }

    public func stopHeadingUpdates() {
        headingTemporaryHandlers.removeAll()
        locationManager.stopUpdatingHeading()
    }

    public func startSignificantLocationUpdates(_ handler: IGZLocationsHandler? = nil) {
        guard authorized && significantLocationAvailable else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    if let handler = handler {
                        self.locationsTemporaryHandlers.append(handler)
                    }
                    self.locationManager.startMonitoringSignificantLocationChanges()
                }
            })
            return
        }

        if let handler = handler {
            locationsTemporaryHandlers.append(handler)
        }
        locationManager.startMonitoringSignificantLocationChanges()
    }

    public func stopSignificantLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    public func startRegionUpdates(_ region: CLRegion, sequential: Bool = false, notify: Bool? = nil, _ handler: IGZRegionHandler? = nil) {
        if let notify = notify {
            region.notifyOnEntry = notify
            region.notifyOnExit = notify
        }
        guard authorized && regionAvailable(type(of: region)) && (region as? CLCircularRegion)?.radius ?? 0 < maximumRegionDistance else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.sequentialRegions = sequential
                    if let handler = handler {
                        self.regionTemporaryHandlers.append(handler)
                    }
                    self.locationManager.startMonitoring(for: region)
                }
            })
            return
        }

        sequentialRegions = sequential
        if let handler = handler {
            regionTemporaryHandlers.append(handler)
        }
        locationManager.startMonitoring(for: region)
    }

    public func stopRegionUpdates(_ region: CLRegion? = nil) -> Bool {
        guard regions.count > 0 else {
            let error = NSError(domain: kCLErrorDomain, code: CLError.regionMonitoringDenied.rawValue, userInfo: [NSLocalizedDescriptionKey: "You don't have any monitored regions."])
            let regionError = IGZLocationError(error)
            for delegate in delegates {
                delegate.didFail?(regionError)
            }
            for errorHandler in errorHandlers {
                errorHandler(regionError)
            }
            return false
        }

        sequentialRegions = false
        regionTemporaryHandlers.removeAll()
        if let region = region {
            locationManager.stopMonitoring(for: region)
        }
        else {
            for region in regions {
                locationManager.stopMonitoring(for: region)
            }
        }
        return true
    }

    public func requestRegion(_ region: CLRegion? = nil, _ handler: IGZRegionHandler? = nil) -> Bool {
        guard regions.count > 0 else {
            let error = NSError(domain: kCLErrorDomain, code: CLError.regionMonitoringDenied.rawValue, userInfo: [NSLocalizedDescriptionKey: "You don't have any monitored regions."])
            let regionError = IGZLocationError(error)
            for delegate in delegates {
                delegate.didFail?(regionError)
            }
            for errorHandler in errorHandlers {
                errorHandler(regionError)
            }
            return false
        }

        guard authorized && regionAvailable(region != nil ? type(of: region!) : CLRegion.self) else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    if let handler = handler {
                        self.regionTemporaryHandlers.append(handler)
                    }
                    if let region = region {
                        self.locationManager.requestState(for: region)
                    }
                    else {
                        for region in self.regions {
                            self.locationManager.requestState(for: region)
                        }
                    }
                }
            })
            return true
        }

        if let handler = handler {
            regionTemporaryHandlers.append(handler)
        }
        if let region = region {
            locationManager.requestState(for: region)
        }
        else {
            for region in regions {
                locationManager.requestState(for: region)
            }
        }
        return true
    }

    public func startDeferredLocationUpdates(distance: CLLocationDistance, timeout: TimeInterval, _ handler: IGZLocationsHandler? = nil) {
        guard authorized && deferredLocationAvailable else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    if let handler = handler {
                        self.locationsTemporaryHandlers.append(handler)
                    }
                    self.locationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
                }
            })
            return
        }

        if let handler = handler {
            locationsTemporaryHandlers.append(handler)
        }
        locationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
    }

    public func stopDeferredLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationManager.disallowDeferredLocationUpdates()
    }

    public func startVisitUpdates(_ handler: IGZVisitHandler? = nil) {
        guard authorized else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    if let handler = handler {
                        self.visitTemporaryHandlers.append(handler)
                    }
                    self.locationManager.startMonitoringVisits()
                }
            })
            return
        }

        if let handler = handler {
            visitTemporaryHandlers.append(handler)
        }
        locationManager.startMonitoringVisits()
    }

    public func stopVisitUpdates() {
        visitTemporaryHandlers.removeAll()
        locationManager.stopMonitoringVisits()
    }
    
}
