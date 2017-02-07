//
//  IGZLocationMapUITests.swift
//  IGZLocationMapUITests
//
//  Created by Alejandro Ruperez Hernando on 3/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import XCTest

@available(iOS 9.0, *)
class IGZLocationMapUITests: XCTestCase {

    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = true
        app.launch()

        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        addUIInterruptionMonitor(withDescription: "Location Authorization") { alert -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        app.tap()
    }

    func testMapPin() {
        // Map load
        sleep(2)

        // Find any map pin
        let element = app.otherElements.containing(.staticText, identifier:" ").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        XCTAssert(element.children(matching: .other).matching(identifier: "Map pin").element.exists)
    }

    override func tearDown() {
        super.tearDown()
    }
    
}
