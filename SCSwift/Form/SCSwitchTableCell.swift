//
//  SCSwitchTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

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
        
        contentView.addSubview(lblTitle)
        lblTitle.sc_pinEdge(toSuperViewEdge: .top, withOffset: margin)
        lblTitle.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 20)
        lblTitle.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: -margin)
        
        swSwitch.setOn(false, animated: false)
        swSwitch.addTarget(self, action: #selector(switchDidChangeValue(sender:)), for: .valueChanged)
        contentView.addSubview(swSwitch)
        swSwitch.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: -20)
        swSwitch.sc_pinEdge(.leading, toEdge: .trailing, ofView: lblTitle, withOffset: 20, withRelation: .greaterOrEqual)
        swSwitch.sc_alignAxis(axis: .vertical, toView: lblTitle)
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
