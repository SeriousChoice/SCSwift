//
//  SCSwitchTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

public protocol SCSwitchTableCellDelegate : AnyObject {
    func scSwitchTableCellDidChangeSelection(cell: SCSwitchTableCell)
}

public class SCSwitchTableCell: UITableViewCell {
    
    public var lblTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    public var swSwitch: UISwitch = {
        let uiswitch = UISwitch()
        return uiswitch
    }()
    
    public weak var delegate: SCSwitchTableCellDelegate?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        clipsToBounds = true
        setupLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        let margin = SCFormViewController.cellsMargin
        
        addSubview(lblTitle)
        lblTitle.autoSetDimension(.height, toSize: 20, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: margin)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: margin)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: swSwitch, withOffset: -20)
        
        swSwitch.setOn(false, animated: false)
        swSwitch.addTarget(self, action: #selector(switchDidChangeValue(sender:)), for: .valueChanged)
        addSubview(swSwitch)
        swSwitch.autoSetDimension(.width, toSize: 49, relation: .equal)
        swSwitch.autoSetDimension(.height, toSize: 31, relation: .equal)
        swSwitch.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        swSwitch.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public override func configure(with row: SCFormRow) {
        
        if let title = row.title {
            let text = row.mandatory ? "\(title) *" : title
            if let attributed = NSMutableAttributedString(html: text) {
                attributed.addAttributes([
                    .font: lblTitle.font ?? UIFont.systemFont(ofSize: 17),
                    .foregroundColor: lblTitle.textColor ?? UIColor.black
                ], range: NSRange(location: 0, length: attributed.length))
                lblTitle.attributedText = attributed
            } else {
                lblTitle.text = ""
            }
        } else {
            lblTitle.text = ""
        }
        swSwitch.isOn = (row.value as? Bool) ?? false
    }
    
    @objc func switchDidChangeValue(sender: UISwitch) {
        delegate?.scSwitchTableCellDidChangeSelection(cell: self)
    }
}
