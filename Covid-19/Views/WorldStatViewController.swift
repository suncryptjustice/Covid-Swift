//
//  WorldStatViewController.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 27.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit

class WorldStatViewController: UIViewController {
    
    enum sortingOrder {
        case totalCases
        case todayCases
        case totalDeaths
        case todayDeaths
        case recovered
        case critical
    }
    
    @IBOutlet weak var statTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var globalCasesLabel: UILabel!
    @IBOutlet weak var globalDeathsLabel: UILabel!
    @IBOutlet weak var globalRecoveredLabel: UILabel!
    @IBOutlet weak var sectionView: UIView!
    @IBOutlet weak var globalView: UIView!
    
    var controllerRule: controllerWorkRule!
    var reportData: COVID_daily_report?
    var refreshControl = UIRefreshControl()
        
    var casesForCountriesNet: [StatModel] = []
    var casesFromReport: [Country_daily_report] = []
    let requestController = RequestController()
    var globalData: (Int64, Int64, Int64)?
    
    let dailyReportsController = DailyReportsController()
    
    @IBOutlet weak var sectionViewConstraint: NSLayoutConstraint!
    var isSectionViewIsHidden: Bool = false
    
    
    enum controllerWorkRule {
        case archive
        case netUpdate
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllerSetup()
        
        
}
    @objc func refresh() {
        self.refreshControl.beginRefreshing()
        startSetUP(rule: controllerRule)
    }
    
//    func gestureFunctionality() {
//        let tapForDissmissKeyboard = UITapGestureRecognizer(target: self, action: #selector(self.hideKyeboard(gesture:)))
//        let swipeUP = UISwipeGestureRecognizer(target: self, action: #selector(self.hideGlobalData(gesture:)))
//        swipeUP.direction = .up
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.showGlobalData(gesture:)))
//        swipeDown.direction = .down
//        self.sectionView.addGestureRecognizer(swipeUP)
//        self.sectionView.addGestureRecognizer(swipeDown)
//        self.statTableView.addGestureRecognizer(tapForDissmissKeyboard)
//    }
    
    @objc func hideKyeboard(gesture: UITapGestureRecognizer) {
        self.searchBar.endEditing(true)
    }
    
