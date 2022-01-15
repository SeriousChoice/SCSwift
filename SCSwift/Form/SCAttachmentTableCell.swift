//
//  SCAttachmentTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

class SCAttachmentTableCell: UITableViewCell {
    
    public var lblTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    public var imgAttachment: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 3
        image.clipsToBounds = true
        return image
    }()
    public var lblFileName: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        clipsToBounds = true
        accessoryType = .disclosureIndicator
        setupLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupLayout() {
        let margin = SCFormViewController.cellsMargin
        
        addSubview(lblTitle)
        lblTitle.autoPinEdge(toSuperviewEdge: .top, withInset: margin)
        lblTitle.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        lblTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: margin)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: imgAttachment, withOffset: -20, relation: .greaterThanOrEqual)
        lblTitle.autoPinEdge(.trailing, to: .leading, of: lblFileName, withOffset: -20, relation: .greaterThanOrEqual)
        lblTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lblTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        addSubview(imgAttachment)
        imgAttachment.autoSetDimension(.width, toSize: 30, relation: .equal)
        imgAttachment.autoSetDimension(.height, toSize: 30, relation: .equal)
        imgAttachment.autoPinEdge(toSuperviewEdge: .trailing, withInset: 40)
        imgAttachment.autoAlignAxis(toSuperviewAxis: .horizontal)

        addSubview(lblFileName)
        lblFileName.autoPinEdge(toSuperviewEdge: .top, withInset: margin)
        lblFileName.autoPinEdge(toSuperviewEdge: .trailing, withInset: 40)
        lblFileName.autoPinEdge(toSuperviewEdge: .bottom, withInset: margin)
        lblFileName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lblFileName.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    public override func configure(with row: SCFormRow) {
        
        lblTitle.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        if let url = row.attachmentUrl {
            if let image = UIImage(contentsOfFile: url.absoluteString.replacingOccurrences(of: "file://", with: "")) {
                imgAttachment.image = image
                lblFileName.text = nil
            } else {
                imgAttachment.image = nil
                lblFileName.text = url.lastPathComponent
            }
        } else {
            imgAttachment.image = nil
            lblFileName.text = nil
        }
    }
}
