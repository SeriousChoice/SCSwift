//
//  SCTextFieldTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

public protocol SCTextFieldTableCellDelegate : AnyObject {
    func scTextFieldTableCellDidChangeText(cell: SCTextFieldTableCell)
}

public class SCTextFieldTableCell: UITableViewCell {
    
    public var lblTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    public var txfValue: UITextField = {
        let field = UITextField()
        field.textAlignment = .right
        return field
    }()
    
    public weak var delegate: SCTextFieldTableCellDelegate?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        clipsToBounds = true
        setupLayout()
    }
    
    private func setupLayout() {
        let margin = SCFormViewController.cellsMargin
        
        addSubview(lblTitle)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: margin)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: margin)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: txfValue, withOffset: -20)
        lblTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        txfValue.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        addSubview(txfValue)
        txfValue.autoPinEdge(toSuperviewEdge: .top, withInset: 8, relation: .greaterThanOrEqual)
        txfValue.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        txfValue.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8, relation: .greaterThanOrEqual)
        txfValue.autoAlignAxis(toSuperviewAxis: .horizontal)
        txfValue.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func configure(with row: SCFormRow) {
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        txfValue.text = row.value as? String
        txfValue.placeholder = row.placeholder
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        delegate?.scTextFieldTableCellDidChangeText(cell: self)
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
