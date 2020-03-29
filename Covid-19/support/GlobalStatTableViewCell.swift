//
//  GlobalStatTableViewCell.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 29.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit

class GlobalStatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var casesTitleLabel: UILabel!
    @IBOutlet weak var casesAmmountLabel: UILabel!
    @IBOutlet weak var deathsTitleLabel: UILabel!
    @IBOutlet weak var deathsAmmountLabel: UILabel!
    @IBOutlet weak var recoveredTitleLabel: UILabel!
    @IBOutlet weak var recoveredAmmountLabel: UILabel!
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "globalStatTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UITableViewCell
        
    }
}
