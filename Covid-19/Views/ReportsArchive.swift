//
//  reportsArchive.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 27.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit
import SwipeCellKit

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

extension ReportsArchive: UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            print("We just delete some stuff")
            self.dailyReportsController.deleteReport(object: self.dataSource[indexPath.row]) { (finish) in
                self.dataSource.remove(at: indexPath.row)
                self.reportsTableVIew.reloadData()
            }
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = reportsTableVIew.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath as IndexPath) as! ArchiveCell
        cell.textLabel?.text = dataSource[indexPath.row].title
        cell.delegate = self
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


class ArchiveCell: SwipeTableViewCell {
    
}
