//
//  IGZLocationManager.swift
//  IGZLocation
//
//  Created by Alejandro Ruperez Hernando on 2/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import CoreLocation

/**
 IGZLocationManager
 
 The IGZLocationManager protocol implementation is your entry point to the location service.
 */
public protocol IGZLocationManager {

    /// IGZLocationManager protocol implementation shared instance
    static var shared: IGZLocationManager { get }
    
    var locationHandlers: [IGZLocationHandler] { get set }
    var errorHandlers: [IGZErrorHandler] { get set }
    var locationsHandlers: [IGZLocationsHandler] { get set }
    var headingHandlers: [IGZHeadingHandler] { get set }
    var regionHandlers: [IGZRegionHandler] { get set }
    var authorizationHandlers: [IGZAuthorizationHandler] { get set }
    var visitHandlers: [IGZVisitHandler] { get set }
    var delegates: [IGZLocationDelegate] { get set }

    /**
     activity
     
     Specifies the type of user activity. Currently affects behavior such as
     the determination of when location updates may be automatically paused.
     By default, CLActivityTypeOther is used.
     */
    var activity: CLActivityType { get set }

    /**
     distanceFilter

     Specifies the minimum update distance in meters. Client will not be notified of movements of less
     than the stated value, unless the accuracy has improved. Pass in kCLDistanceFilterNone to be
     notified of all movements. By default, kCLDistanceFilterNone is used.
     */
    var distanceFilter: CLLocationDistance { get set }

    /**
     accuracy

     The desired location accuracy. The location service will try its best to achieve
     your desired accuracy. However, it is not guaranteed. To optimize
     power performance, be sure to specify an appropriate accuracy for your usage scenario (eg,
     use a large accuracy value when only a coarse location is needed). Use kCLLocationAccuracyBest to
     achieve the best possible accuracy. Use kCLLocationAccuracyBestForNavigation for navigation.
     The default value varies by platform.
     */
    var accuracy: CLLocationAccuracy { get set }

    /**
     pausesAutomatically

     Specifies that location updates may automatically be paused when possible.
     By default, this is true for applications linked against iOS 8.0 or later.
     */
    var pausesAutomatically: Bool { get set }

    /**
     background

     By default, this is false for applications linked against iOS 9.0 or later,
     regardless of minimum deployment target.
 
     With UIBackgroundModes set to include "location" in Info.plist, you must
     also set this property to true at runtime whenever calling
     -startLocationUpdates: with the intent to continue in the background.
 
     Setting this property to true when UIBackgroundModes does not include
     "location" is a fatal error.
 
     Resetting this property to false is equivalent to omitting "location" from
     the UIBackgroundModes value.  Access to location is still permitted
     whenever the application is running (ie not suspended), and has
     sufficient authorization (ie it has WhenInUse authorization and is in
     use, or it has Always authorization).  However, the app will still be
     subject to the usual task suspension rules.
 
     See -authorize: for
     more details on possible authorization values.
     */
    @available(iOS 9.0, *)
    var background: Bool { get set }

    /**
     headingFilter

     Specifies the minimum amount of change in degrees needed for a heading service update. Client will not
     be notified of updates less than the stated filter value. Pass in kCLHeadingFilterNone to be
     notified of all updates. By default, 1 degree is used.
     */
    var headingFilter: CLLocationDegrees { get set }

    /**
     headingOrientation

     Specifies a physical device orientation from which heading calculation should be referenced. By default,
     CLDeviceOrientationPortrait is used. CLDeviceOrientationUnknown, CLDeviceOrientationFaceUp, and
     CLDeviceOrientationFaceDown are ignored.

     */
    var orientation: CLDeviceOrientation { get set }

    /**
     authorized

     Returns if the current authorization status of the calling application is "always" or "when in use".
     */
    var authorized: Bool { get }

    /**
     locationAvailable

     Determines whether the user has location services enabled.
     If false, and you proceed to call other CoreLocation API, user will be prompted with the warning
     dialog. You may want to check this property and use location services only when explicitly requested by the user.
     */
    var locationAvailable: Bool { get }

    /**
     headingAvailable
     
     Returns true if the device supports the heading service, otherwise false.
     */
    var headingAvailable: Bool { get }

    /**
     significantLocationAvailable
     
     Returns true if the device supports significant location change monitoring, otherwise false.
     */
    var significantLocationAvailable: Bool { get }

    /**
     deferredLocationAvailable
     
     Returns true if the device supports deferred location updates, otherwise false.
     */
    var deferredLocationAvailable: Bool { get }

    /**
     authorization
     
     Returns the current authorization status of the calling application.
     */
    var authorization: CLAuthorizationStatus { get }

