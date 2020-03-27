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
    }
    
    @IBOutlet weak var statTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var controllerRule: controllerWorkRule!
    var reportData: COVID_daily_report?
        
    var casesForCountriesNet: [StatModel] = []
    var casesFromReport: [Country_daily_report] = []
    let requestController = RequestController()
    
    let dailyReportsController = DailyReportsController()
    
    enum controllerWorkRule {
        case archive
        case netUpdate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statTableView.delegate = self
        self.statTableView.dataSource = self
        self.searchBar.delegate = self
        
        self.searchBar.setImage(UIImage.init(systemName: "list.dash"), for: .bookmark, state: .normal)
        
        self.statTableView.register(UINib(nibName: "covidStatTableViewCell", bundle: nil), forCellReuseIdentifier: "covidTableViewCell")
        
        startSetUP(rule: controllerRule)
        
}
    
    func startSetUP(rule: controllerWorkRule) {
        switch rule {
        case .archive:
            print("Use core data to fill tableview")
            guard let report = reportData else { return }
            dailyReportsController.grabAllCountriesReports(report: report) { (countriesCases) in
                self.casesFromReport = countriesCases
                self.statTableView.reloadData()
            }
        case .netUpdate:
            requestController.getAllData { (statistics) in
                    self.casesForCountriesNet.append(contentsOf: statistics)
                    self.statTableView.reloadData()
                    self.dailyReportsController.checkIfAlreadyHaveDailyReport(data: statistics) { (report) in
                        if let covid_report = report {
                            print("We already have this report, start updating")
                            self.dailyReportsController.updateDailyReport(parent: covid_report, newData: statistics)
                        } else {
                            print("We currently don't have today report, create the newOne")
                            self.dailyReportsController.createDailyReport { (newReport) in
                                for all in statistics {
                                self.dailyReportsController.createCountryDailyReport(parent: newReport, report: all)
                                }
                            }
                            
                    }
                }
                
            }
        }
    }
}

extension WorldStatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch controllerRule {
        case .archive:
            return casesFromReport.count
        case .netUpdate:
            return casesForCountriesNet.count
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = statTableView.dequeueReusableCell(withIdentifier: "covidTableViewCell", for: indexPath as IndexPath) as! CovidStatTableViewCell
        switch controllerRule {
        case .archive:
            cell.countryName.text = casesFromReport[indexPath.row].country_name
            cell.casesAmmount.text = "Cases: \(casesFromReport[indexPath.row].totalCases) | Today: \(casesFromReport[indexPath.row].totalCases) | Active: \(casesFromReport[indexPath.row].activeCases)"
            cell.deathsAmmount.text = "Deaths: \(casesFromReport[indexPath.row].totalDeaths) | Today: \(casesFromReport[indexPath.row].todayDeaths)"
            cell.recoveredAmmount.text = "Recovered: \(casesFromReport[indexPath.row].recovered) | Critical: \(casesFromReport[indexPath.row].criticalCondition)"
        case .netUpdate:
            cell.countryName.text = casesForCountriesNet[indexPath.row].country
            cell.casesAmmount.text = "Cases: \(casesForCountriesNet[indexPath.row].cases) | Today: \(casesForCountriesNet[indexPath.row].todayCases) | Active: \(casesForCountriesNet[indexPath.row].activeCases)"
            cell.deathsAmmount.text = "Deaths: \(casesForCountriesNet[indexPath.row].deaths) | Today: \(casesForCountriesNet[indexPath.row].todayDeaths)"
            cell.recoveredAmmount.text = "Recovered: \(casesForCountriesNet[indexPath.row].recovered) | Critical: \(casesForCountriesNet[indexPath.row].inCtriticalCondition)"
        case .none:
            return UITableViewCell()
        }
        
        
        return cell
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
        let alert = UIAlertController(title: "Sorting", message: "Choose type of sorting that you want", preferredStyle: .alert)
        let mostCases = UIAlertAction(title: "Total cases", style: .default) { (handler) in
            self.sorting(sortingType: .totalCases)
            self.statTableView.reloadData()
        }
        let newCases = UIAlertAction(title: "Today new cases", style: .default) { (handler) in
            self.sorting(sortingType: .todayCases)
            self.statTableView.reloadData()
        }
        let mostDeaths = UIAlertAction(title: "Total deaths", style: .default) { (handler) in
            self.sorting(sortingType: .totalDeaths)
            self.statTableView.reloadData()
        }
        let newDeaths = UIAlertAction(title: "Today new deaths", style: .default) { (handler) in
            self.sorting(sortingType: .todayDeaths)
            self.statTableView.reloadData()
        }
        let recovered = UIAlertAction(title: "Recovered", style: .default) { (handler) in
            self.sorting(sortingType: .recovered)
            self.statTableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (handler) in
            print("Nothing changes")
        }
        alert.addAction(mostCases)
        alert.addAction(newCases)
        alert.addAction(mostDeaths)
        alert.addAction(newDeaths)
        alert.addAction(recovered)
        alert.addAction(cancel)
        
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
            }
        case .none:
            print("Not real")
        }
    }
    
}


