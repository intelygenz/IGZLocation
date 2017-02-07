//
//  IGZLocationTests.swift
//  IGZLocationTests
//
//  Created by Alejandro Ruperez Hernando on 31/1/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import XCTest
import CoreLocation
@testable import IGZLocation

class IGZLocationMock: IGZLocation {
    private let mockLocation = CLLocation(latitude: 0, longitude: 0)

    override var location: CLLocation? {
        return mockLocation
    }

    override func startLocationUpdates(_ handler: IGZLocationsHandler?) {
        super.startLocationUpdates(handler)
        locationManager.delegate?.locationManager?(locationManager, didChangeAuthorization: .authorizedAlways)
        locationManager.delegate?.locationManager?(locationManager, didUpdateLocations: [mockLocation])
    }

    override func requestLocation(_ handler: IGZLocationHandler?) {
        super.requestLocation(handler)
        locationManager.delegate?.locationManager?(locationManager, didChangeAuthorization: .authorizedAlways)
        locationManager.delegate?.locationManager?(locationManager, didUpdateLocations: [mockLocation])
    }

}

class IGZLocationTests: XCTestCase {

    var locationManager: IGZLocationManager!
    
    override func setUp() {
        super.setUp()

        locationManager = IGZLocationMock()
        locationManager.delegates.append(self)

    }
    
    func testRegionAvailable() {
        XCTAssertTrue(locationManager.regionAvailable(CLCircularRegion.self))
    }

    func testAuthorized() {
        XCTAssertFalse(locationManager.authorized(.notDetermined))
        XCTAssertFalse(locationManager.authorized(.restricted))
        XCTAssertFalse(locationManager.authorized(.denied))
        XCTAssertTrue(locationManager.authorized(.authorizedAlways))
        XCTAssertTrue(locationManager.authorized(.authorizedWhenInUse))
    }

    func testLocationsUpdates() {
        locationManager.locationsHandlers.append { locations in
            XCTAssertNotNil(locations)
            XCTAssertNotNil(self.locationManager.location)
            XCTAssertTrue(locations.contains(self.locationManager.location!))
        }
        locationManager.startLocationUpdates { locations in
            XCTAssertNotNil(locations)
            XCTAssertNotNil(self.locationManager.location)
            XCTAssertTrue(locations.contains(self.locationManager.location!))
        }
    }

    func testLocationUpdates() {
        locationManager.locationHandlers.append { location in
            XCTAssertNotNil(location)
            XCTAssertNotNil(self.locationManager.location)
            XCTAssertEqual(location, self.locationManager.location)
        }
        if #available(iOS 9.0, *) {
            locationManager.requestLocation { location in
                XCTAssertNotNil(location)
                XCTAssertNotNil(self.locationManager.location)
                XCTAssertEqual(location, self.locationManager.location)
            }
        }
    }
    
    override func tearDown() {

        locationManager = nil

        super.tearDown()
    }
    
}

extension IGZLocationTests: IGZLocationDelegate {

    func didUpdateLocations(_ locations: [CLLocation]) {
        XCTAssertNotNil(locations)
        XCTAssertNotNil(self.locationManager.location)
        XCTAssertTrue(locations.contains(self.locationManager.location!))
    }

    func didUpdateLocation(_ location: CLLocation) {
        XCTAssertNotNil(location)
        XCTAssertNotNil(self.locationManager.location)
        XCTAssertEqual(location, self.locationManager.location)
    }

}