    /**
     location
     
     The last location received. Will be nil until a location has been received.
     */
    var location: CLLocation? { get }

    /**
     heading
     
     Returns the latest heading update received, or nil if none is available.
     */
    var heading: CLHeading? { get }

    /**
     maximumRegionDistance

     The maximum region size, in terms of a distance from a central point, that the framework can support.
     Attempts to register a region larger than this will generate a kCLErrorRegionMonitoringFailure.
     This value may vary based on the hardware features of the device, as well as on dynamically changing resource constraints.
     */
    var maximumRegionDistance: CLLocationDistance { get }

    /**
     regions

     Retrieve a set of objects for the regions that are currently being monitored.  If any location manager
     has been instructed to monitor a region, during this or previous launches of your application, it will
     be present in this set.
     */
    var regions: Set<CLRegion> { get }

    /**
     shouldDisplayHeadingCalibration:
     
     Shows the heading calibration when needed.
     
     - Parameters:
        - display: Should display heading calibration.
     */
    func shouldDisplayHeadingCalibration(_ display: Bool)

    /**
     dismissHeadingCalibrationDisplay
     
     Dismiss the heading calibration immediately.
     */
    func dismissHeadingCalibration()

    /**
     regionAvailable:
     
     Determines whether the device supports monitoring for the specified type of region.
     If false, all attempts to monitor the specified type of region will fail.
     
     - Parameters:
        - regionClass: The specified type of region.
     
     - Returns: If the device supports monitoring for the specified type of region.
     */
    func regionAvailable(_ regionClass: CLRegion.Type) -> Bool

    /**
     authorized

     Returns if status is "always" or "when in use".
     
     - Parameters:
        - status: The authorization status.

     - Returns: If status is "always" or "when in use".
     */
    func authorized(_ status: CLAuthorizationStatus) -> Bool

    /**
     authorize:

     When authorization == kCLAuthorizationStatusNotDetermined,
     calling this method will trigger a prompt to request
     authorization from the user.  If possible, perform this call in response
     to direct user request for a location-based service so that the reason
     for the prompt will be clear.
 
     If "always" authorization is received, grants access to the user's
     location via any CLLocationManager API, and grants access to
     launch-capable monitoring API such as geofencing/region monitoring,
     significante location visits, etc.  Even if killed by the user, launch
     events triggered by monitored regions or visit patterns will cause a
     relaunch.
 
     "Always" authorization presents a significant risk to user privacy, and
     as such requesting it is discouraged unless background launch behavior
     is genuinely required.  Do not call with "always" unless
     you think users will thank you for doing so.
 
     When authorization != kCLAuthorizationStatusNotDetermined, (ie
     generally after the first call) this method will do nothing.
 
     If the location usage description key is not specified in your
     Info.plist, this method will do nothing, as your app will be assumed not
     to support location updates.
     
     - Parameters:
        - status: The requested authorization.
        - handler: The single request handler.
     
     - Returns: Authorization request result.
     */
    func authorize(_ status: CLAuthorizationStatus, _ handler: IGZAuthorizationHandler?) -> Bool

    /**
     startLocationUpdates:
     
     Start updating locations.
     
     - Parameters:
        - handler: The single request handler.
     */
    func startLocationUpdates(_ handler: IGZLocationsHandler?)

    /**
     stopLocationUpdates
     
     Stop updating locations.
     */
    func stopLocationUpdates()

    /**
     requestLocation:
     
     Request a single location update.
     
     The service will attempt to determine location with accuracy according
     to the desiredAccuracy property.
 
     If the best available location has lower accuracy, then it will be
     delivered via the standard delegate callback after timeout.
 
     There can only be one outstanding location request and this method can
     not be used concurrently with startLocationUpdates: or
     startDeferredLocationUpdates:.  Calling either of those methods will
     immediately cancel the location request.  The method
     stopLocationUpdates can be used to explicitly cancel the request.
     
     - Parameters:
        - handler: The single request handler.
     */
    @available(iOS 9.0, *)
    func requestLocation(_ handler: IGZLocationHandler?)

    /**
     startHeadingUpdates:
     
     Start updating heading.
     
     - Parameters:
        - handler: The single request handler.
     */
    func startHeadingUpdates(_ handler: IGZHeadingHandler?)

    /**
     stopUpdatingHeading:
     
     Stop updating heading.
     
     - Parameters:
        - handler: The single request handler.
     */
    func stopHeadingUpdates()

