//
//  RequestController.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 27.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RequestController {
    
    let headers: HTTPHeaders = [
        "x-rapidapi-host": "covid-19-coronavirus-statistics.p.rapidapi.com",
        "x-rapidapi-key": "870bc26c4cmshd40f48e35779abcp12ffa0jsn4a4beddda2c6"
    ]

    
    func getDataForCountry(_ countryName: String?, model: (((StatModel)) -> ())? = nil) {
        
        let parameter = countryName ?? ""
        let url = "https://coronavirus-19-api.herokuapp.com/countries/\(parameter)"
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).validate().validate(contentType: ["application/json"])
                .responseJSON() { response in
                    
                    //print("Request: \(String(describing: response.request))")   // original url request
                    //print("Response: \(String(describing: response.response))") // http url response
                    print("Result: \(response.result)")                         // response serialization result
                    
                    switch response.result {
                        
                    case .success:
                        print("Success")
                        if let data = response.data {
                            do {
                                let subJson = try JSON(data: data)
                                let country = subJson["country"].stringValue
                                let confirmedCases = subJson["cases"].intValue
                                let todayCases = subJson["todayCases"].intValue
                                let activeCases = subJson["active"].intValue
                                let deaths = subJson["deaths"].intValue
                                let todayDeaths = subJson["todayDeaths"].intValue
                                let recovered = subJson["recovered"].intValue
                                let inCriticalCondition = subJson["critical"].intValue
                                print("Country: \(country)\nConfirmed cases: \(confirmedCases)\nDeaths: \(deaths)\nRecovered: \(recovered)")
                                
                                let statModel = StatModel(country: country, cases: confirmedCases, todayCases: todayCases, activeCases: activeCases, deaths: deaths, todayDeaths: todayDeaths, inCriticalCondition: inCriticalCondition, recovered: recovered)
                                model?(statModel)
                            } catch {
                                print("Error to get user information")
                            }
                        }
                        
                    case .failure( _):
                        print("Failure")
                    }
            }
        }
    
    func getAllData(model: ((([StatModel])) -> ())? = nil) {
    
    let url = "https://coronavirus-19-api.herokuapp.com/countries"
        var statistics: [StatModel] = []
        
    AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().validate(contentType: ["application/json"])
            .responseJSON() { response in
                
                //print("Request: \(String(describing: response.request))")   // original url request
                //print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                switch response.result {
                    
                case .success:
                    print("Success")
                    if let data = response.data {
                        do {
                            let json = try JSON(data: data)
                            
                            for (_, subJson) in json {
                                let country = subJson["country"].stringValue
                                let confirmedCases = subJson["cases"].intValue
                                let todayCases = subJson["todayCases"].intValue
                                let activeCases = subJson["active"].intValue
                                let deaths = subJson["deaths"].intValue
                                let todayDeaths = subJson["todayDeaths"].intValue
                                let recovered = subJson["recovered"].intValue
                                let inCriticalCondition = subJson["critical"].intValue
                                //print("Country: \(country)\nConfirmed cases: \(confirmedCases)\nDeaths: \(deaths)\nRecovered: \(recovered)")
                                
                                let statModel = StatModel(country: country, cases: confirmedCases, todayCases: todayCases, activeCases: activeCases, deaths: deaths, todayDeaths: todayDeaths, inCriticalCondition: inCriticalCondition, recovered: recovered)
                                    statistics.append(statModel)
                                
                            }
                           
                            statistics = statistics.sorted { (model1, model2) -> Bool in
                                return model1.cases > model2.cases
                            }
                            model?(statistics)
                        } catch {
                            print("Error to get user information")
                        }
                    }
                    
                case .failure( _):
                    print("Failure")
                }
        }
    }

}
