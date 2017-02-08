//
//  IGZLocationManagerDelegate.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

extension IGZLocation: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        notificationCenter.post(name: .IGZLocationDidUpdateLocations, object: locations)
        for delegate in delegates {
            delegate.didUpdateLocations?(locations)
        }
        for locationsTemporaryHandler in locationsTemporaryHandlers {
            locationsTemporaryHandler(locations)
        }
        for locationsHandler in locationsHandlers {
            locationsHandler(locations)
        }
        if let lastLocation = locations.last {
            notificationCenter.post(name: .IGZLocationDidUpdateLocation, object: lastLocation)
            for delegate in delegates {
                delegate.didUpdateLocation?(lastLocation)
            }
            for locationTemporaryHandler in locationTemporaryHandlers {
                locationTemporaryHandler(lastLocation)
            }
            locationTemporaryHandlers.removeAll()
            for locationHandler in locationHandlers {
                locationHandler(lastLocation)
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        notificationCenter.post(name: .IGZLocationDidUpdateHeading, object: newHeading)
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
        notificationCenter.post(name: .IGZLocationDidUpdateRegion, object: region, userInfo: [IGZLocationRegionStateUserInfoKey: state])
        for delegate in delegates {
            delegate.didUpdateRegion?(region, state)
        }
        for regionTemporaryHandler in regionTemporaryHandlers {
            regionTemporaryHandler(region, state)
        }
        for regionHandler in regionHandlers {
            regionHandler(region, state)
        }
        if let lastLocation = location, let circularRegion = region as? CLCircularRegion, sequentialRegions, state == .outside {
            let temporaryHandlers = regionTemporaryHandlers
            if stopRegionUpdates(region) {
                let newRegion = CLCircularRegion(center: lastLocation.coordinate, radius: circularRegion.radius, identifier: region.identifier)
                startRegionUpdates(newRegion, sequential: true, temporaryHandlers.last)
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notificationCenter.post(name: .IGZLocationDidUpdateRegion, object: region, userInfo: [IGZLocationRegionStateUserInfoKey: CLRegionState.inside])
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
        notificationCenter.post(name: .IGZLocationDidUpdateRegion, object: region, userInfo: [IGZLocationRegionStateUserInfoKey: CLRegionState.outside])
        for delegate in delegates {
            delegate.didUpdateRegion?(region, .outside)
        }
        for regionTemporaryHandler in regionTemporaryHandlers {
            regionTemporaryHandler(region, .outside)
        }
        for regionHandler in regionHandlers {
            regionHandler(region, .outside)
        }
        if let lastLocation = location, let circularRegion = region as? CLCircularRegion, sequentialRegions {
            let temporaryHandlers = regionTemporaryHandlers
            if stopRegionUpdates(region) {
                let newRegion = CLCircularRegion(center: lastLocation.coordinate, radius: circularRegion.radius, identifier: region.identifier)
                startRegionUpdates(newRegion, sequential: true, temporaryHandlers.last)
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = IGZLocationError(error)
        notificationCenter.post(name: .IGZLocationDidFail, object: locationError)
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
        notificationCenter.post(name: .IGZLocationDidFail, object: locationError)
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
        notificationCenter.post(name: .IGZLocationDidChangeAuthorization, object: status)
        for delegate in delegates {
            delegate.didChangeAuthorization?(status)
        }
        for authorizationTemporaryHandler in authorizationTemporaryHandlers {
            authorizationTemporaryHandler(status)
        }
        if status != .notDetermined {
            authorizationTemporaryHandlers.removeAll()
        }
        for authorizationHandler in authorizationHandlers {
            authorizationHandler(status)
        }
    }

    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        notificationCenter.post(name: .IGZLocationDidUpdateRegion, object: region, userInfo: [IGZLocationRegionStateUserInfoKey: CLRegionState.unknown])
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
            notificationCenter.post(name: .IGZLocationDidFail, object: locationError)
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
        let date = Date()
        let visiting = visit.arrivalDate < date && visit.departureDate > date
        notificationCenter.post(name: .IGZLocationDidVisit, object: visit, userInfo: [IGZLocationVisitingUserInfoKey: visiting])
        for delegate in delegates {
            delegate.didVisit!(visit, visiting)
        }
        for visitTemporaryHandler in visitTemporaryHandlers {
            visitTemporaryHandler(visit, visiting)
        }
        for visitHandler in visitHandlers {
            visitHandler(visit, visiting)
        }
    }
    
}
