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

}
