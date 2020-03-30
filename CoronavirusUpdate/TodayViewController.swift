//
//  TodayViewController.swift
//  CoronavirusUpdate
//
//  Created by Ilia Zhegunov on 30.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    enum loadingProcess {
        case haveCountry
        case dontHaveCountry
    }
        
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var cases: UILabel!
    @IBOutlet weak var deaths: UILabel!
    
    var widgetInit: loadingProcess?
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        widgetInit = self.checkIfHaveStoredData()
        switch widgetInit {
        case .dontHaveCountry:
            self.globalDataSetup()
        case .haveCountry:
            self.countryDataSetup()
        case nil:
            cases.isHidden = true
            deaths.isHidden = true
            countryName.isHidden = true
            self.createGoToMainAppButton()
            print("User don't use app yet")
        
        }
        // Do any additional setup after loading the view.
    }
    
    func checkIfHaveStoredData() -> loadingProcess? {
        if UserDefaults(suiteName: "group.Covid")!.string(forKey: "userCountry") != nil {
            return .haveCountry
        } else if UserDefaults(suiteName: "group.Covid")!.string(forKey: "cases") != nil {
            return .dontHaveCountry
        } else {
            return nil
        }
    }
    
    func globalDataSetup() {
        countryName.text = NSLocalizedString("World Statistics",comment: "")
        cases.text = NSLocalizedString("Cases", comment: "") + ": \(UserDefaults(suiteName: "group.todayCases")!.integer(forKey: "cases"))\n" + NSLocalizedString("Deaths", comment: "") + ": \(UserDefaults(suiteName: "group.todayCases")!.integer(forKey: "deaths"))\n" + NSLocalizedString("Recovered", comment: "") + ": \(UserDefaults(suiteName: "group.todayCases")!.integer(forKey: "recovered"))"
    }
    
    func countryDataSetup() {
        countryName.text = UserDefaults(suiteName: "group.Covid")!.string(forKey: "userCountry")
        cases.text = NSLocalizedString("Cases", comment: "") + ": \(UserDefaults(suiteName: "group.Covid")!.integer(forKey: "totalCases")) | " + NSLocalizedString("Today", comment: "") + ": \(UserDefaults(suiteName: "group.todayCases")!.integer(forKey: "userCountry"))"
        deaths.text =  NSLocalizedString("Deaths", comment: "") + ": \(UserDefaults(suiteName: "group.totalDeaths")!.integer(forKey: "userCountry")) | " + NSLocalizedString("Today", comment: "") + ": \(UserDefaults(suiteName: "group.todayDeaths")!.integer(forKey: "userCountry"))"
    }
    
    func createGoToMainAppButton() {
        let virusButton = UpdateView.instanceFromNib() as! UpdateView
        virusButton.frame = .init(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        virusButton.center = self.view.center
        virusButton.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        virusButton.delegate = self
        self.view.addSubview(virusButton)
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    
    
    
}

extension TodayViewController: virusButtonDeleGate {
    func pressed() {
        print("Button was pressed")
        extensionContext?.open(URL(string: "covid-19://")! , completionHandler: nil)
    }
    
    
}
