//
//  SCDateTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

public protocol SCDateTableCellDelegate : AnyObject {
    func scDateTableCellDidChangeDate(cell: SCDateTableCell)
}

public class SCDateTableCell: UITableViewCell, UITextFieldDelegate {
    
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
    public var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.backgroundColor = .red
        return picker
    }()
    
    public weak var delegate: SCDateTableCellDelegate?
    private var dateFormatter = DateFormatter()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    private func setupLayout() {
        selectionStyle = .none
        clipsToBounds = true
        
        contentView.addSubview(lblTitle)
        let margin = SCFormViewController.cellsMargin
        
        lblTitle.sc_pinEdge(toSuperViewEdge: .top, withOffset: margin)
        lblTitle.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 20)
        lblTitle.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: -margin)
        lblTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        if #available(iOS 14, *) {
            datePicker.addTarget(self, action: #selector(datePickerDidChangeValue(picker:)), for: .valueChanged)
            contentView.addSubview(datePicker)
            datePicker.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: -20)
            datePicker.sc_pinEdge(.leading, toEdge: .trailing, ofView: lblTitle, withOffset: 20, withRelation: .greaterOrEqual)
            datePicker.sc_alignAxis(axis: .vertical, toView: lblTitle)
            datePicker.setContentHuggingPriority(.defaultLow, for: .horizontal)
        } else {
            txfValue.delegate = self
            contentView.addSubview(txfValue)
            lblTitle.sc_pinEdge(.trailing, toEdge: .leading, ofView: txfValue, withOffset: 20)
            
            txfValue.inputView = datePicker
            txfValue.sc_pinEdge(toSuperViewEdge: .top, withOffset: 8, withRelation: .greaterOrEqual)
            txfValue.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: 20)
            txfValue.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: -8, withRelation: .greaterOrEqual)
            txfValue.sc_alignAxisToSuperview(axis: .vertical)
            txfValue.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @objc func datePickerDidChangeValue(picker: UIDatePicker) {
        setDate(date: picker.date)
        delegate?.scDateTableCellDidChangeDate(cell: self)
    }
    
    public override func configure(with row: SCFormRow) {
        
        dateFormatter = DateFormatter()
        if !row.dateFormat.isEmpty {
            dateFormatter.dateFormat = row.dateFormat
            let format = row.dateFormat.lowercased()
            datePicker.datePickerMode = format.contains("hh") && row.dateFormat.contains("y") ? .dateAndTime : format.contains("hh") && !row.dateFormat.contains("y") ? .time : .date
        } else {
            dateFormatter.dateStyle = .medium
            datePicker.datePickerMode = .date
        }
        
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        if #available(iOS 14, *) {
            
        } else {
            txfValue.placeholder = row.placeholder
        }
        setDate(date: row.value as? Date)
    }
    
    private func setDate(date: Date?) {
        
        if #available(iOS 14, *) {
            
        } else {
            if let date = date {
                txfValue.text = dateFormatter.string(from: date)
            } else {
                txfValue.text = ""
            }
        }
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - UITextField Delegate
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        setDate(date: datePicker.date)
        delegate?.scDateTableCellDidChangeDate(cell: self)
    }
}
