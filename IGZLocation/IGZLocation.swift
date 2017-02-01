//
//  IGZLocation.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 31/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

public typealias IGZLocationHandler = (_ location: CLLocation) -> Void
public typealias IGZLocationsHandler = (_ locations: [CLLocation]) -> Void
public typealias IGZErrorHandler = (_ error: IGZLocationError) -> Void
public typealias IGZHeadingHandler = (_ heading: CLHeading) -> Void
public typealias IGZRegionHandler = (_ region: CLRegion, _ state: CLRegionState) -> Void
public typealias IGZAuthorizationHandler = (_ status: CLAuthorizationStatus) -> Void
public typealias IGZVisitHandler = (_ visit: CLVisit) -> Void

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
    func startRegionUpdates(_ region: CLRegion, _ handler: IGZRegionHandler?)
    func stopRegionUpdates(_ region: CLRegion)
    func requestRegion(_ region: CLRegion, _ handler: IGZRegionHandler?)
    func startDeferredLocationUpdates(distance: CLLocationDistance, timeout: TimeInterval, _ handler: IGZLocationsHandler?)
    func stopDeferredLocationUpdates()
    func startVisitUpdated(_ handler: IGZVisitHandler?)
    func stopVisitUpdated()

}

@objc public protocol IGZLocationDelegate {

    @objc optional func didUpdateLocation(_ location: CLLocation)
    @objc optional func didUpdateLocations(_ locations: [CLLocation])
    @objc optional func didUpdateHeading(_ heading: CLHeading)
    @objc optional func didUpdateRegion(_ region: CLRegion, _ state: CLRegionState)
    @objc optional func didFail(_ error: IGZLocationError)
    @objc optional func didChangeAuthorization(_ status: CLAuthorizationStatus)
    @objc optional func didVisit(_ visit: CLVisit)
    
}

public class IGZLocationError: NSError {

    fileprivate(set) var region: CLRegion?

    public convenience init(_ error: Error) {
        self.init(error: error as NSError, region: nil)
    }

    public convenience init(_ error: Error, region: CLRegion? = nil) {
        self.init(error: error as NSError, region: nil)
    }

    public convenience init(error: NSError) {
        self.init(error, region: nil)
    }

    public init(error: NSError, region: CLRegion? = nil) {
        var userInfo = error.userInfo
        userInfo[NSUnderlyingErrorKey] = error
        super.init(domain: error.domain, code: error.code, userInfo: userInfo)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

public class IGZLocation: NSObject {

    public var locationHandlers = [IGZLocationHandler]()
    public var locationsHandlers = [IGZLocationsHandler]()
    public var errorHandlers = [IGZErrorHandler]()
    public var headingHandlers = [IGZHeadingHandler]()
    public var regionHandlers = [IGZRegionHandler]()
    public var authorizationHandlers = [IGZAuthorizationHandler]()
    public var visitHandlers = [IGZVisitHandler]()
    public var delegates = [IGZLocationDelegate]()

    fileprivate var locationTemporaryHandlers = [IGZLocationHandler]()
    fileprivate var locationsTemporaryHandlers = [IGZLocationsHandler]()
    fileprivate var errorTemporaryHandlers = [IGZErrorHandler]()
    fileprivate var headingTemporaryHandlers = [IGZHeadingHandler]()
    fileprivate var regionTemporaryHandlers = [IGZRegionHandler]()
    fileprivate var authorizationTemporaryHandlers = [IGZAuthorizationHandler]()
    fileprivate var visitTemporaryHandlers = [IGZVisitHandler]()

    fileprivate final var displayHeadingCalibration = false
    fileprivate final let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
    }

}

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
                let error = NSError(domain: kCLErrorDomain, code: CLError.denied.rawValue, userInfo: nil)
                let authorizationError = IGZLocationError(error)
                for delegate in delegates {
                    delegate.didFail?(authorizationError)
                }
                for errorHandler in errorHandlers {
                    errorHandler(authorizationError)
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

    public func authorize(_ status: CLAuthorizationStatus, _ handler: IGZAuthorizationHandler?) -> Bool {
        authorizationTemporaryHandlers.append({ newStatus in handler?(newStatus) })
        switch status {
            case .authorizedAlways:
                locationManager.requestAlwaysAuthorization()
                return true
            case .authorizedWhenInUse:
                locationManager.requestWhenInUseAuthorization()
                return true
            default:
                let error = NSError(domain: kCLErrorDomain, code: CLError.denied.rawValue, userInfo: nil)
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

    public func startLocationUpdates(_ handler: IGZLocationsHandler?) {
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

    public func requestLocation(_ handler: IGZLocationHandler?) {
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

    public func startHeadingUpdates(_ handler: IGZHeadingHandler?) {
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

    public func startSignificantLocationUpdates(_ handler: IGZLocationsHandler?) {
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

    public func startRegionUpdates(_ region: CLRegion, _ handler: IGZRegionHandler?) {
        guard authorized && regionAvailable(type(of: region)) else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.regionTemporaryHandlers.append({ region, state in handler?(region, state) })
                    self.locationManager.startMonitoring(for: region)
                }
            })
            return
        }

        regionTemporaryHandlers.append({ region, state in handler?(region, state) })
        locationManager.startMonitoring(for: region)
    }

    public func stopRegionUpdates(_ region: CLRegion) {
        regionTemporaryHandlers.removeAll()
        locationManager.stopMonitoring(for: region)
    }

    public func requestRegion(_ region: CLRegion, _ handler: IGZRegionHandler?) {
        guard authorized && regionAvailable(type(of: region)) else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.regionTemporaryHandlers.append({ region, state in handler?(region, state) })
                    self.locationManager.requestState(for: region)
                }
            })
            return
        }

