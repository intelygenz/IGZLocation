//
//  IGZLocationDelegate.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

public protocol IGZLocationDelegate {

    func didUpdateLocation(_ location: CLLocation)
    func didUpdateLocations(_ locations: [CLLocation])
    func didUpdateHeading(_ heading: CLHeading)
    func didUpdateRegion(_ region: CLRegion, _ state: CLRegionState)
    func didFail(_ error: IGZLocationError)
    func didChangeAuthorization(_ status: CLAuthorizationStatus)
    func didVisit(_ visit: CLVisit, _ visiting: Bool)

}

public extension IGZLocationDelegate {

    func didUpdateLocation(_ location: CLLocation) {}
    func didUpdateLocations(_ locations: [CLLocation]) {}
    func didUpdateHeading(_ heading: CLHeading) {}
    func didUpdateRegion(_ region: CLRegion, _ state: CLRegionState) {}
    func didFail(_ error: IGZLocationError) {}
    func didChangeAuthorization(_ status: CLAuthorizationStatus) {}
    func didVisit(_ visit: CLVisit, _ visiting: Bool) {}

}
