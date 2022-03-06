//
//  SCTextViewTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

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
        textView.isEditable = true
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
        contentView.addSubview(lblTitle)
        lblTitle.sc_pinEdge(toSuperViewEdge: .top, withOffset: 12)
        lblTitle.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 20)
        lblTitle.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: -20)
        
        txwValue.delegate = self
        contentView.addSubview(txwValue)
        txwValue.sc_setDimension(.height, withValue: 120)
        txwValue.sc_pinEdge(.top, toEdge: .bottom, ofView: lblTitle, withOffset: 8)
        txwValue.sc_pinEdge(.leading, toEdge: .leading, ofView: lblTitle)
        txwValue.sc_pinEdge(.trailing, toEdge: .trailing, ofView: lblTitle)
        txwValue.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: -12)
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
