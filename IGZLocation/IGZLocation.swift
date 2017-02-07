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
public class IGZLocation: NSObject {

    public var locationHandlers = [IGZLocationHandler]()
    public var locationsHandlers = [IGZLocationsHandler]()
    public var errorHandlers = [IGZErrorHandler]()
    public var headingHandlers = [IGZHeadingHandler]()
    public var regionHandlers = [IGZRegionHandler]()
    public var authorizationHandlers = [IGZAuthorizationHandler]()
    public var visitHandlers = [IGZVisitHandler]()
    public var delegates = [IGZLocationDelegate]()

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

    override init() {
        super.init()
        locationManager.delegate = self
    }

}
