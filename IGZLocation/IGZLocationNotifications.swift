//
//  IGZLocationNotifications.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

public struct IGZLocationNotifications {
    public static let didUpdateLocation = NSNotification.Name("IGZLocationDidUpdateLocationNotification")
    public static let didUpdateLocations = NSNotification.Name("IGZLocationDidUpdateLocationsNotification")
    public static let didUpdateHeading = NSNotification.Name("IGZLocationDidUpdateHeadingNotification")
    /// Includes regionState in userInfo
    public static let didUpdateRegion = NSNotification.Name("IGZLocationDidUpdateRegionNotification")
    public static let didFail = NSNotification.Name("IGZLocationDidFailNotification")
    public static let didChangeAuthorization = NSNotification.Name("IGZLocationDidChangeAuthorizationNotification")
    /// Includes visiting in userInfo
    public static let didVisit = NSNotification.Name("IGZLocationDidVisitNotification")

    public struct userInfoKeys {
        public static let regionState = "IGZLocationRegionStateNotificationUserInfoKey"
        public static let visiting = "IGZLocationVisitingNotificationUserInfoKey"
    }
}
