//
//  IGZLocation.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 31/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

/**
 IGZLocationManager

 The IGZLocation is your entry point to the location service.
 */
open class IGZLocation: NSObject {

    open var location: CLLocation? {
        return locationManager.location
    }

    open var locationHandlers = [IGZLocationHandler]()
    open var locationsHandlers = [IGZLocationsHandler]()
    open var errorHandlers = [IGZErrorHandler]()
    open var headingHandlers = [IGZHeadingHandler]()
    open var regionHandlers = [IGZRegionHandler]()
    open var authorizationHandlers = [IGZAuthorizationHandler]()
    open var visitHandlers = [IGZVisitHandler]()
    open var delegates = [IGZLocationDelegate]()

    var locationTemporaryHandlers = [IGZLocationHandler]()
    var locationsTemporaryHandlers = [IGZLocationsHandler]()
    var errorTemporaryHandlers = [IGZErrorHandler]()
    var headingTemporaryHandlers = [IGZHeadingHandler]()
    var regionTemporaryHandlers = [IGZRegionHandler]()
    var authorizationTemporaryHandlers = [IGZAuthorizationHandler]()
    var visitTemporaryHandlers = [IGZVisitHandler]()

    var displayHeadingCalibration = false
    var sequentialRegions = false
    final let locationManager = CLLocationManager()
    final let notificationCenter = NotificationCenter.default

    public override init() {
        super.init()
        locationManager.delegate = self
    }

    deinit {
        locationManager.delegate = nil
        delegates.removeAll()
        locationTemporaryHandlers.removeAll()
        locationsTemporaryHandlers.removeAll()
        errorTemporaryHandlers.removeAll()
        headingTemporaryHandlers.removeAll()
        regionTemporaryHandlers.removeAll()
        authorizationTemporaryHandlers.removeAll()
        visitTemporaryHandlers.removeAll()
        locationHandlers.removeAll()
        locationsHandlers.removeAll()
        errorHandlers.removeAll()
        headingHandlers.removeAll()
        regionHandlers.removeAll()
        authorizationHandlers.removeAll()
        visitHandlers.removeAll()
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

    open func requestLocation(_ handler: IGZLocationHandler? = nil) {
        guard #available(iOS 9.0, *) else {
            let error = NSError(domain: kCLErrorDomain, code: CLError.denied.rawValue, userInfo: [NSLocalizedDescriptionKey: "Request location is only available on iOS 9 or newer."])
            let backgroundError = IGZLocationError(error)
            delegates.forEach { delegate in
                delegate.didFail(backgroundError)
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

}
