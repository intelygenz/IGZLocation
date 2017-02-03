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
            return locationManager.allowsBackgroundLocationUpdates
        }
        set {
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
            handler?(status)
            return true
        }
        authorizationTemporaryHandlers.append({ newStatus in handler?(newStatus) })
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
                    self.locationsTemporaryHandlers.append({ locations in handler?(locations) })
                    self.locationManager.startUpdatingLocation()
                }
            })
            return
        }

        locationsTemporaryHandlers.append({ locations in handler?(locations) })
        locationManager.startUpdatingLocation()
    }

    public func stopLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationTemporaryHandlers.removeAll()
        locationManager.stopUpdatingLocation()
    }

    public func requestLocation(_ handler: IGZLocationHandler? = nil) {
        guard authorized && locationAvailable else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.locationTemporaryHandlers.append({ location in handler?(location) })
                    self.locationManager.requestLocation()
                }
            })
            return
        }

        locationTemporaryHandlers.append({ location in handler?(location) })
        locationManager.requestLocation()
    }

    public func startHeadingUpdates(_ handler: IGZHeadingHandler? = nil) {
        guard authorized && headingAvailable else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.headingTemporaryHandlers.append({ heading in handler?(heading) })
                    self.locationManager.startUpdatingHeading()
                }
            })
            return
        }

        headingTemporaryHandlers.append({ heading in handler?(heading) })
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
                    self.locationsTemporaryHandlers.append({ locations in handler?(locations) })
                    self.locationManager.startMonitoringSignificantLocationChanges()
                }
            })
            return
        }

        locationsTemporaryHandlers.append({ locations in handler?(locations) })
        locationManager.startMonitoringSignificantLocationChanges()
    }

    public func stopSignificantLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    public func startRegionUpdates(_ region: CLRegion, sequential: Bool = false, _ handler: IGZRegionHandler? = nil) {
        guard authorized && regionAvailable(type(of: region)) else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.sequentialRegions = sequential
                    self.regionTemporaryHandlers.append({ region, state in handler?(region, state) })
                    self.locationManager.startMonitoring(for: region)
                }
            })
            return
        }

        sequentialRegions = sequential
        regionTemporaryHandlers.append({ region, state in handler?(region, state) })
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
            return true
        } else if let region = regions.first {
            locationManager.stopMonitoring(for: region)
            return true
        }
        return false
    }

    public func requestRegion(_ region: CLRegion? = nil, _ handler: IGZRegionHandler? = nil) -> Bool {
        var requestedRegion: CLRegion? = region
        if requestedRegion == nil {
            requestedRegion = regions.first
        }
        guard let region = requestedRegion else {
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
        guard authorized && regionAvailable(type(of: region)) else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.regionTemporaryHandlers.append({ region, state in handler?(region, state) })
                    self.locationManager.requestState(for: region)
                }
            })
            return true
        }

        regionTemporaryHandlers.append({ region, state in handler?(region, state) })
        locationManager.requestState(for: region)

        return true
    }

    public func startDeferredLocationUpdates(distance: CLLocationDistance, timeout: TimeInterval, _ handler: IGZLocationsHandler? = nil) {
        guard authorized && deferredLocationAvailable else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.locationsTemporaryHandlers.append({ locations in handler?(locations) })
                    self.locationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
                }
            })
            return
        }

        locationsTemporaryHandlers.append({ locations in handler?(locations) })
        locationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
    }

    public func stopDeferredLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationManager.disallowDeferredLocationUpdates()
    }

    public func startVisitUpdated(_ handler: IGZVisitHandler? = nil) {
        guard authorized else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.visitTemporaryHandlers.append({ visit, visiting in handler?(visit, visiting) })
                    self.locationManager.startMonitoringVisits()
                }
            })
            return
        }

        visitTemporaryHandlers.append({ visit, visiting in handler?(visit, visiting) })
        locationManager.startMonitoringVisits()
    }

    public func stopVisitUpdated() {
        visitTemporaryHandlers.removeAll()
        locationManager.stopMonitoringVisits()
    }
    
}
