//
//  CovidStatTableViewCell.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 27.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit

class CovidStatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var casesAmmount: UILabel!
    @IBOutlet weak var deathsAmmount: UILabel!
    @IBOutlet weak var recoveredAmmount: UILabel!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "covidStatTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UITableViewCell
        
    }
    
}
