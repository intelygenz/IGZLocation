//
//  IGZLocationManager.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

public protocol IGZLocationManager: NSObjectProtocol {

    static var shared: IGZLocationManager { get }
    var locationHandlers: [IGZLocationHandler] { get set }
    var errorHandlers: [IGZErrorHandler] { get set }
    var locationsHandlers: [IGZLocationsHandler] { get set }
    var headingHandlers: [IGZHeadingHandler] { get set }
    var regionHandlers: [IGZRegionHandler] { get set }
    var authorizationHandlers: [IGZAuthorizationHandler] { get set }
    var visitHandlers: [IGZVisitHandler] { get set }
    var delegates: [IGZLocationDelegate] { get set }

    var activity: CLActivityType { get set }
    var distanceFilter: CLLocationDistance { get set }
    var accuracy: CLLocationAccuracy { get set }
    var pausesAutomatically: Bool { get set }
    var background: Bool { get set }
    var headingFilter: CLLocationDegrees { get set }
    var orientation: CLDeviceOrientation { get set }

    var authorized: Bool { get }
    var locationAvailable: Bool { get }
    var headingAvailable: Bool { get }
    var significantLocationAvailable: Bool { get }
    var deferredLocationAvailable: Bool { get }
    var authorization: CLAuthorizationStatus { get }
    var location: CLLocation? { get }
    var heading: CLHeading? { get }
    var maximumRegionDistance: CLLocationDistance { get }
    var regions: Set<CLRegion> { get }

    func shouldDisplayHeadingCalibration(_ display: Bool)
    func dismissHeadingCalibration()
    func regionAvailable(_ regionClass: CLRegion.Type) -> Bool
    func authorized(_ status: CLAuthorizationStatus) -> Bool
    func authorize(_ status: CLAuthorizationStatus, _ handler: IGZAuthorizationHandler?) -> Bool
    func startLocationUpdates(_ handler: IGZLocationsHandler?)
    func stopLocationUpdates()
    func requestLocation(_ handler: IGZLocationHandler?)
    func startHeadingUpdates(_ handler: IGZHeadingHandler?)
    func stopHeadingUpdates()
    func startSignificantLocationUpdates(_ handler: IGZLocationsHandler?)
    func stopSignificantLocationUpdates()
    func startRegionUpdates(_ region: CLRegion, sequential: Bool, notify: Bool?, _ handler: IGZRegionHandler?)
    func stopRegionUpdates(_ region: CLRegion?) -> Bool
    func requestRegion(_ region: CLRegion?, _ handler: IGZRegionHandler?) -> Bool
    func startDeferredLocationUpdates(distance: CLLocationDistance, timeout: TimeInterval, _ handler: IGZLocationsHandler?)
    func stopDeferredLocationUpdates()
    func startVisitUpdated(_ handler: IGZVisitHandler?)
    func stopVisitUpdated()
    
}
