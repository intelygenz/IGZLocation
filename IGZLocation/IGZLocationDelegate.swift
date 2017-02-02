//
//  IGZLocationDelegate.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

@objc public protocol IGZLocationDelegate {

    @objc optional func didUpdateLocation(_ location: CLLocation)
    @objc optional func didUpdateLocations(_ locations: [CLLocation])
    @objc optional func didUpdateHeading(_ heading: CLHeading)
    @objc optional func didUpdateRegion(_ region: CLRegion, _ state: CLRegionState)
    @objc optional func didFail(_ error: IGZLocationError)
    @objc optional func didChangeAuthorization(_ status: CLAuthorizationStatus)
    @objc optional func didVisit(_ visit: CLVisit)

}
