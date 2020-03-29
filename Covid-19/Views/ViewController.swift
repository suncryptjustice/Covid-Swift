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
    @IBOutlet weak var virusButton: UIButton!
    @IBOutlet weak var journalButton: UIBarButtonItem!
    @IBOutlet weak var statisticsButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let locationManager = CLLocationManager()
    var shakeTimer = Timer()
    let refreshControl = UIRefreshControl()
    
    var userCountry: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.delegate = self
        self.scrollViewSetup(scrollEnabled: false)
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        self.scrollView.addSubview(refreshControl) // not required when using UITableViewController
        // Do any additional setup after loading the view.
        activityController.startAnimating()
        dispatchDelay(delay: 2) {
            self.askLocation()
        }
        
    }
    
    private func scrollViewSetup(scrollEnabled: Bool) {
        self.scrollView.isScrollEnabled = scrollEnabled
        self.scrollView.alwaysBounceVertical = scrollEnabled
    }
    
    @objc func refresh() {
        print("Refresh")
        refreshControl.beginRefreshing()
        if let country = userCountry {
            self.updateByCountry(countryName: country)
        } else {
            self.updateByGlobal()
        }
    }
    @IBAction func virusButtonPressed(_ sender: UIButton) {
        virusButton.isEnabled = false
        statisticsButton.isEnabled = false
        journalButton.isEnabled = false
        
    }
    @IBAction func statisticsButtonPressed(_ sender: UIButton) {
        virusButton.isEnabled = false
        statisticsButton.isEnabled = false
        journalButton.isEnabled = false
    }
    @IBAction func journalButtonPressed(_ sender: UIButton) {
        virusButton.isEnabled = false
        statisticsButton.isEnabled = false
        journalButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dailyReportsController = DailyReportsController()
        journalButton.isEnabled = dailyReportsController.checkIfHaveStoredData()
        virusButton.isEnabled = true
        statisticsButton.isEnabled = true
        let shaker = UserDefaults.standard.bool(forKey: "shaker")
        if shaker {
            print("Bad, we already press to shaker")
        } else {
            self.activateVirusShaker()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getFromNet" {
            if let nextViewController = segue.destination as? WorldStatViewController {
                nextViewController.controllerRule = .netUpdate //Or pass any values
            }
        }
    }
    
    func activateVirusShaker() {
        shakeTimer = Timer.scheduledTimer(timeInterval: Double.random(in: 3...5), target: self, selector: #selector(shaker), userInfo: nil, repeats: true)
        shakeTimer.tolerance = 3
    }
    
    @objc func shaker(){
        print("Shake baby")
        self.virusButton.shakeAnim()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.shakeTimer.invalidate()
        self.stopLocationManager()
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
        self.getCountry(location, countryName: { (country) in
            if let countryName = country {
                print("Update label and make request for user country = \(countryName)")
                self.updateByCountry(countryName: countryName)
                self.scrollViewSetup(scrollEnabled: true)
            } else {
                print("Update label for something that guide user for all stat")
            }
        }) { (errorFlag) in
            if errorFlag {
                self.locationErrorHandler()
                self.scrollViewSetup(scrollEnabled: true)
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
    
    func getCountry(_ location: CLLocation, countryName: (((String?)) -> ())? = nil, errorFlag: (((Bool)) -> ())? = nil) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "en_US"),completionHandler:
                {
                    placemarks, error -> Void in
                    
                    // Place details
                    guard let placeMark = placemarks?.first else {errorFlag?(true); return }
                    if let country_Name = placeMark.country {
                        print("We manage to get country from coordinates \(country_Name)")
                        countryName?(country_Name)
                    } else {
                        print("We can't get country from coordinates")
                        errorFlag?(true)
                    }
            })
        }
    func dispatchDelay(delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: closure)
    }
    
    func locationErrorHandler() {
        print("We can't get location of user, show him global data instead")
        self.updateByGlobal()
    }
    
    private func updateByCountry(countryName: String) {
        let requestController = RequestController()
        requestController.getDataForCountry(countryName, model: { (countryData) in
            print("We get all data about COVID in \(countryName). Create form to show all stuff")
            
            self.activityController.stopAnimating()
            self.activityController.isHidden = true
            UIView.animate(withDuration: 0.25) {
                self.countryUILabel.text = countryName.capitalized
                self.casesLabel.text = NSLocalizedString("Cases", comment: "") + ": \(countryData.cases) | " + NSLocalizedString("Today", comment: "") + ": \(countryData.todayCases) | " + NSLocalizedString("Active", comment: "") + ": \(countryData.activeCases)"
                self.deathsLabel.text = NSLocalizedString("Deaths", comment: "") + ": \(countryData.deaths) | " + NSLocalizedString("Today", comment: "") + ": \(countryData.todayDeaths)"
                self.recoveredLabel.text = NSLocalizedString("Recovered", comment: "") + ": \(countryData.recovered) | " + NSLocalizedString("Critical", comment: "") + ": \(countryData.inCtriticalCondition)"
                self.countryUILabel.layoutIfNeeded()
                self.casesLabel.layoutIfNeeded()
                self.deathsLabel.layoutIfNeeded()
                self.recoveredLabel.layoutIfNeeded()
                self.refreshControl.endRefreshing()
            }
            self.userCountry = countryName
        }) { (errorFlag) in
            if errorFlag {
                self.locationErrorHandler()
            }
        }
    }
    
    private func updateByGlobal() {
        let requestController = RequestController()
        requestController.getGlobalData(globalData: { (globalData) in
            UIView.animate(withDuration: 0.25) {
                self.countryUILabel.text = NSLocalizedString("World Statistics",comment: "")
                self.casesLabel.text = NSLocalizedString("Cases", comment: "") + ": \(globalData.0)\n" + NSLocalizedString("Deaths", comment: "") + ": \(globalData.1)\n" + NSLocalizedString("Recovered", comment: "") + ": \(globalData.2)"
                self.countryUILabel.layoutIfNeeded()
                self.casesLabel.layoutIfNeeded()
            }
            self.activityController.stopAnimating()
            self.activityController.isHidden = true
            self.refreshControl.endRefreshing()
        }) { (errorFlag) in
            if errorFlag {
                self.troubleshootingAlert {
                    self.locationErrorHandler()
                }
            }
        }
    }
    
    
}


extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            scrollView.contentOffset.y = 0
        }
    }
   
}
