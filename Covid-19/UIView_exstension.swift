//
//  UIView_exstension.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 28.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit

extension UIView {
    
    func shakeAnim ()
    {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = Double.pi * 0.11
        rotation.duration = 0.1 // or however long you want ...
        rotation.isCumulative = true
        rotation.autoreverses = true
        rotation.repeatCount = 6
        self.layer.add(rotation, forKey: "rotationAnimation")
        
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 6
        shake.autoreverses = true
        
        let from_point:CGPoint = CGPoint(x:self.center.x - 2.7,y: self.center.y)
        let from_value:NSValue = NSValue(cgPoint: from_point)
        
        let to_point:CGPoint = CGPoint(x:self.center.x + 2.7,y: self.center.y)
        let to_value:NSValue = NSValue(cgPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        self.layer.add(shake, forKey: "position")
    }
}
