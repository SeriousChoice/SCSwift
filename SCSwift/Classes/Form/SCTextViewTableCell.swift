//
//  SCTextViewTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

public protocol SCTextViewTableCellDelegate : AnyObject {
    func scTextViewTableCellDidChangeText(cell: SCTextViewTableCell)
}

public class SCTextViewTableCell: UITableViewCell, UITextViewDelegate {
    
    public var lblTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    public var txwValue: UITextView = {
        let textView = UITextView()
        textView.textContainerInset.left = -6
        return textView
    }()
    
    public weak var delegate: SCTextViewTableCellDelegate?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        clipsToBounds = true
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(lblTitle)
        lblTitle.autoSetDimension(.height, toSize: 20, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: 12)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)
        
        txwValue.delegate = self
        addSubview(txwValue)
        txwValue.autoSetDimension(.height, toSize: 120, relation: .equal)
        txwValue.autoPinEdge(.top, to: .bottom, of: lblTitle, withOffset: 8)
        txwValue.autoPinEdge(.leading, to: .leading, of: lblTitle)
        txwValue.autoPinEdge(.trailing, to: .trailing, of: lblTitle)
        txwValue.autoPinEdge(toSuperviewEdge: .bottom, withInset: 12)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        txwValue.text = row.value as? String
    }
    
    // MARK: - UITextView Delegate
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.scTextViewTableCellDidChangeText(cell: self)
    }
}
