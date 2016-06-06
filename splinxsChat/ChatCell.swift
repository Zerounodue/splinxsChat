//
//  ChatCell.swift
//  splinxsChat
//
//  Created by Elia Kocher on 17.05.16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit

class ChatCell: BaseCell {

    @IBOutlet weak var nicknameLable: UILabel!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var timeLable: UILabel!

    @IBOutlet weak var bubble: UIView!
    
    //@IBOutlet weak var widthConstraint: NSLayoutConstraint!
    //@IBOutlet weak var rightConstraint: NSLayoutConstraint!
    //@IBOutlet weak var leftConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
