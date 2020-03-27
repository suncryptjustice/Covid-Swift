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
    
    func createDailyReport(newBrandReport: (((COVID_daily_report)) -> ())? = nil) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let report = COVID_daily_report(context: context)

        report.date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        report.title = "Daily report \(dateFormatter.string(from: Date()))"
        
        
        do{
            try context.save()
            newBrandReport?(report)
        } catch {
            print(error)
        }
        
    }
    
    func createCountryDailyReport(parent: COVID_daily_report, report: StatModel) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "COVID_daily_report")
        fetchRequest.predicate = NSPredicate(format: "title MATCHES %@", "Daily report \(dateFormatter.string(from: Date()))")

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
                countryReport.date = Date()
                countryReport.parentReport = parent
                try context.save()
                print("We create daily report for \(report.country) at CoreData")
        } catch {
            print(error)
        }
        
    }
    
    func updateDailyReport(parent: COVID_daily_report, newData: [StatModel]) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country_daily_report")
        
        fetchRequest.predicate = NSPredicate(format: "parentReport.title MATCHES %@", parent.title!)
        
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
    
    func checkIfAlreadyHaveDailyReport(data: [StatModel], comlition: (((COVID_daily_report?)) -> ())? = nil){
        if let element = data.first {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "COVID_daily_report")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let title = "Daily report \(dateFormatter.string(from: element.date))"
            
            fetchRequest.predicate = NSPredicate(format: "title MATCHES %@", title)
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            do {
                let result = try context.fetch(fetchRequest) as! [COVID_daily_report]
                if let report = result.first {
                    comlition?(report)
                } else {
                    comlition?(nil)
                }
            } catch {
                
            }
            
        }
        
    }
    
    func grabAllReports(comlition: ((([COVID_daily_report])) -> ())? = nil) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<COVID_daily_report> = COVID_daily_report.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
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
        fetchRequest.predicate = NSPredicate(format: "parentReport.title MATCHES %@", report.title!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "totalCases", ascending: false)]
        
        do {
            let result: [Country_daily_report] = try context.fetch(fetchRequest)
            print("We get \(result.count) objects from report")
            comlition?(result)
        } catch {
            print(error)
        }
        
    }
    
}
