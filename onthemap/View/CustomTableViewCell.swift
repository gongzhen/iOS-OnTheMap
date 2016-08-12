//
//  CustomTableViewCell.swift
//  onthemap
//
//  Created by gongzhen on 3/23/16.
//  Copyright © 2016 gongzhen. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!    
    @IBOutlet weak var mediaURLLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
