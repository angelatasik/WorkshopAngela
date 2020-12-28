//
//  MajstoriDetailsTableViewCell.swift
//  WorkshopAngela
//
//  Created by Angela Tasikj on 12/22/20.
//  Copyright © 2020 Angela Tasikj. All rights reserved.
//

import UIKit

class MajstoriDetailsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var Slika: UIImageView!
    @IBOutlet weak var Datum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
