//
//  ViewController.swift
//  IGZLocationMap
//
//  Created by Alejandro Ruperez Hernando on 3/2/17.
//  Copyright © 2017 Intelygenz. All rights reserved.
//

import UIKit
import MapKit
import IGZLocation

extension CLLocation: MKAnnotation {}

extension CLCircularRegion: MKOverlay {
    public var coordinate: CLLocationCoordinate2D {
        return center
    }

    public var boundingMapRect: MKMapRect {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(center, radius*2, radius*2)
        let a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(coordinateRegion.center.latitude + coordinateRegion.span.latitudeDelta / 2, coordinateRegion.center.longitude - coordinateRegion.span.longitudeDelta / 2))
        let b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(coordinateRegion.center.latitude - coordinateRegion.span.latitudeDelta / 2, coordinateRegion.center.longitude + coordinateRegion.span.longitudeDelta / 2))
        return MKMapRectMake(min(a.x,b.x), min(a.y,b.y), abs(a.x-b.x), abs(a.y-b.y))
    }

    open override func isEqual(_ region: Any?) -> Bool {
        guard let region = region as? CLCircularRegion else {
            return false
        }
        return identifier == region.identifier && center == region.center && radius == region.radius
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

class ViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var visitLabel: UILabel!
    @IBOutlet private weak var headingLabel: UILabel!

    private let locationManager: IGZLocationManager = IGZLocation.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.delegates.append(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        launchLocation()
    }

    func launchLocation() {
        _ = locationManager.authorize(.authorizedAlways) { status in
            if status == .authorizedAlways {
                if self.locationManager.regions.count > 0 {
                    _ = self.locationManager.stopRegionUpdates(nil)
                }
                if #available(iOS 9.0, *) {
                    self.locationManager.background = true
                    self.locationManager.requestLocation { location in
                        self.mapView.showsUserLocation = true
                        let region = CLCircularRegion(center: location.coordinate, radius: 100, identifier: UUID().uuidString)
                        self.locationManager.startRegionUpdates(region, sequential: true, notify: true, { region, state in
                            if let region = region as? CLCircularRegion, !self.mapView.overlays.contains(where: { overlay -> Bool in
                                return overlay as? CLCircularRegion == region
                            }) {
                                self.mapView.addOverlays([region])
                            }
                        })
                    }
                }

                self.locationManager.startLocationUpdates { locations in
                    self.mapView.addAnnotations(locations)
                }

                self.locationManager.startVisitUpdates { visit, visiting in
                    self.visitLabel.text = visiting ? "VISITING: \(visit.coordinate.latitude), \(visit.coordinate.longitude)" : nil
                }

                self.locationManager.startHeadingUpdates { heading in
                    self.headingLabel.text = "\(heading.magneticHeading)"
                }
            }
        }
    }

}

extension ViewController: IGZLocationDelegate {
    func didFail(_ error: IGZLocationError) {
        let alertController = UIAlertController(title: "ERROR", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.userTrackingMode = .followWithHeading
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let region = overlay as? CLCircularRegion {
            let renderer = MKCircleRenderer(circle: MKCircle(center: region.center, radius: region.radius))
            renderer.fillColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 0.5)
            return renderer
        }

        return MKOverlayRenderer(overlay: overlay)
    }
}
