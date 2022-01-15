//
//  SCBaseTableCell.swift
//  Pods
//
//  Created by Nicola Innocenti on 08/01/2022.
//

import UIKit

@objc public class SCBaseTableCell : UITableViewCell {
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xeeeeee)
        selectedBackgroundView = view
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let view = UIView()
        view.backgroundColor = UIColor(netHex: 0xeeeeee)
        selectedBackgroundView = view
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: SCBaseTableCell.identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
