//
//  IGZLocationNotifications.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import Foundation

public struct IGZLocationNotifications {
    @available(*, deprecated, message: "Please use .IGZLocationDidUpdateLocation instead")
    public static let didUpdateLocation = NSNotification.Name("IGZLocationDidUpdateLocationNotification")
    @available(*, deprecated, message: "Please use .IGZLocationDidUpdateLocations instead")
    public static let didUpdateLocations = NSNotification.Name("IGZLocationDidUpdateLocationsNotification")
    @available(*, deprecated, message: "Please use .IGZLocationDidUpdateHeading instead")
    public static let didUpdateHeading = NSNotification.Name("IGZLocationDidUpdateHeadingNotification")
    /// Includes regionState in userInfo
    @available(*, deprecated, message: "Please use .IGZLocationDidUpdateRegion instead")
    public static let didUpdateRegion = NSNotification.Name("IGZLocationDidUpdateRegionNotification")
    @available(*, deprecated, message: "Please use .IGZLocationDidFail instead")
    public static let didFail = NSNotification.Name("IGZLocationDidFailNotification")
    @available(*, deprecated, message: "Please use .IGZLocationDidChangeAuthorization instead")
    public static let didChangeAuthorization = NSNotification.Name("IGZLocationDidChangeAuthorizationNotification")
    /// Includes visiting in userInfo
    @available(*, deprecated, message: "Please use .IGZLocationDidVisit instead")
    public static let didVisit = NSNotification.Name("IGZLocationDidVisitNotification")

    public struct userInfoKeys {
        @available(*, deprecated, message: "Please use IGZLocationRegionStateUserInfoKey instead")
        public static let regionState = "IGZLocationRegionStateNotificationUserInfoKey"
        @available(*, deprecated, message: "Please use IGZLocationVisitingUserInfoKey instead")
        public static let visiting = "IGZLocationVisitingNotificationUserInfoKey"
    }
}

public extension NSNotification.Name {
    public static let IGZLocationDidUpdateLocation = NSNotification.Name("IGZLocationDidUpdateLocationNotification")
    public static let IGZLocationDidUpdateLocations = NSNotification.Name("IGZLocationDidUpdateLocationsNotification")
    public static let IGZLocationDidUpdateHeading = NSNotification.Name("IGZLocationDidUpdateHeadingNotification")
    /// Includes regionState in userInfo
    public static let IGZLocationDidUpdateRegion = NSNotification.Name("IGZLocationDidUpdateRegionNotification")
    public static let IGZLocationDidFail = NSNotification.Name("IGZLocationDidFailNotification")
    public static let IGZLocationDidChangeAuthorization = NSNotification.Name("IGZLocationDidChangeAuthorizationNotification")
    /// Includes visiting in userInfo
    public static let IGZLocationDidVisit = NSNotification.Name("IGZLocationDidVisitNotification")
}

public let IGZLocationRegionStateUserInfoKey = "IGZLocationRegionStateNotificationUserInfoKey"
public let IGZLocationVisitingUserInfoKey = "IGZLocationVisitingNotificationUserInfoKey"
