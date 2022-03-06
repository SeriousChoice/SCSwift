//
//  SCAttachmentTableCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

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
        
        contentView.addSubview(lblTitle)
        lblTitle.sc_pinEdge(toSuperViewEdge: .top, withOffset: margin)
        lblTitle.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 20)
        lblTitle.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: -margin)
        lblTitle.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        lblTitle.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        contentView.addSubview(imgAttachment)
        imgAttachment.sc_setDimension(.width, withValue: 30)
        imgAttachment.sc_setDimension(.height, withValue: 30)
        imgAttachment.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: -40)
        imgAttachment.sc_alignAxis(axis: .vertical, toView: lblTitle)

        contentView.addSubview(lblFileName)
        lblFileName.sc_pinEdge(toSuperViewEdge: .top, withOffset: margin)
        lblFileName.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: -40)
        lblFileName.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: -margin)
        lblFileName.setContentHuggingPriority(.defaultLow, for: .horizontal)
        lblFileName.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        lblTitle.sc_pinEdge(.trailing, toEdge: .leading, ofView: imgAttachment, withOffset: 20, withRelation: .greaterOrEqual)
        lblTitle.sc_pinEdge(.trailing, toEdge: .leading, ofView: lblFileName, withOffset: -20, withRelation: .greaterOrEqual)
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
