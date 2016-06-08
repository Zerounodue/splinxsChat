//
//  UserCell.swift
//  splinxsChat
//
//  Created by Elia Kocher on 17.05.16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit

class UserCell: BaseCell {
    @IBOutlet weak var nicknameLable: UILabel!
    @IBOutlet weak var statusLable: UILabel!
    @IBOutlet weak var onlineStatusImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code 
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
