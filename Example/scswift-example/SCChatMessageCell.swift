//
//  SCChatMessageCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import SCSwift
import PureLayout
import TTTAttributedLabel

public protocol SCChatMessageCellDelegate : class {
    func SCChatMessageCellDidSelectUrl(cell: SCChatMessageCell, url: URL)
    func SCChatMessageCellDidSelectImage(cell: SCChatMessageCell, image: UIImage?)
    func SCChatMessageCellDidSelectVideo(cell: SCChatMessageCell)
}

public enum SCChatMessageCellStyle {
    case text
    case audio
    case video
    case image
}

open class SCChatMessageCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    // MARK: - Layout
    
    open var bubbleContainerView: UIView!
    open var bubbleView: UIImageView?
    open var lblSenderName: UILabel?
    open var lblMessage: TTTAttributedLabel?
    open var imgImage: UIImageView?
    open var lblMessageDate: UILabel!
    private var videoLayer: UIView?
    open var playIcon: UIImageView?
    
    // MARK: - Constraints
    
    private var cntBubbleContainerTop: NSLayoutConstraint!
    private var cntBubbleContainerLeading: NSLayoutConstraint!
    private var cntBubbleContainerTrailing: NSLayoutConstraint!
    
    // MARK: - Constants & Variables
    
    open weak var delegate: SCChatMessageCellDelegate?
    open var style = SCChatMessageCellStyle.text
    open var isSender = true
    open var isSenderNameActive = false
    var senderPosition = ItemPosition.inside
    var messageDatePosition = ItemPosition.inside
    
    // MARK: - Initialization
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Cell Methods
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: - Configuration Methods
    
    private func setupUI() {
        
        autoresizingMask = [.flexibleHeight]
        
        selectionStyle = .none
        
        //Creating container for all layout components
        
        bubbleContainerView = UIView()
        bubbleContainerView.isUserInteractionEnabled = true
        
        addSubview(bubbleContainerView)
        cntBubbleContainerTop = bubbleContainerView.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
        cntBubbleContainerLeading = bubbleContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 40, relation: .greaterThanOrEqual)
        cntBubbleContainerTrailing = bubbleContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        bubbleContainerView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 0)
        
        //Creating UIImageView to show bubble images
        
        bubbleView = UIImageView()
        bubbleView?.clipsToBounds = true
        bubbleView?.contentMode = .scaleToFill
        bubbleView?.isUserInteractionEnabled = true
        
        bubbleContainerView.addSubview(bubbleView!)
        bubbleView?.autoPinEdgesToSuperviewEdges()
    }
    
    open func configure(style: SCChatMessageCellStyle) {
        
        self.style = style
        
        //Changing trailing and leading constraints to keep lateral spacing depending on current sender
        
        NSLayoutConstraint.deactivate([cntBubbleContainerLeading, cntBubbleContainerTrailing])
        if isSender {
            cntBubbleContainerLeading = bubbleContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 40, relation: .greaterThanOrEqual)
            cntBubbleContainerTrailing = bubbleContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
        } else {
            cntBubbleContainerLeading = bubbleContainerView.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
            cntBubbleContainerTrailing = bubbleContainerView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 40, relation: .greaterThanOrEqual)
        }
        NSLayoutConstraint.activate([cntBubbleContainerLeading, cntBubbleContainerTrailing])
        
        if style == .text {
            createMessageLabel()
        } else if style == .image {
            createImage()
        } else if style == .video {
            createVideo()
        }
        
        if isSenderNameActive {
            createSenderName()
        }
        
        createMessageDate()
        applyConstraints()
    }
    
    open func setBubbleTopSpacing(value: CGFloat) {
        cntBubbleContainerTop.constant = value
    }
    
    open func setText(text: String?) {
        
        var realText = text ?? ""
        let endSpace = " aaaa"
        realText += endSpace
        
        lblMessage?.setText(realText) { (attributedString) -> NSMutableAttributedString? in
            attributedString?.addAttribute(
                kCTForegroundColorAttributeName as NSAttributedString.Key,
                value: UIColor.clear,
                range: NSRange(location: attributedString!.length-endSpace.count, length: endSpace.count)
            )
            return attributedString
        }
    }
    
    private func createMessageLabel() {
        
        //Removing media layout components
        
        removeUnusedViews()
        
        if lblMessage == nil {
            
            //Creating message UILabel with link support
            
            lblMessage = TTTAttributedLabel(frame: .zero)
            lblMessage?.enabledTextCheckingTypes = NSTextCheckingAllTypes
            lblMessage?.delegate = self
            lblMessage?.activeLinkAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.white.darker,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            lblMessage?.linkAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            lblMessage?.inactiveLinkAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            lblMessage?.numberOfLines = 0
            lblMessage?.textColor = .white
            bubbleView?.addSubview(lblMessage!)
            
            lblMessage?.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
        }
    }
    
    private func createImage() {
        
        //Removing not needed components
        
        removeUnusedViews()
        
        if imgImage == nil {
            
            //Creating UIImageView containing message image
            
            imgImage = UIImageView()
            imgImage?.clipsToBounds = true
            imgImage?.contentMode = .scaleAspectFill
            imgImage?.isUserInteractionEnabled = true
            bubbleView?.insertSubview(imgImage!, at: 0)
            imgImage?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
            imgImage?.layer.cornerRadius = 12
            imgImage?.autoSetDimension(.width, toSize: 280)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
            tap.numberOfTapsRequired = 1
            imgImage?.addGestureRecognizer(tap)
        }
    }
    
    private func createVideo() {
        
        createImage()
        imgImage?.removeSubviews()
        
        if videoLayer == nil {
            videoLayer = UIView()
            videoLayer?.clipsToBounds = true
            videoLayer?.backgroundColor = .black
            videoLayer?.alpha = 0.4
            videoLayer?.isUserInteractionEnabled = true
            imgImage?.addSubview(videoLayer!)
            videoLayer?.autoPinEdgesToSuperviewEdges()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapVideo))
            tap.numberOfTapsRequired = 1
            videoLayer?.addGestureRecognizer(tap)
        }
        
        if playIcon == nil {
            playIcon = UIImageView()
            playIcon?.contentMode = .center
            imgImage?.addSubview(playIcon!)
            playIcon?.autoPinEdgesToSuperviewEdges()
        }
    }
    
    private func createSenderName() {
        
        if lblSenderName == nil {
            
            //Creating UILabel showing message sender
            
            lblSenderName = UILabel()
            lblSenderName?.textColor = .white
            
            //Can be shown inside the bubble or outside
            
            let lateralPadding: CGFloat = style == .text ? 8 : 14
            
            if senderPosition == .inside {
                
                lblSenderName?.textColor = .white
                bubbleView?.addSubview(lblSenderName!)
                lblSenderName!.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: lateralPadding, left: lateralPadding, bottom: lateralPadding, right: lateralPadding), excludingEdge: .bottom)
                
            } else {
                
                lblSenderName?.textColor = .gray
                addSubview(lblSenderName!)
                lblSenderName?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: lateralPadding, left: lateralPadding, bottom: lateralPadding, right: lateralPadding), excludingEdge: .bottom)
                NSLayoutConstraint.deactivate([cntBubbleContainerTop])
                cntBubbleContainerTop = bubbleContainerView.autoPinEdge(.top, to: .bottom, of: lblSenderName!, withOffset: 8)
                NSLayoutConstraint.activate([cntBubbleContainerTop])
            }
        }
        
        if senderPosition == .inside {
            
            if style == .text {
                
                //Sender name without shadow for text messages
                
                lblSenderName?.layer.shadowColor = UIColor.clear.cgColor
                lblSenderName?.layer.shadowOffset = .zero
                lblSenderName?.layer.shadowRadius = 0
                lblSenderName?.layer.shadowOpacity = 0
                lblSenderName?.layer.masksToBounds = true
                
            } else {
                
                //Sender name with shadow for media messages because they can have background with same color
                
                lblSenderName?.layer.shadowColor = UIColor.black.cgColor
                lblSenderName?.layer.shadowOffset = .zero
                lblSenderName?.layer.shadowRadius = 2
                lblSenderName?.layer.shadowOpacity = 1
                lblSenderName?.layer.masksToBounds = false
            }
        }
    }
    
    private func createMessageDate() {
        
        if lblMessageDate == nil {
            
            lblMessageDate = UILabel()
            
            if messageDatePosition == .inside {
                bubbleView?.insertSubview(lblMessageDate!, at: 1)
            } else {
                addSubview(lblMessageDate!)
                lblMessageDate.autoPinEdge(.top, to: .bottom, of: bubbleContainerView, withOffset: 8)
            }
            lblMessageDate?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), excludingEdge: .top)
        }
        
        if style == .text || messageDatePosition == .outside {
            
            lblMessageDate.textColor = .white
            
            lblMessageDate?.layer.shadowColor = UIColor.clear.cgColor
            lblMessageDate?.layer.shadowOffset = .zero
            lblMessageDate?.layer.shadowRadius = 0
            lblMessageDate?.layer.shadowOpacity = 0
            lblMessageDate?.layer.masksToBounds = true
            
        } else {
            
            lblMessageDate.textColor = .white
            
            lblMessageDate?.layer.shadowColor = UIColor.black.cgColor
            lblMessageDate?.layer.shadowOffset = .zero
            lblMessageDate?.layer.shadowRadius = 2
            lblMessageDate?.layer.shadowOpacity = 1
            lblMessageDate?.layer.masksToBounds = false
        }
    }
    
    private func applyConstraints() {
        
        if senderPosition == .inside {
            lblMessage?.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
            lblMessage?.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
            lblMessage?.autoPinEdge(.top, to: .bottom, of: lblSenderName!, withOffset: 8)
        } else {
            lblMessage?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
    }
    
    @objc func didTapImage() {
        delegate?.SCChatMessageCellDidSelectImage(cell: self, image: imgImage?.image)
    }
    
    @objc func didTapVideo() {
        delegate?.SCChatMessageCellDidSelectVideo(cell: self)
    }
    
    // MARK: - TTTAttributedLabel Delegate
    
    public func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        delegate?.SCChatMessageCellDidSelectUrl(cell: self, url: url)
    }
    
    // MARK: - Other Methods
    
    private func removeUnusedViews() {
        
        if style == .text {
            videoLayer?.removeConstraints()
            videoLayer?.removeFromSuperview()
            videoLayer = nil
            imgImage?.removeConstraints()
            imgImage?.removeFromSuperview()
            imgImage = nil
            bubbleView?.mask = nil
        } else {
            if style == .image {
                videoLayer?.removeConstraints()
                videoLayer?.removeFromSuperview()
                videoLayer = nil
            }
            lblMessage?.removeConstraints()
            lblMessage?.removeFromSuperview()
            lblMessage = nil
        }
        
        if style != .video {
            playIcon?.removeConstraints()
            playIcon?.removeFromSuperview()
            playIcon = nil
        }
    }
}