//    @objc func showGlobalData(gesture: UISwipeGestureRecognizer) {
//        print("User tap to section view")
//        if isSectionViewIsHidden {
//            UIView.animate(withDuration: 0.25, animations: {
//                self.sectionViewConstraint.isActive = false
//                self.globalView.alpha = 1
//                self.view.layoutIfNeeded()
//            }) { (finish) in
//                if finish {
//                    self.isSectionViewIsHidden = !self.isSectionViewIsHidden
//                }
//            }
//        }
//    }
//
//    @objc func hideGlobalData(gesture: UISwipeGestureRecognizer) {
//        if !isSectionViewIsHidden {
//            UIView.animate(withDuration: 0.25, animations: {
//                self.sectionViewConstraint.isActive = true
//                self.globalView.alpha = 0
//                self.view.layoutIfNeeded()
//            }) { (finish) in
//                if finish {
//                    self.isSectionViewIsHidden = !self.isSectionViewIsHidden
//                }
//            }
//        }
//    }
    
    func viewControllerSetup() {
        //gestureFunctionality()
        self.statTableView.delegate = self
        self.statTableView.dataSource = self
        self.searchBar.delegate = self
        self.searchBar.setImage(UIImage.init(systemName: "list.dash"), for: .bookmark, state: .normal)
        
        self.statTableView.register(UINib(nibName: "globalStatTableViewCell", bundle: nil), forCellReuseIdentifier: "covidGlobalStatCell")
        self.statTableView.register(UINib(nibName: "covidStatTableViewCell", bundle: nil), forCellReuseIdentifier: "covidTableViewCell")
        if controllerRule == .netUpdate {
            self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
            //self.refreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Updating latest information about COVID-19", comment: ""))
            self.statTableView.addSubview(refreshControl) // not required when using UITableViewController
        }
        
        startSetUP(rule: controllerRule)
    }
    
    private func startSetUP(rule: controllerWorkRule) {
        switch rule {
        case .archive:
            print("Use core data to fill tableview")
            guard let report = reportData else { return }
            dailyReportsController.grabAllCountriesReports(report: report) { (countriesCases) in
                self.casesFromReport = countriesCases
                self.globalData = (report.cases, report.deaths, report.recovered)
                self.statTableView.reloadData()
            }
        case .netUpdate:
            
            self.dailyReportsController.checkIfAlreadyHaveDailyReport { (report) in
                if let covid_report = report {
                    print("Grab from CoreData")
                    self.dailyReportsController.grabAllCountriesReports(report: covid_report) { (countriesCases) in
                        self.casesForCountriesNet = countriesCases.map({ (transform) -> StatModel in
                            StatModel.init(country: transform.country_name!, cases: Int(transform.totalCases), todayCases: Int(transform.todayCases), activeCases: Int(transform.activeCases), deaths: Int(transform.totalDeaths), todayDeaths: Int(transform.todayDeaths), inCriticalCondition: Int(transform.criticalCondition), recovered: Int(transform.recovered))
                        }).sorted(by: { (element1, element2) -> Bool in
                            return element1.cases > element2.cases
                        })
                        self.globalData = (covid_report.cases, covid_report.deaths, covid_report.recovered)
                        self.statTableView.reloadData()
                    }
                        print("We already have this report, start updating")
                    self.requestController.getGlobalData(globalData: { (globalData) in
                        self.requestController.getAllData { (statistics) in
                                self.casesForCountriesNet.append(contentsOf: statistics)
                                self.globalData = (Int64(globalData.0), Int64(globalData.1), Int64(globalData.2))
                                self.refreshControl.endRefreshing()
                                self.statTableView.reloadData()
                                 self.dailyReportsController.updateDailyReport(parent: covid_report, newData: statistics)
                                                       self.dailyReportsController.updateDailyReportWithGlobalData(parent: covid_report, newData: (globalData.0, globalData.1, globalData.2))
                            
                        }
                    }, errorFlag: nil)
                    
                       
                    } else {
                        print("We currently don't have today report, create the newOne")
                    self.requestController.getGlobalData(globalData: { (globalData) in
                        self.globalData = (Int64(globalData.0), Int64(globalData.1), Int64(globalData.2))
                        self.requestController.getAllData { (statistics) in
                            self.casesForCountriesNet = statistics
                            self.statTableView.reloadData()
                            self.dailyReportsController.createDailyReport(globalData: (globalData.0, globalData.1, globalData.2)) { (newReport) in
                                for all in statistics {
                                self.dailyReportsController.createCountryDailyReport(parent: newReport, report: all)
                                }
                                
                                
                            }
                        }
                        
                    }, errorFlag: nil)
                        
                        
                }
            }
            
        }
    }
}

