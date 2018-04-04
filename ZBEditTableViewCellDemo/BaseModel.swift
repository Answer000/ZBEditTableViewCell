//
//  BaseModel.swift
//  ZBEditTableViewCellDemo
//
//  Created by 澳蜗科技 on 2018/4/4.
//  Copyright © 2018年 Coder_Answer. All rights reserved.
//

import UIKit

class BaseModel: NSObject {
    
    var iconName : String?
    
    var title : String?
    
    var message : String?
    
    convenience init(json: [String : Any]?) {
        self.init()
        guard let json = json else {
            return
        }
        self.title = json["title"] as? String
        self.iconName = json["iconName"] as? String
        self.message = json["message"] as? String
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
}
