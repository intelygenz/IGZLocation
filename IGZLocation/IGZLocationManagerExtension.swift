//
//  IGZLocationManagerExtension.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

extension IGZLocation: IGZLocationManager {

    open static var shared: IGZLocationManager = IGZLocation()

    open var authorized: Bool {
        return authorized(authorization)
    }

    open var locationAvailable: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    open var headingAvailable: Bool {
        return CLLocationManager.headingAvailable()
    }
    open var significantLocationAvailable: Bool {
        return CLLocationManager.significantLocationChangeMonitoringAvailable()
    }
    open var deferredLocationAvailable: Bool {
        return CLLocationManager.deferredLocationUpdatesAvailable()
    }
    open var authorization: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    open var location: CLLocation? {
        return locationManager.location
    }
    open var heading: CLHeading? {
        return locationManager.heading
    }
    open var maximumRegionDistance: CLLocationDistance {
        return locationManager.maximumRegionMonitoringDistance
    }
    open var regions: Set<CLRegion> {
        return locationManager.monitoredRegions
    }

    open var activity: CLActivityType {
        get {
            return locationManager.activityType
        }
        set {
            locationManager.activityType = newValue
        }
    }
    open var distanceFilter: CLLocationDistance {
        get {
            return locationManager.distanceFilter
        }
        set {
            locationManager.distanceFilter = newValue
        }
    }
    open var accuracy: CLLocationAccuracy {
        get {
            return locationManager.desiredAccuracy
        }
        set {
            locationManager.desiredAccuracy = newValue
        }
    }
    open var pausesAutomatically: Bool {
        get {
            return locationManager.pausesLocationUpdatesAutomatically
        }
        set {
            locationManager.pausesLocationUpdatesAutomatically = newValue
        }
    }
    open var background: Bool {
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
                delegates.forEach { delegate in
                    delegate.didFail?(backgroundError)
                }
                errorHandlers.forEach { errorHandler in
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
                delegates.forEach { delegate in
                    delegate.didFail?(backgroundError)
                }
                errorHandlers.forEach { errorHandler in
                    errorHandler(backgroundError)
                }
            }
        }
    }
    open var headingFilter: CLLocationDegrees {
        get {
            return locationManager.headingFilter
        }
        set {
            locationManager.headingFilter = newValue
        }
    }
    open var orientation: CLDeviceOrientation {
        get {
            return locationManager.headingOrientation
        }
        set {
            locationManager.headingOrientation = newValue
        }
    }

    open func shouldDisplayHeadingCalibration(_ display: Bool = true) {
        displayHeadingCalibration = display
    }

    open func dismissHeadingCalibration() {
        locationManager.dismissHeadingCalibrationDisplay()
    }

    open func regionAvailable(_ regionClass: CLRegion.Type) -> Bool {
        return CLLocationManager.isMonitoringAvailable(for: regionClass)
    }

    open func authorized(_ status: CLAuthorizationStatus) -> Bool {
        return status.rawValue >= CLAuthorizationStatus.authorizedAlways.rawValue
    }

    open func authorize(_ status: CLAuthorizationStatus, _ handler: IGZAuthorizationHandler? = nil) -> Bool {
        guard status != authorization else {
            if let handler = handler {
                handler(status)
            }
            return authorized(status)
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
            delegates.forEach { delegate in
                delegate.didFail?(authorizationError)
            }
            errorHandlers.forEach { errorHandler in
                errorHandler(authorizationError)
            }
            return false
        }
    }

    open func startLocationUpdates(_ handler: IGZLocationsHandler? = nil) {
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

    open func stopLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationTemporaryHandlers.removeAll()
        locationManager.stopUpdatingLocation()
    }

    open func requestLocation(_ handler: IGZLocationHandler? = nil) {
        guard #available(iOS 9.0, *) else {
            let error = NSError(domain: kCLErrorDomain, code: CLError.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Request location is only available on iOS 9 or newer."])
            let backgroundError = IGZLocationError(error)
            delegates.forEach { delegate in
                delegate.didFail?(backgroundError)
            }
            errorHandlers.forEach { errorHandler in
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

    open func startHeadingUpdates(_ handler: IGZHeadingHandler? = nil) {
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

    open func stopHeadingUpdates() {
        headingTemporaryHandlers.removeAll()
        locationManager.stopUpdatingHeading()
    }

    open func startSignificantLocationUpdates(_ handler: IGZLocationsHandler? = nil) {
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

    open func stopSignificantLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    open func startRegionUpdates(_ region: CLRegion, sequential: Bool = false, notify: Bool? = nil, _ handler: IGZRegionHandler? = nil) {
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

    open func stopRegionUpdates(_ region: CLRegion? = nil) -> Bool {
        guard regions.count > 0 else {
            let error = NSError(domain: kCLErrorDomain, code: CLError.regionMonitoringDenied.rawValue, userInfo: [NSLocalizedDescriptionKey: "You don't have any monitored regions."])
            let regionError = IGZLocationError(error)
            delegates.forEach { delegate in
                delegate.didFail?(regionError)
            }
            errorHandlers.forEach { errorHandler in
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
            regions.forEach { region in
                locationManager.stopMonitoring(for: region)
            }
        }
        return true
    }

    open func requestRegion(_ region: CLRegion? = nil, _ handler: IGZRegionHandler? = nil) -> Bool {
        guard regions.count > 0 else {
            let error = NSError(domain: kCLErrorDomain, code: CLError.regionMonitoringDenied.rawValue, userInfo: [NSLocalizedDescriptionKey: "You don't have any monitored regions."])
            let regionError = IGZLocationError(error)
            delegates.forEach { delegate in
                delegate.didFail?(regionError)
            }
            errorHandlers.forEach { errorHandler in
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
                        self.regions.forEach { region in
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
            regions.forEach { region in
                locationManager.requestState(for: region)
            }
        }
        return true
    }

    open func startDeferredLocationUpdates(distance: CLLocationDistance, timeout: TimeInterval, _ handler: IGZLocationsHandler? = nil) {
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

    open func stopDeferredLocationUpdates() {
        locationsTemporaryHandlers.removeAll()
        locationManager.disallowDeferredLocationUpdates()
    }

    open func startVisitUpdates(_ handler: IGZVisitHandler? = nil) {
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

    open func stopVisitUpdates() {
        visitTemporaryHandlers.removeAll()
        locationManager.stopMonitoringVisits()
    }
    
}
