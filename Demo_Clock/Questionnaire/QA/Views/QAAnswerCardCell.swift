//
//  QAAnswerCardCell.swift
//  Todo
//
//  Created by edison on 2019/4/25.
//  Copyright © 2019年 EDC. All rights reserved.
//

import UIKit

class QAAnswerCardCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    var isAnswered: Bool = false {
        didSet{
            titleLabel.layer.cornerRadius = frame.width * 0.5
            titleLabel.layer.masksToBounds = true
            if isAnswered {
                //选中
                titleLabel.backgroundColor = Q_A.Color.yellow
            }else
            {
                titleLabel.backgroundColor = Q_A.Color.gray
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.textColor = Q_A.Color.text

    }

}