    /**
     startSignificantLocationUpdates:
     
     Start monitoring significant location changes.  The behavior of this service is not affected by the desiredAccuracy
     or distanceFilter properties.
     
     - Parameters:
        - handler: The single request handler.
     */
    func startSignificantLocationUpdates(_ handler: IGZLocationsHandler?)

    /**
     stopSignificantLocationUpdates
     
     Stop monitoring significant location changes.
     */
    func stopSignificantLocationUpdates()

    /**
     startRegionUpdates:sequential:notify:
     
     Start monitoring the specified region.
     
     If a region of the same type with the same identifier is already being monitored for this application,
     it will be removed from monitoring. For circular regions, the region monitoring service will prioritize
     regions by their size, favoring smaller regions over larger regions.
 
     This is done asynchronously and may not be immediately reflected in regions.
     
     - Parameters:
        - region: The region object that defines the boundary to monitor. This parameter must not be nil.
        - sequential: When using CLCircularRegion, the center will be updated with the user current location when the user exits the region. By default, this is false.
        - notify: App will be launched when the user enters or exits the region. If false, only notifies when requestRegion: and sequential is disabled. By default, this is true.
        - handler: The single request handler.
     */
    func startRegionUpdates(_ region: CLRegion, sequential: Bool, notify: Bool?, _ handler: IGZRegionHandler?)

    /**
     stopRegionUpdates:
     
     Stop monitoring the specified region.  It is valid to call stopMonitoringForRegion: for a region that was registered
     for monitoring with a different location manager object, during this or previous launches of your application.
 
     This is done asynchronously and may not be immediately reflected in regions.
     
     - Parameters:
        - region: The region object currently being monitored. If it's nil, all region updates will be stopped.
     
     - Returns: When there is an active region updates request.
     */
    func stopRegionUpdates(_ region: CLRegion?) -> Bool

    /**
     requestRegion:
     
     Asynchronously retrieve the cached state of the specified region.

     - Parameters:
        - region: The region whose state you want to know. This object must be an instance of one of the standard region subclasses provided by Map Kit. You cannot use this method to determine the state of custom regions you define yourself.
        - handler: The single request handler.
     
     - Returns: When there is an active region updates request.
     */
    func requestRegion(_ region: CLRegion?, _ handler: IGZRegionHandler?) -> Bool

    /**
     startDeferredLocationUpdatesForDistance:timeout:
     
     Indicate that the application will allow the location manager to defer
     location updates until an exit criterion is met. This may allow the
     device to enter a low-power state in which updates are held for later
     delivery. Once an exit condition is met, the location manager will
     continue normal updates until this method is invoked again.
 
     Exit conditions, distance and timeout, can be specified using the constants
     CLLocationDistanceMax and CLTimeIntervalMax, respectively, if you are
     trying to achieve an unlimited distance or timeout.
 
     The CLLocationManagerDelegate will continue to receive normal updates as
     long as the application remains in the foreground. While the process is
     in the background, the device may be able to enter a low-power state for
     portions of the specified distance and time interval. While in this
     state, locations will be coalesced for later delivery.
 
     Location updates will be deferred as much as is reasonable to save
     power. If another process is using location, the device may not enter a
     low-power state and instead updates will continue normally. Deferred
     updates may be interspersed with normal updates if the device exits and
     re-enters a low-power state.

     - Parameters:
        - distance: The distance (in meters) from the current location that must be travelled before event delivery resumes. To specify an unlimited distance, pass the CLLocationDistanceMax constant.
        - timeout: The amount of time (in seconds) from the current time that must pass before event delivery resumes. To specify an unlimited amount of time, pass the CLTimeIntervalMax constant.
        - handler: The single request handler.
     */
    func startDeferredLocationUpdates(distance: CLLocationDistance, timeout: TimeInterval, _ handler: IGZLocationsHandler?)

    /**
     stopDeferredLocationUpdates:
     
     Disallow deferred location updates if previously enabled. Any outstanding
     updates will be sent and regular location updates will resume.
     */
    func stopDeferredLocationUpdates()

    /**
     startVisitUpdates:
     
     Begin monitoring for visits.  All CLLLocationManagers allocated by your
     application, both current and future, will deliver detected visits to
     their delegates.  This will continue until -stopMonitoringVisits is sent
     to any such CLLocationManager, even across application relaunch events.
     
     - Parameters:
        - handler: The single request handler.
     */
    func startVisitUpdates(_ handler: IGZVisitHandler?)

    /**
     stopVisitUpdates
     
     Stop monitoring for visits.  To resume visit monitoring, send
     -startVisitUpdates:.
     
     Note that stopping and starting are asynchronous operations and may not
     immediately reflect in delegate callback patterns.
     */
    func stopVisitUpdates()
    
}
