//
//  SCCollections.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import Foundation

public class SCTableSection : NSObject {
    
    public var key: String = ""
    public var title: String?
    public var rows = [SCTableRow]()
    
    public convenience init(key: String, title: String?, rows: [SCTableRow]) {
        self.init()
        
        self.key = key
        self.title = title
        self.rows = rows
    }
}

public class SCTableRow : NSObject {
    
    public var key: String = ""
    public var title: String?
    public var subtitle: String?
    public var value: String?
    public var image: UIImage?
    public var accessoryType: UITableViewCell.AccessoryType = .none
    
    public convenience init(key: String, title: String?, subtitle: String?, value: String) {
        self.init()
        
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.value = value
    }
    
    public convenience init(key: String, title: String?, value: String?, image: UIImage?, accessoryType: UITableViewCell.AccessoryType) {
        self.init()
        
        self.key = key
        self.title = title
        self.value = value
        self.image = image
        self.accessoryType = accessoryType
    }
    
    public convenience init(key: String, title: String?, value: String?, accessoryType: UITableViewCell.AccessoryType) {
        self.init()
        
        self.key = key
        self.title = title
        self.value = value
        self.accessoryType = accessoryType
    }
}
