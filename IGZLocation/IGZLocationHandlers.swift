//
//  IGZLocationHandlers.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
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
