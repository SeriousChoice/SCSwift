//
//  SCChatMessageCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

public protocol SCChatMessageCellDelegate : AnyObject {
    func scChatMessageCellDidSelectUrl(cell: SCChatMessageCell, url: URL)
    func scChatMessageCellDidSelectImage(cell: SCChatMessageCell, image: UIImage?)
    func scChatMessageCellDidSelectVideo(cell: SCChatMessageCell)
}

public enum SCChatMessageCellStyle {
    case text
    case audio
    case video
    case image
}

open class SCChatMessageCell: UITableViewCell {
    
    // MARK: - Layout
    
    open var bubbleContainerView: UIView!
    open var bubbleView: UIImageView?
    open var lblSenderName: UILabel?
    open var lblMessage: UILabel?
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
    open var senderPosition = ItemPosition.inside
    open var messageDatePosition = ItemPosition.inside
    
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
        
        contentView.addSubview(bubbleContainerView)
        cntBubbleContainerTop = bubbleContainerView.sc_pinEdge(toSuperViewEdge: .top, withOffset: 8)
        cntBubbleContainerLeading = bubbleContainerView.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 40, withRelation: .greaterOrEqual)
        cntBubbleContainerTrailing = bubbleContainerView.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: 8)
        bubbleContainerView.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: 0)
        
        //Creating UIImageView to show bubble images
        
        bubbleView = UIImageView()
        bubbleView?.clipsToBounds = true
        bubbleView?.contentMode = .scaleToFill
        bubbleView?.isUserInteractionEnabled = true
        
        bubbleContainerView.addSubview(bubbleView!)
        bubbleView?.sc_pinEdgesToSuperViewEdges()
    }
    
    open func configure(style: SCChatMessageCellStyle) {
        
        self.style = style
        
        //Changing trailing and leading constraints to keep lateral spacing depending on current sender
        
        NSLayoutConstraint.deactivate([cntBubbleContainerLeading, cntBubbleContainerTrailing])
        if isSender {
            cntBubbleContainerLeading = bubbleContainerView.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 40, withRelation: .greaterOrEqual)
            cntBubbleContainerTrailing = bubbleContainerView.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: 8)
        } else {
            cntBubbleContainerLeading = bubbleContainerView.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 8)
            cntBubbleContainerTrailing = bubbleContainerView.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: 40, withRelation: .greaterOrEqual)
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
        let endSpace = "  aaaa"
        realText += endSpace
        
        let attributedString = NSMutableAttributedString(string: realText)
        attributedString.addAttribute(
            kCTForegroundColorAttributeName as NSAttributedString.Key,
            value: UIColor.clear,
            range: NSRange(location: attributedString.length-endSpace.count, length: endSpace.count)
        )
        lblMessage?.attributedText = attributedString
    }
    
    private func createMessageLabel() {
        
        //Removing media layout components
        
        removeUnusedViews()
        
        if lblMessage == nil {
            
            //Creating message UILabel with link support
            
            lblMessage = UILabel(frame: .zero)
            lblMessage?.numberOfLines = 0
            lblMessage?.textColor = .white
            bubbleView?.addSubview(lblMessage!)
            
            lblMessage?.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: 8)
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
            imgImage?.sc_pinEdgesToSuperViewEdges(withInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
            imgImage?.layer.cornerRadius = 12
            imgImage?.sc_setDimension(.width, withValue: 280)
            
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
            videoLayer?.sc_pinEdgesToSuperViewEdges()
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapVideo))
            tap.numberOfTapsRequired = 1
            videoLayer?.addGestureRecognizer(tap)
        }
        
        if playIcon == nil {
            playIcon = UIImageView()
            playIcon?.contentMode = .center
            imgImage?.addSubview(playIcon!)
            playIcon?.sc_pinEdgesToSuperViewEdges()
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
                lblSenderName!.sc_pinEdgesToSuperViewEdges(withInsets: UIEdgeInsets(top: lateralPadding, left: lateralPadding, bottom: lateralPadding, right: lateralPadding), exceptEdge: .bottom)
                
            } else {
                
                lblSenderName?.textColor = .gray
                contentView.addSubview(lblSenderName!)
                lblSenderName?.sc_pinEdgesToSuperViewEdges(withInsets: UIEdgeInsets(top: lateralPadding, left: lateralPadding, bottom: lateralPadding, right: lateralPadding), exceptEdge: .bottom)
                NSLayoutConstraint.deactivate([cntBubbleContainerTop])
                cntBubbleContainerTop = bubbleContainerView.sc_pinEdge(.top, toEdge: .bottom, ofView: lblSenderName!, withOffset: 8)
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
                contentView.addSubview(lblMessageDate!)
                lblMessage?.sc_pinEdge(.top, toEdge: .bottom, ofView: bubbleContainerView, withOffset: 8)
            }
            lblMessageDate?.sc_pinEdgesToSuperViewEdges(withInsets: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12), exceptEdge: .top)
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
        
        if senderPosition == .inside && lblSenderName != nil {
            lblMessage?.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 8)
            lblMessage?.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: 8)
            lblMessage?.sc_pinEdge(.top, toEdge: .bottom, ofView: lblSenderName!, withOffset: 8)
        } else {
            lblMessage?.sc_pinEdgesToSuperViewEdges(withInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        }
    }
    
    @objc func didTapImage() {
        delegate?.scChatMessageCellDidSelectImage(cell: self, image: imgImage?.image)
    }
    
    @objc func didTapVideo() {
        delegate?.scChatMessageCellDidSelectVideo(cell: self)
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
