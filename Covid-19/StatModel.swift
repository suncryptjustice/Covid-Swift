//
//  StatModel.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 27.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import Foundation

struct StatModel {
    let country: String
    let cases: Int
    let todayCases: Int
    let activeCases: Int
    let deaths: Int
    let todayDeaths: Int
    let recovered: Int
    let inCtriticalCondition: Int
    
    let date: Date
    
    init(country: String,cases: Int, todayCases: Int, activeCases: Int,deaths: Int, todayDeaths: Int, inCriticalCondition: Int,recovered: Int) {
        self.date = Date()
        
        self.country = country
        self.cases = cases
        self.todayCases = todayCases
        self.activeCases = activeCases
        self.deaths = deaths
        self.todayDeaths = todayDeaths
        self.recovered = recovered
        self.inCtriticalCondition = inCriticalCondition
    }
}
