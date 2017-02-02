//
//  IGZLocationNotifications.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

struct IGZLocationNotifications {
    static let didUpdateLocation = NSNotification.Name("IGZLocationDidUpdateLocationNotification")
    static let didUpdateLocations = NSNotification.Name("IGZLocationDidUpdateLocationsNotification")
    static let didUpdateHeading = NSNotification.Name("IGZLocationDidUpdateHeadingNotification")
    static let didUpdateRegion = NSNotification.Name("IGZLocationDidUpdateRegionNotification")
    static let didFail = NSNotification.Name("IGZLocationDidFailNotification")
    static let didChangeAuthorization = NSNotification.Name("IGZLocationDidChangeAuthorizationNotification")
    static let didVisit = NSNotification.Name("IGZLocationDidVisitNotification")

    struct userInfoKeys {
        static let regionState = "IGZLocationRegionStateNotificationUserInfoKey"
    }
}