extension WorldStatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Coronavirus Global Cases", comment: "")
        } else {
            return NSLocalizedString("Confirmed Cases by Country", comment: "")
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
        switch controllerRule {
        case .archive:
            return casesFromReport.count
        case .netUpdate:
            return casesForCountriesNet.count
        case .none:
            return 0
        }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = statTableView.dequeueReusableCell(withIdentifier: "covidGlobalStatCell", for: indexPath as IndexPath) as! GlobalStatTableViewCell
            
            cell.casesTitleLabel.text = NSLocalizedString("CasesShort", comment: "")
            cell.deathsTitleLabel.text = NSLocalizedString("Deaths", comment: "")
            cell.recoveredTitleLabel.text = NSLocalizedString("Recovered", comment: "")
            if let cases = globalData?.0, let deaths = globalData?.1, let recovered = globalData?.2 {
            cell.casesAmmountLabel.text = String(cases)
            cell.deathsAmmountLabel.text = String(deaths)
            cell.recoveredAmmountLabel.text = String(recovered)
            } else {
                cell.casesAmmountLabel.text = "-"
                cell.deathsAmmountLabel.text = "-"
                cell.recoveredAmmountLabel.text = "-"
            }
            
            return cell
            
        } else {
        let cell = statTableView.dequeueReusableCell(withIdentifier: "covidTableViewCell", for: indexPath as IndexPath) as! CovidStatTableViewCell
        switch controllerRule {
        case .archive:
            cell.countryName.text = casesFromReport[indexPath.row].country_name
            cell.casesAmmount.text = NSLocalizedString("Cases", comment: "") + ": \(casesFromReport[indexPath.row].totalCases) | " + NSLocalizedString("Today", comment: "") + ": \(casesFromReport[indexPath.row].todayCases) | " + NSLocalizedString("Active", comment: "") + ": \(casesFromReport[indexPath.row].activeCases)"
            cell.deathsAmmount.text = NSLocalizedString("Deaths", comment: "") + ": \(casesFromReport[indexPath.row].totalDeaths) | " + NSLocalizedString("Today", comment: "") + ": \(casesFromReport[indexPath.row].todayDeaths)"
            cell.recoveredAmmount.text = NSLocalizedString("Recovered", comment: "") + ": \(casesFromReport[indexPath.row].recovered) | " + NSLocalizedString("Critical", comment: "") + ": \(casesFromReport[indexPath.row].criticalCondition)"
        case .netUpdate:
            cell.countryName.text = casesForCountriesNet[indexPath.row].country
            cell.casesAmmount.text = NSLocalizedString("Cases", comment: "") + ": \(casesForCountriesNet[indexPath.row].cases) | " + NSLocalizedString("Today", comment: "") + ": \(casesForCountriesNet[indexPath.row].todayCases) | " + NSLocalizedString("Active", comment: "") + ": \(casesForCountriesNet[indexPath.row].activeCases)"
            cell.deathsAmmount.text = NSLocalizedString("Deaths", comment: "") + ": \(casesForCountriesNet[indexPath.row].deaths) | " + NSLocalizedString("Today", comment: "") + ": \(casesForCountriesNet[indexPath.row].todayDeaths)"
            cell.recoveredAmmount.text = NSLocalizedString("Recovered", comment: "") + ": \(casesForCountriesNet[indexPath.row].recovered) | " + NSLocalizedString("Critical", comment: "") + ": \(casesForCountriesNet[indexPath.row].inCtriticalCondition)"
            
        case .none:
            return UITableViewCell()
        }
        
        
        return cell
        }
    }
    
    
}


