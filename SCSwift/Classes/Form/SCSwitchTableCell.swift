//
//  SCSwitchTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

public protocol SCSwitchTableCellDelegate : class {
    func SCSwitchTableCellDidChangeSelection(cell: SCSwitchTableCell)
}

public class SCSwitchTableCell: UITableViewCell {
    
    public var lblTitle: UILabel!
    public var swSwitch: UISwitch!
    
    public weak var delegate: SCSwitchTableCellDelegate?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        clipsToBounds = true
        setupInterface()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInterface() {
        
        lblTitle = UILabel()
        lblTitle.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lblTitle.numberOfLines = 0
        addSubview(lblTitle)
        
        swSwitch = UISwitch()
        swSwitch.setOn(false, animated: false)
        swSwitch.addTarget(self, action: #selector(switchDidChangeValue(sender:)), for: .valueChanged)
        addSubview(swSwitch)
        
        lblTitle.autoSetDimension(.height, toSize: 28, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        lblTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: swSwitch, withOffset: -16)
        
        swSwitch.autoSetDimension(.height, toSize: 28, relation: .greaterThanOrEqual)
        swSwitch.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        swSwitch.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        swSwitch.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    public override func configure(with row: SCFormRow) {
        
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        swSwitch.isOn = (row.value as? Bool) ?? false
    }
    
    @objc func switchDidChangeValue(sender: UISwitch) {
        delegate?.SCSwitchTableCellDidChangeSelection(cell: self)
    }
}
