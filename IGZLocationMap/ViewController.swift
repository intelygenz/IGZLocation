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

class ViewController: UIViewController {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var visitLabel: UILabel!
    @IBOutlet private weak var headingLabel: UILabel!

    private let locationManager = IGZLocation.shared
    fileprivate var annotations = [CLLocation]()
    fileprivate var regions = [CLRegion]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager.delegates.append(self)
    }

    func launchLocation() {
        _ = locationManager.authorize(.authorizedAlways) { status in
            if status == .authorizedAlways {
                self.locationManager.requestLocation { location in
                    self.mapView.showsUserLocation = true
                    let region = CLCircularRegion(center: location.coordinate, radius: 50, identifier: UUID().uuidString)
                    self.locationManager.startRegionUpdates(region, sequential: true, { region, state in
                        self.regions.append(region)
                    })
                }

                self.locationManager.startLocationUpdates { locations in
                    self.annotations.append(contentsOf: locations)
                }

                self.locationManager.startVisitUpdated { visit, visiting in
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
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        launchLocation()
    }
}
