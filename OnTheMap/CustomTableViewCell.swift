//
//  CustomTableViewCell.swift
//  OnTheMap
//
//  Created by Alexander on 5/27/17.
//  Copyright © 2017 Dictality. All rights reserved.
//

import Foundation
import UIKit

class CustomTableViewCell : UITableViewCell {
    
    @IBOutlet weak var pinMainLabel: UILabel!
    @IBOutlet weak var pinSublabel: UILabel!
    @IBOutlet weak var pinDateCreatedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        
        // configure the view for the selected state
    }
    
    func setupViews() {
        backgroundColor = UIColor.purple
        
    }
}
