//
//  SCChatViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import SCSwift
import PureLayout

public enum ItemPosition {
    case inside
    case outside
}

open class SCChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SCChatMessageCellDelegate {
    
    // MARK: - Layout
    
    open var tblChat: UITableView!

    // MARK: - Constants & Variables
    
    open var senderPosition = ItemPosition.inside
    
    private let cellIdentifier = "cellIdentifier"
    open var fontMessage = UIFont.systemFont(ofSize: 16, weight: .medium)
    open var fontSenderName = UIFont.systemFont(ofSize: 14, weight: .bold)
    open var fontMessageDate = UIFont.systemFont(ofSize: 12, weight: .regular)
    open var textColorSender: UIColor = .white
    open var textColorReceiver: UIColor = .black
    open var bubbleSender: UIImage?
    open var bubbleReceiver: UIImage?
    open var playButtonImage: UIImage?
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        tblChat = UITableView(frame: view.frame)
        tblChat.dataSource = self
        tblChat.delegate = self
        tblChat.separatorStyle = .none
        tblChat.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        tblChat.register(SCChatMessageCell.self, forCellReuseIdentifier: cellIdentifier)
        
        view.addSubview(tblChat)
        tblChat.autoPinEdgesToSuperviewEdges()
        
        bubbleSender = #imageLiteral(resourceName: "bubble_sender").resizableImage(withCapInsets: UIEdgeInsets(top: 19.5, left: 19.5, bottom: 19.5, right: 19.5), resizingMode: .stretch)
        bubbleReceiver = #imageLiteral(resourceName: "bubble_receiver").resizableImage(withCapInsets: UIEdgeInsets(top: 19.5, left: 19.5, bottom: 19.5, right: 19.5), resizingMode: .stretch)
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SCChatMessageCell
        cell.delegate = self
        cell.isSenderNameActive = true
        cell.senderPosition = .inside
        
        let isSender = indexPath.row % 2 == 0
        cell.isSender = isSender
        cell.bubbleView?.image = isSender ? bubbleSender : bubbleReceiver
        
        if isSender {
            cell.configure(style: .video)
            cell.imgImage?.image = "landscape.jpg".image
            cell.playIcon?.image = playButtonImage
            /*cell.lblMessage?.font = fontMessage
            cell.lblMessage?.textColor = isSender ? textColorSender : textColorReceiver
            cell.lblMessage?.textAlignment = isSender ? .right : .left
            cell.setText(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua" + "\n\nhttps://www.google.it")*/
        } else {
            cell.configure(style: .image)
            cell.imgImage?.image = "landscape.jpg".image
        }

        cell.lblSenderName?.font = fontSenderName
        cell.lblSenderName?.text = isSender ? "Sender" : "Receiver"
        cell.lblSenderName?.textAlignment = isSender ? .right : .left
        
        cell.lblMessageDate.font = fontMessageDate
        cell.lblMessageDate.textAlignment = isSender ? .right : .left
        cell.lblMessageDate.text = "15:30"
        
        return cell
    }
    
    // MARK: - SCChatMessageCell Delegate
    
    public func SCChatMessageCellDidSelectUrl(cell: SCChatMessageCell, url: URL) {
        
        UIApplication.shared.openURL(url)
    }
    
    public func SCChatMessageCellDidSelectImage(cell: SCChatMessageCell, image: UIImage?) {
        
        print("DID TAP IMAGE")
    }
    
    public func SCChatMessageCellDidSelectVideo(cell: SCChatMessageCell) {
        
        print("DID TAP VIDEO")
    }
    
    // MARK: - Other Methods

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
