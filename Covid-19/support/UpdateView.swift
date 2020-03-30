//
//  UpdateView.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 30.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit

protocol virusButtonDeleGate {
    func pressed()
}

class UpdateView: UIView {
    
    var delegate: virusButtonDeleGate?
    
    @IBAction func virusButtonPressed(_ sender: UIButton) {
        print("Go to main app")
        delegate?.pressed()
    }
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "updateView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        
    }
    
}
