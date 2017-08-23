//
//  IGZLocationManagerDelegate.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

extension IGZLocation: CLLocationManagerDelegate {

    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        notificationCenter.post(name: .IGZLocationDidUpdateLocations, object: locations)
        delegates.forEach { delegate in
            delegate.didUpdateLocations(locations)
        }
        locationsTemporaryHandlers.forEach { locationsTemporaryHandler in
            locationsTemporaryHandler(locations)
        }
        locationsHandlers.forEach { locationsHandler in
            locationsHandler(locations)
        }
        if let lastLocation = locations.last {
            notificationCenter.post(name: .IGZLocationDidUpdateLocation, object: lastLocation)
            delegates.forEach { delegate in
                delegate.didUpdateLocation(lastLocation)
            }
            locationTemporaryHandlers.forEach { locationTemporaryHandler in
                locationTemporaryHandler(lastLocation)
            }
            locationTemporaryHandlers.removeAll()
            locationHandlers.forEach { locationHandler in
                locationHandler(lastLocation)
            }
        }
    }

    open func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        notificationCenter.post(name: .IGZLocationDidUpdateHeading, object: newHeading)
        delegates.forEach { delegate in
            delegate.didUpdateHeading(newHeading)
        }
        headingTemporaryHandlers.forEach { headingTemporaryHandler in
            headingTemporaryHandler(newHeading)
        }
        headingHandlers.forEach { headingHandler in
            headingHandler(newHeading)
        }
    }

    open func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return displayHeadingCalibration
    }

    open func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        notificationCenter.post(name: .IGZLocationDidUpdateRegion, object: region, userInfo: [IGZLocationRegionStateUserInfoKey: state])
        delegates.forEach { delegate in
            delegate.didUpdateRegion(region, state)
        }
        regionTemporaryHandlers.forEach { regionTemporaryHandler in
            regionTemporaryHandler(region, state)
        }
        regionHandlers.forEach { regionHandler in
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

    open func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        notificationCenter.post(name: .IGZLocationDidUpdateRegion, object: region, userInfo: [IGZLocationRegionStateUserInfoKey: CLRegionState.inside])
        delegates.forEach { delegate in
            delegate.didUpdateRegion(region, .inside)
        }
        regionTemporaryHandlers.forEach { regionTemporaryHandler in
            regionTemporaryHandler(region, .inside)
        }
        regionHandlers.forEach { regionHandler in
            regionHandler(region, .inside)
        }
    }

    open func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        notificationCenter.post(name: .IGZLocationDidUpdateRegion, object: region, userInfo: [IGZLocationRegionStateUserInfoKey: CLRegionState.outside])
        delegates.forEach { delegate in
            delegate.didUpdateRegion(region, .outside)
        }
        regionTemporaryHandlers.forEach { regionTemporaryHandler in
            regionTemporaryHandler(region, .outside)
        }
        regionHandlers.forEach { regionHandler in
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

    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let locationError = IGZLocationError(error)
        notificationCenter.post(name: .IGZLocationDidFail, object: locationError)
        delegates.forEach { delegate in
            delegate.didFail(locationError)
        }
        errorTemporaryHandlers.forEach { errorTemporaryHandler in
            errorTemporaryHandler(locationError)
        }
        errorTemporaryHandlers.removeAll()
        errorHandlers.forEach { errorHandler in
            errorHandler(locationError)
        }
    }

    open func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        let locationError = IGZLocationError(error, region: region)
        notificationCenter.post(name: .IGZLocationDidFail, object: locationError)
        delegates.forEach { delegate in
            delegate.didFail(locationError)
        }
        errorTemporaryHandlers.forEach { errorTemporaryHandler in
            errorTemporaryHandler(locationError)
        }
        errorTemporaryHandlers.removeAll()
        errorHandlers.forEach { errorHandler in
            errorHandler(locationError)
        }
    }

    open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        notificationCenter.post(name: .IGZLocationDidChangeAuthorization, object: status)
        delegates.forEach { delegate in
            delegate.didChangeAuthorization(status)
        }
        authorizationTemporaryHandlers.forEach { authorizationTemporaryHandler in
            authorizationTemporaryHandler(status)
        }
        if status != .notDetermined {
            authorizationTemporaryHandlers.removeAll()
        }
        authorizationHandlers.forEach { authorizationHandler in
            authorizationHandler(status)
        }
    }

    open func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        notificationCenter.post(name: .IGZLocationDidUpdateRegion, object: region, userInfo: [IGZLocationRegionStateUserInfoKey: CLRegionState.unknown])
        delegates.forEach { delegate in
            delegate.didUpdateRegion(region, .unknown)
        }
        regionTemporaryHandlers.forEach { regionTemporaryHandler in
            regionTemporaryHandler(region, .unknown)
        }
        regionHandlers.forEach { regionHandler in
            regionHandler(region, .unknown)
        }
    }

    open func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {

    }

    open func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {

    }

    open func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if let error = error {
            let locationError = IGZLocationError(error)
            notificationCenter.post(name: .IGZLocationDidFail, object: locationError)
            delegates.forEach { delegate in
                delegate.didFail(locationError)
            }
            errorTemporaryHandlers.forEach { errorTemporaryHandler in
                errorTemporaryHandler(locationError)
            }
            errorTemporaryHandlers.removeAll()
            errorHandlers.forEach { errorHandler in
                errorHandler(locationError)
            }
        }
    }

    open func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let date = Date()
        let visiting = visit.arrivalDate < date && visit.departureDate > date
        notificationCenter.post(name: .IGZLocationDidVisit, object: visit, userInfo: [IGZLocationVisitingUserInfoKey: visiting])
        delegates.forEach { delegate in
            delegate.didVisit(visit, visiting)
        }
        visitTemporaryHandlers.forEach { visitTemporaryHandler in
            visitTemporaryHandler(visit, visiting)
        }
        visitHandlers.forEach { visitHandler in
            visitHandler(visit, visiting)
        }
    }
    
}
