//
//  AdvicesViewController.swift
//  Covid-19
//
//  Created by Ilia Zhegunov on 28.03.2020.
//  Copyright © 2020 Ilia Zhegunov. All rights reserved.
//

import UIKit

class AdvicesViewController: UIViewController {
    @IBOutlet weak var advicesCollectionView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: "shaker")
        advicesCollectionView.delegate = self
        advicesCollectionView.dataSource = self
    }
}

extension AdvicesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Symptoms", comment: "")
        }
        else if section == 1 {
            return NSLocalizedString("Sequelae", comment: "")
        }
        else if section == 2 {
            return NSLocalizedString("Spread", comment: "")
        }
        else {
            return NSLocalizedString("Advice", comment: "")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = advicesCollectionView.dequeueReusableCell(withIdentifier: "adviceCell", for: indexPath as IndexPath) as! AdviceCell
        switch indexPath.section {
        case 0:
            cell.adviceImage.image = UIImage(imageLiteralResourceName: NSLocalizedString("SymptomsPic", comment: ""))
        case 1:
            cell.adviceImage.image = UIImage(imageLiteralResourceName: NSLocalizedString("SequelaePic", comment: ""))
        case 2:
            cell.adviceImage.image = UIImage(imageLiteralResourceName: NSLocalizedString("SpreadPic", comment: ""))
        case 3:
            cell.adviceImage.image = UIImage(imageLiteralResourceName: NSLocalizedString("AdvicePic", comment: ""))
        default:
            print("lol")
        }
      //  cell.adviceImage.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        cell.adviceImage.contentMode = UIView.ContentMode.scaleAspectFit
        return cell
    }
    
    
}

class AdviceCell: UITableViewCell {
    @IBOutlet weak var adviceImage: UIImageView!
    
}
