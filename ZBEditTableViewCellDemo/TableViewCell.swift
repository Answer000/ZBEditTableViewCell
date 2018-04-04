//
//  TableViewCell.swift
//  ZBEditTableViewCellDemo
//
//  Created by 澳蜗科技 on 2018/4/4.
//  Copyright © 2018年 Coder_Answer. All rights reserved.
//

import UIKit

class TableViewCell: ZBEditTableViewCell {
    
    private lazy var imgView : UIImageView = {
        let view = UIImageView.init()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        self.contentView.addSubview(view)
        return view
    }()
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.darkText
        self.contentView.addSubview(label)
        return label
    }()
    
    private lazy var messageLabel : UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.lightGray
        self.contentView.addSubview(label)
        return label
    }()
    
    public func fillCellWithModel(model: BaseModel?) {
        guard let model = model else {
            return
        }
        self.imgView.image = UIImage.init(named: (model.iconName ?? ""))
        self.titleLabel.text = model.title
        self.messageLabel.text = model.message
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imgView.frame.origin = CGPoint.init(x: 12, y: 12)
        self.imgView.frame.size = CGSize.init(width: self.contentView.bounds.height - 24, height: self.contentView.bounds.height - 24)
        
        self.titleLabel.frame.origin = CGPoint.init(x: self.imgView.frame.origin.x + self.imgView.frame.width + 12, y: self.contentView.center.y - 16 - 8)
        self.titleLabel.frame.size = CGSize.init(width: self.contentView.bounds.width - self.titleLabel.frame.origin.x - 15, height: 16)
        self.messageLabel.frame.origin = CGPoint.init(x: self.titleLabel.frame.origin.x, y: self.contentView.center.y + 8)
        self.messageLabel.frame.size = CGSize.init(width: self.titleLabel.bounds.width, height: 14)
    }
}
