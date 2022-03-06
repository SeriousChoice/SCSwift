//
//  SCTextFieldTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

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
        
        contentView.addSubview(lblTitle)
        lblTitle.sc_pinEdge(toSuperViewEdge: .top, withOffset: margin)
        lblTitle.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 20)
        lblTitle.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: -margin)
        lblTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        txfValue.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        contentView.addSubview(txfValue)
        txfValue.sc_pinEdge(toSuperViewEdge: .top, withOffset: 8, withRelation: .greaterOrEqual)
        txfValue.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: 20)
        txfValue.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: -8, withRelation: .greaterOrEqual)
        txfValue.sc_pinEdge(.leading, toEdge: .trailing, ofView: lblTitle, withOffset: 20)
        txfValue.sc_alignAxisToSuperview(axis: .vertical)
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
