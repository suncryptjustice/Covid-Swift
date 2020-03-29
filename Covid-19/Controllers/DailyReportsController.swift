//
//  DailyReportsController.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 27.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit
import CoreData

class DailyReportsController {
    
    func createDailyReport(globalData: (Int, Int, Int),newBrandReport: (((COVID_daily_report)) -> ())? = nil) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let report = COVID_daily_report(context: context)

        report.created_at = Date()
        report.updated_at = Date()
        report.id = NSUUID().uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        report.title = NSLocalizedString("Daily report", comment: "") + " \(dateFormatter.string(from: Date()))"
        report.cases = Int64(globalData.0)
        report.deaths = Int64(globalData.1)
        report.recovered = Int64(globalData.2)
        
        do{
            try context.save()
            newBrandReport?(report)
        } catch {
            print(error)
        }
        
    }
    
    func createCountryDailyReport(parent: COVID_daily_report, report: StatModel) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "COVID_daily_report")
//        fetchRequest.predicate = NSPredicate(format: "parentReport.id MATCHES %@", parent.id!)

        do{
                let countryReport = Country_daily_report(context: context)
                countryReport.country_name = report.country
                countryReport.totalCases = Int64(report.cases)
                countryReport.todayCases = Int64(report.todayCases)
                countryReport.activeCases = Int64(report.activeCases)
                countryReport.totalDeaths = Int64(report.deaths)
                countryReport.todayDeaths = Int64(report.todayDeaths)
                countryReport.recovered = Int64(report.recovered)
                countryReport.criticalCondition = Int64(report.inCtriticalCondition)
                countryReport.created_at = Date()
                countryReport.updated_at = Date()
                countryReport.parentReport = parent
                try context.save()
                print("We create daily report for \(report.country) at CoreData")
        } catch {
            print(error)
        }
        
    }
    
    func updateDailyReport(parent: COVID_daily_report, newData: [StatModel]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country_daily_report")
        
        fetchRequest.predicate = NSPredicate(format: "parentReport.id MATCHES %@", parent.id!)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            if let report = try? (context.fetch(fetchRequest) as! [Country_daily_report]){
                for elements in report {
                    for models in newData {
                        if elements.country_name == models.country {
                            elements.totalCases = Int64(models.cases)
                            elements.activeCases = Int64(models.activeCases)
                            elements.todayCases = Int64(models.todayCases)
                            elements.totalDeaths = Int64(models.deaths)
                            elements.todayDeaths = Int64(models.todayDeaths)
                            elements.recovered = Int64(models.recovered)
                            elements.updated_at = Date()
                            elements.criticalCondition = Int64(models.inCtriticalCondition)
                        }
                    }
                }
            }
            try context.save()
            print("We finish add countries data")
        }catch {
            print("error")
        }
    }
    
    func updateDailyReportWithGlobalData(parent: COVID_daily_report, newData: (Int, Int, Int)) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "COVID_daily_report")
        
        fetchRequest.predicate = NSPredicate(format: "id MATCHES %@", parent.id!)
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            if let report = try? (context.fetch(fetchRequest) as! [COVID_daily_report]){
                if let dailyReport = report.first{
                    dailyReport.cases = Int64(newData.0)
                    dailyReport.deaths = Int64(newData.1)
                    dailyReport.recovered = Int64(newData.2)
                    dailyReport.updated_at = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                    dailyReport.title = NSLocalizedString("Daily report", comment: "") + " \(dateFormatter.string(from: Date()))"
                }
            }
            try context.save()
            print("We finish add global data to daily report")
        }catch {
            print("error")
        }
    }
    
    func checkIfHaveStoredData() -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "COVID_daily_report")
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let result = try context.fetch(fetchRequest) as! [COVID_daily_report]
            if result.first != nil {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func checkIfAlreadyHaveDailyReport(data: [StatModel], comlition: (((COVID_daily_report?)) -> ())? = nil){
        if let element = data.first {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "COVID_daily_report")
        
            fetchRequest.predicate = NSPredicate(format: "created_at <= %@", element.date as NSDate)
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            do {
                let result = try context.fetch(fetchRequest) as! [COVID_daily_report]
                if let report = result.first(where: { (db_report) -> Bool in
                    let datesAreInTheSameDay = Calendar.current.isDate(db_report.created_at!, equalTo: data.first!.date, toGranularity:.day)
                    return datesAreInTheSameDay
                }) {
                    print("We manage to find report from the same day")
                    comlition?(report)
                } else {
                    print("Can't find report from that day")
                    comlition?(nil)
                }
            } catch {
                
            }
            
        }
        
    }
    
    func grabAllReports(comlition: ((([COVID_daily_report])) -> ())? = nil) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<COVID_daily_report> = COVID_daily_report.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
        
        do {
            let result: [COVID_daily_report] = try context.fetch(fetchRequest)
            comlition?(result)
        } catch {
            print(error)
        }
        
    }
    
    func grabAllCountriesReports(report: COVID_daily_report, comlition: ((([Country_daily_report])) -> ())? = nil) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Country_daily_report> = Country_daily_report.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "parentReport.id MATCHES %@", report.id!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "totalCases", ascending: false)]
        
        do {
            let result: [Country_daily_report] = try context.fetch(fetchRequest)
            print("We get \(result.count) objects from report")
            comlition?(result)
        } catch {
            print(error)
        }
        
    }
    
    func deleteReport(object: COVID_daily_report, handler: (((Bool)) -> ())? = nil) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<COVID_daily_report> = COVID_daily_report.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id MATCHES %@", object.id!)
        
        do {
            let result: [COVID_daily_report] = try context.fetch(fetchRequest)
            if let reportForDelete = result.first {
                context.delete(reportForDelete)
                print("We delete report with id: \(reportForDelete.id!)")
                handler?(true)
            }
            
        }catch {
            print("failed to delete document")
        }
    }
    
}
