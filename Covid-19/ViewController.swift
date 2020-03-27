//
//  ViewController.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 27.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var countryUILabel: UILabel!
    @IBOutlet weak var casesLabel: UILabel!
    @IBOutlet weak var deathsLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var activityController: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityController.startAnimating()
        dispatchDelay(delay: 2) {
            self.askLocation()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getFromNet" {
            if let nextViewController = segue.destination as? WorldStatViewController {
                nextViewController.controllerRule = .netUpdate //Or pass any values
            }
        }
    }


}

extension ViewController: CLLocationManagerDelegate {
    func askLocation() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = manager.location else {
            print("Can't get coordinates of device")
            return
        }
        print("User location = \(location.coordinate.latitude) \(location.coordinate.longitude)")
        
        self.getCountry(location) { (country) in
            if let countryCode = country.0, let countryName = country.1 {
                print("Update label and make request for user country = \(country)")
                let requestController = RequestController()
                requestController.getDataForCountry(countryCode) { (countryData) in
                    print("We get all data about COVID in \(countryName). Create form to show all stuff")
                    
                    self.activityController.startAnimating()
                    self.activityController.isHidden = true
                    self.countryUILabel.text = countryName.capitalized
                    self.casesLabel.text = "Cases: \(countryData.cases) | Today: \(countryData.todayCases) | Active: \(countryData.activeCases)"
                    self.deathsLabel.text = "Deaths: \(countryData.deaths) | Today: \(countryData.todayDeaths)"
                    self.recoveredLabel.text = "Recovered: \(countryData.recovered) | Critical: \(countryData.inCtriticalCondition)"
                    //If we use CoreData to save things we need compare to previous and check dynamic of grown
                    self.stopLocationManager()
                }
            } else {
                print("Update label for something that guide user for all stat")
                self.stopLocationManager()
            }
        }
    }

    func stopLocationManager() {
       locationManager.stopUpdatingLocation()
       locationManager.delegate = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // print the error to see what went wrong
        print("didFailwithError\(error)")
        // stop location manager if failed
        stopLocationManager()
    }
    
    func getCountry(_ location: CLLocation, countryName: (((String?, String?)) -> ())? = nil) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, completionHandler:
                {
                    placemarks, error -> Void in

                    // Place details
                    guard let placeMark = placemarks?.first else { return }
                    if let countryCode = placeMark.isoCountryCode, let country_Name = placeMark.country {
                        print("We manage to get country from coordinates \(country_Name)")
                        countryName?((countryCode, country_Name))
                    } else {
                        print("We can't get country from coordinates")
                    }
            })
        }
    func dispatchDelay(delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
    }
    
}

