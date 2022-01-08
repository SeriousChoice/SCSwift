//
//  SCTableSection.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import Foundation

public struct SCTableSection {
    public var key: String
    public var title: String?
    public var rows: [SCTableRow]
}

public struct SCTableRow {
    public var key: String
    public var title: String?
    public var subtitle: String?
    public var value: String?
    public var image: UIImage?
    public var accessoryType: UITableViewCell.AccessoryType
    
    public init(key: String, title: String?, subtitle: String?, value: String) {
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.accessoryType = .none
    }
    
    public init(key: String, title: String?, value: String?, image: UIImage?, accessoryType: UITableViewCell.AccessoryType) {
        self.key = key
        self.title = title
        self.value = value
        self.image = image
        self.accessoryType = accessoryType
    }
    
    public init(key: String, title: String?, value: String?, accessoryType: UITableViewCell.AccessoryType) {
        self.key = key
        self.title = title
        self.value = value
        self.accessoryType = accessoryType
    }
}
