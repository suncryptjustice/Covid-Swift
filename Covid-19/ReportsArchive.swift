//
//  reportsArchive.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 27.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit

class ReportsArchive: UIViewController {
    
    @IBOutlet weak var reportsTableVIew: UITableView!
    var dataSource: [COVID_daily_report] = []
    let dailyReportsController = DailyReportsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportsTableVIew.delegate = self
        reportsTableVIew.dataSource = self
        
        dailyReportsController.grabAllReports { (reports) in
            self.dataSource = reports
            self.reportsTableVIew.reloadData()
        }
        
    }
    
}

extension ReportsArchive: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reportsTableVIew.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath as IndexPath)
        cell.textLabel?.text = dataSource[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "statScreen") as? WorldStatViewController {
            mvc.reportData = dataSource[indexPath.row]
            mvc.controllerRule = .archive
            self.navigationController?.pushViewController(mvc, animated: true)
        }
    }
    
    
}