extension WorldStatViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch controllerRule {
        case .netUpdate:
            guard searchText != ""  else { requestController.getAllData { (statistics) in
            self.casesForCountriesNet = statistics
            self.statTableView.reloadData()
            }; return }
            let saver = casesForCountriesNet
            casesForCountriesNet = casesForCountriesNet.filter({ element -> Bool in
                return element.country.lowercased().contains(searchText.lowercased())
            })
            if casesForCountriesNet.isEmpty {
                casesForCountriesNet = saver
            }
        case .archive:
            guard searchText != ""  else { dailyReportsController.grabAllCountriesReports(report: reportData!) { (countriesCases) in
                self.casesFromReport = countriesCases
                self.statTableView.reloadData()
            }; return }
            casesFromReport = casesFromReport.filter({ element -> Bool in
                return element.country_name!.lowercased().contains(searchText.lowercased())
            })
        case .none:
            print("Never happen")
        }
        
        statTableView.reloadData()
        
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let alert = UIAlertController(title: NSLocalizedString("Sorting", comment: ""), message: "Choose sort parameter", preferredStyle: .alert)
        let mostCases = UIAlertAction(title: NSLocalizedString("Total cases", comment: ""), style: .default) { (handler) in
            self.sorting(sortingType: .totalCases)
            self.statTableView.reloadData()
        }
        let newCases = UIAlertAction(title: NSLocalizedString("Today new cases", comment: ""), style: .default) { (handler) in
            self.sorting(sortingType: .todayCases)
            self.statTableView.reloadData()
        }
        let mostDeaths = UIAlertAction(title: NSLocalizedString("Total deaths", comment: ""), style: .default) { (handler) in
            self.sorting(sortingType: .totalDeaths)
            self.statTableView.reloadData()
        }
        let newDeaths = UIAlertAction(title: NSLocalizedString("Today new deaths", comment: ""), style: .default) { (handler) in
            self.sorting(sortingType: .todayDeaths)
            self.statTableView.reloadData()
        }
        let recovered = UIAlertAction(title: NSLocalizedString("Recovered", comment: ""), style: .default) { (handler) in
            self.sorting(sortingType: .recovered)
            self.statTableView.reloadData()
        }
        let critical = UIAlertAction(title: NSLocalizedString("Critical condition", comment: ""), style: .default) { (handler) in
            self.sorting(sortingType: .critical)
            self.statTableView.reloadData()
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (handler) in
            print("Nothing changes")
        }
        alert.addAction(mostCases)
        alert.addAction(newCases)
        alert.addAction(mostDeaths)
        alert.addAction(newDeaths)
        alert.addAction(recovered)
        alert.addAction(cancel)
        alert.addAction(critical)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func sorting(sortingType: sortingOrder) {
        switch controllerRule {
        case .archive:
            switch sortingType {
            case .totalCases:
                casesFromReport = casesFromReport.sorted(by: { (element1, element2) -> Bool in
                    return element1.totalCases > element2.totalCases
                })
            case .todayCases:
                casesFromReport = casesFromReport.sorted(by: { (element1, element2) -> Bool in
                    return element1.todayCases > element2.todayCases
                })
            case .totalDeaths:
                casesFromReport = casesFromReport.sorted(by: { (element1, element2) -> Bool in
                    return element1.totalDeaths > element2.totalDeaths
                })
            case .todayDeaths:
                casesFromReport = casesFromReport.sorted(by: { (element1, element2) -> Bool in
                    return element1.todayDeaths > element2.todayDeaths
                })
            case .recovered:
                casesFromReport = casesFromReport.sorted(by: { (element1, element2) -> Bool in
                    return element1.recovered > element2.recovered
                })
            case .critical:
                casesFromReport = casesFromReport.sorted(by: { (element1, element2) -> Bool in
                    return element1.criticalCondition > element2.criticalCondition
                })
            }
            
        case .netUpdate:
            switch sortingType {
            case .totalCases:
                casesForCountriesNet = casesForCountriesNet.sorted(by: { (element1, element2) -> Bool in
                    return element1.cases > element2.cases
                })
            case .todayCases:
                casesForCountriesNet = casesForCountriesNet.sorted(by: { (element1, element2) -> Bool in
                    return element1.todayCases > element2.todayCases
                })
            case .totalDeaths:
                casesForCountriesNet = casesForCountriesNet.sorted(by: { (element1, element2) -> Bool in
                    return element1.deaths > element2.deaths
                })
            case .todayDeaths:
                casesForCountriesNet = casesForCountriesNet.sorted(by: { (element1, element2) -> Bool in
                    return element1.todayDeaths > element2.todayDeaths
                })
            case .recovered:
                casesForCountriesNet = casesForCountriesNet.sorted(by: { (element1, element2) -> Bool in
                    return element1.recovered > element2.recovered
                })
            case .critical:
                casesForCountriesNet = casesForCountriesNet.sorted(by: { (element1, element2) -> Bool in
                    return element1.inCtriticalCondition > element2.inCtriticalCondition
                })
            }
        case .none:
            print("Not real")
        }
    }
    
}