        regionTemporaryHandlers.append({ region, state in handler?(region, state) })
        locationManager.requestState(for: region)
    }

    public func startDeferredLocationUpdates(distance: CLLocationDistance, timeout: TimeInterval, _ handler: IGZLocationsHandler?) {
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

    public func startVisitUpdated(_ handler: IGZVisitHandler?) {
        guard authorized else {
            _ = authorize(authorization, { newStatus in
                if self.authorized(newStatus) {
                    self.visitTemporaryHandlers.append({ visit in handler?(visit) })
                    self.locationManager.startMonitoringVisits()
                }
            })
            return
        }

        visitTemporaryHandlers.append({ visit in handler?(visit) })
        locationManager.startMonitoringVisits()
    }

    public func stopVisitUpdated() {
        visitTemporaryHandlers.removeAll()
        locationManager.stopMonitoringVisits()
    }

}

extension IGZLocation: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for delegate in delegates {
            delegate.didUpdateLocations?(locations)
        }
        for locationsTemporaryHandler in locationsTemporaryHandlers {
            locationsTemporaryHandler(locations)
        }
        if let lastLocation = locations.last {
            for locationTemporaryHandler in locationTemporaryHandlers {
                locationTemporaryHandler(lastLocation)
            }
            locationTemporaryHandlers.removeAll()
        }
        for locationsHandler in locationsHandlers {
            locationsHandler(locations)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        for delegate in delegates {
            delegate.didUpdateHeading?(newHeading)
        }
        for headingTemporaryHandler in headingTemporaryHandlers {
            headingTemporaryHandler(newHeading)
        }
        for headingHandler in headingHandlers {
            headingHandler(newHeading)
        }
    }

    public func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return displayHeadingCalibration
    }

    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        for delegate in delegates {
            delegate.didUpdateRegion?(region, state)
        }
        for regionTemporaryHandler in regionTemporaryHandlers {
            regionTemporaryHandler(region, state)
        }
        for regionHandler in regionHandlers {
            regionHandler(region, state)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        for delegate in delegates {
            delegate.didUpdateRegion?(region, .inside)
        }
        for regionTemporaryHandler in regionTemporaryHandlers {
            regionTemporaryHandler(region, .inside)
        }
        for regionHandler in regionHandlers {
            regionHandler(region, .inside)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        for delegate in delegates {
            delegate.didUpdateRegion?(region, .outside)
        }
        for regionTemporaryHandler in regionTemporaryHandlers {
            regionTemporaryHandler(region, .outside)
        }
        for regionHandler in regionHandlers {
            regionHandler(region, .outside)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = IGZLocationError(error)
        for delegate in delegates {
            delegate.didFail?(locationError)
        }
        for errorTemporaryHandler in errorTemporaryHandlers {
            errorTemporaryHandler(locationError)
        }
        errorTemporaryHandlers.removeAll()
        for errorHandler in errorHandlers {
            errorHandler(locationError)
        }
    }

    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        let locationError = IGZLocationError(error, region: region)
        for delegate in delegates {
            delegate.didFail?(locationError)
        }
        for errorTemporaryHandler in errorTemporaryHandlers {
            errorTemporaryHandler(locationError)
        }
        errorTemporaryHandlers.removeAll()
        for errorHandler in errorHandlers {
            errorHandler(locationError)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        for delegate in delegates {
            delegate.didChangeAuthorization?(status)
        }
        for authorizationTemporaryHandler in authorizationTemporaryHandlers {
            authorizationTemporaryHandler(status)
        }
        authorizationTemporaryHandlers.removeAll()
        for authorizationHandler in authorizationHandlers {
            authorizationHandler(status)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        for delegate in delegates {
            delegate.didUpdateRegion?(region, .unknown)
        }
        for regionTemporaryHandler in regionTemporaryHandlers {
            regionTemporaryHandler(region, .unknown)
        }
        for regionHandler in regionHandlers {
            regionHandler(region, .unknown)
        }
    }

    public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {

    }

    public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {

    }

    public func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if let error = error {
            let locationError = IGZLocationError(error)
            for delegate in delegates {
                delegate.didFail?(locationError)
            }
            for errorTemporaryHandler in errorTemporaryHandlers {
                errorTemporaryHandler(locationError)
            }
            errorTemporaryHandlers.removeAll()
            for errorHandler in errorHandlers {
                errorHandler(locationError)
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        for delegate in delegates {
            delegate.didVisit!(visit)
        }
        for visitTemporaryHandler in visitTemporaryHandlers {
            visitTemporaryHandler(visit)
        }
        for visitHandler in visitHandlers {
            visitHandler(visit)
        }
    }

}
