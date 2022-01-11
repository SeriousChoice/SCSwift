//
//  SCHud.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import PureLayout

class SCHudButtonCell : UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        clipsToBounds = true
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: true)
        
        if highlighted {
            if let rgb = superview?.superview?.backgroundColor?.getRGB() {
                if rgb.red > 225 && rgb.green > 225 && rgb.blue > 225 {
                    self.backgroundColor = UIColor(netHex: 0xeeeeee)
                } else {
                    self.backgroundColor = superview?.superview?.backgroundColor?.lighter
                }
            } else {
                self.backgroundColor = superview?.superview?.backgroundColor?.lighter
            }
        } else {
            self.backgroundColor = .clear
        }
    }
}

open class SCHudButton : NSObject {
    
    var title: String?
    var highlighted: Bool = false
    var action: (() -> Void)?
    
    public convenience init(title: String?, highlighted: Bool, action: (() -> Void)?) {
        self.init()
        
        self.title = title
        self.highlighted = highlighted
        self.action = action
    }
}

public protocol SCLabelDelegate : AnyObject {
    func labelDidChangeText(text: String?)
}

open class SCLabel : UILabel {
    
    weak var delegate: SCLabelDelegate?
    
    override open var text: String? {
        
        didSet {
            delegate?.labelDidChangeText(text: text)
        }
    }
}

public enum SCHudTheme {
    case light
    case dark
    case custom(hudColor: UIColor, textColor: UIColor)
}

public enum SCHudStyle {
    case indeterminate
    case linearProgress
    case rotationInside(image: UIImage, duration: TimeInterval)
    case rotationOnly(image: UIImage, duration: TimeInterval)
}

@objc open class SCHud: UIView, SCLabelDelegate, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Views
    
    open var hudView: UIView!
    private var progressView: UIView!
    private var progressBar: UIProgressView!
    private var imageView: UIImageView!
    private var tblButtons: UITableView!
    open var textLabel: SCLabel?
    
    // MARK: - Constraints
    
    var cntTextLabelTop: NSLayoutConstraint!
    var cntTextLabelBottomSuperview: NSLayoutConstraint!
    var cntTextLabelBottomButtons: NSLayoutConstraint!
    var cntTblButtonsHeight: NSLayoutConstraint!
    
    // MARK: - Constants & Variables
    
    private var theme = SCHudTheme.dark
    private var style = SCHudStyle.indeterminate
    @objc public var progress: Float = 0
    @objc public var isVisible = false
    private var contentOffset: CGFloat = 16
    private var shadowColor: UIColor = .black
    private var shadowOffset: CGSize = .zero
    private var shadowRadius: CGFloat = 3
    private var shadowOpacity: Float = 0.3
    private let cellIdentifier = "cellIdentifier"
    private var buttons = [SCHudButton]()
    private let buttonRowHeight: CGFloat = 50
    private var blurView: UIVisualEffectView!
    
    // MARK: - Initialization
    
    public convenience init(theme: SCHudTheme, style: SCHudStyle) {
        self.init()
        
        backgroundColor = .clear
        clipsToBounds = true
        
        self.theme = theme
        self.style = style
        
        set(style: style)
    }
    
    // MARK: - SCLabel Delegate
    
    public func labelDidChangeText(text: String?) {
        
        fixLabelPosition()/*
         if superview != nil {
         UIView.animate(withDuration: 0.1) {
         self.textLabel?.layoutIfNeeded()
         }
         }*/
    }
    
    private func fixLabelPosition() {
        
        if textLabel != nil {
            let validText = textLabel?.text != nil && textLabel?.text?.isEmpty == false
            let offset: CGFloat = validText ? contentOffset : 0
            if cntTextLabelTop == nil {
                cntTextLabelTop = textLabel?.autoPinEdge(.top, to: .bottom, of: progressView, withOffset: offset)
            } else {
                cntTextLabelTop.constant = offset
            }
        }
    }
    
    // MARK: - Linear Progress Handlers
    
    open func set(progress: Float) {
        
        if progressBar != nil {
            progressBar.setProgress(progress, animated: true)
        }
    }
    
    open func setProgressColors(emptyColor: UIColor, filledColor: UIColor) {
        
        if progressBar != nil {
            progressBar.trackTintColor = emptyColor
            progressBar.progressTintColor = filledColor
        }
    }
    
    // MARK: - Shadow Handlers
    
    open func enableShadow(enable: Bool) {
        
        if hudView != nil {
            if enable {
                hudView.layer.shadowColor = shadowColor.cgColor
                hudView.layer.shadowOffset = shadowOffset
                hudView.layer.shadowRadius = shadowRadius
                hudView.layer.shadowOpacity = shadowOpacity
            } else {
                hudView.layer.shadowColor = UIColor.black.cgColor
                hudView.layer.shadowOffset = .zero
                hudView.layer.shadowRadius = 0
                hudView.layer.shadowOpacity = 0
            }
        }
    }
    
    open func setShadow(color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        
        shadowColor = color
        shadowOffset = offset
        shadowRadius = radius
        shadowOpacity = opacity
        enableShadow(enable: true)
    }
    
    // MARK: - Appearance Handlers
    
    open func set(style: SCHudStyle) {
        
        self.style = style
        if progressView != nil {
            progressView.removeSubviews()
        }
        
        switch style {
            
        case .indeterminate:
            
            setupHudView()
            
            progressView.removeSubviews()
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white
            switch theme {
                case .dark:
                    spinner.color = .white
                case .custom(hudColor: _, textColor: let textColor):
                    spinner.color = textColor
                default: spinner.color = .lightGray
            }
            
            progressView.addSubview(spinner)
            spinner.autoPinEdgesToSuperviewEdges()
            spinner.startAnimating()
            
        case .linearProgress:
            
            setupHudView()
            
            progressBar = UIProgressView(progressViewStyle: .default)
            progressBar.autoSetDimensions(to: CGSize(width: 200, height: 6))
            progressBar.clipsToBounds = true
            progressBar.layer.cornerRadius = 3
            
            progressView.addSubview(progressBar)
            progressBar.trackTintColor = UIColor(netHex: 0x999999)
            progressBar.progressTintColor = .green
            progressBar.progress = 0.5
            progressBar.autoAlignAxis(toSuperviewAxis: .vertical)
            progressBar.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            
        case .rotationInside(image: let image, duration: let duration):
            
            setupHudView()
            
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            imageView.image = image
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            imageView.autoSetDimensions(to: CGSize(width: 60, height: 60))
            
            progressView.addSubview(imageView)
            imageView.autoAlignAxis(toSuperviewAxis: .vertical)
            imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            
            imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            
            UIView.animateKeyframes(withDuration: duration, delay: 0, options:[.repeat, .autoreverse], animations: {
                self.imageView.layer.transform = CATransform3DMakeScale(-1.0, 1.0, 1.0)
            }) { (completed) in
                
            }
            
        case .rotationOnly(image: let image, duration: let duration):
            
            removeHudView()
            
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            imageView.image = image
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFit
            imageView.autoSetDimensions(to: CGSize(width: 80, height: 80))
            
            addSubview(imageView)
            imageView.autoCenterInSuperview()
            
            imageView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
            
            UIView.animateKeyframes(withDuration: duration, delay: 0, options:[.repeat, .autoreverse], animations: {
                self.imageView.layer.transform = CATransform3DMakeScale(-1.0, 1.0, 1.0)
            }) { (completed) in
                
            }
        }
    }
    
    private func setupHudView() {
        
        if imageView != nil {
            imageView.removeFromSuperview()
        }
        
        if hudView != nil {
            return
        }
        
        hudView = UIView()
        hudView.clipsToBounds = true
        hudView.layer.cornerRadius = 8
        hudView.layer.borderWidth = 1/UIScreen.main.scale
        hudView.layer.borderColor = UIColor.lightGray.cgColor
        hudView.autoSetDimension(.width, toSize: 30, relation: .greaterThanOrEqual)
        hudView.autoSetDimension(.height, toSize: 30, relation: .greaterThanOrEqual)
        
        progressView = UIView()
        
        textLabel = SCLabel()
        textLabel?.delegate = self
        textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        textLabel?.textAlignment = .center
        textLabel?.numberOfLines = 0
        
        switch theme {
        case .light:
            hudView.backgroundColor = .white
            textLabel?.textColor = UIColor.black
        case .dark:
            hudView.backgroundColor = UIColor(netHex: 0x444444)
            textLabel?.textColor = UIColor.white
        case .custom(hudColor: let hudColor, textColor: let textColor):
            hudView.backgroundColor = hudColor
            textLabel?.textColor = textColor
        }
        
        hudView.addSubview(progressView)
        progressView.autoAlignAxis(toSuperviewAxis: .vertical)
        progressView.autoPinEdge(toSuperviewEdge: .top, withInset: contentOffset)
        progressView.autoPinEdge(toSuperviewEdge: .left, withInset: contentOffset, relation: .greaterThanOrEqual)
        progressView.autoPinEdge(toSuperviewEdge: .right, withInset: contentOffset, relation: .greaterThanOrEqual)
        
        hudView.addSubview(textLabel!)
        fixLabelPosition()
        if cntTextLabelBottomSuperview == nil {
            cntTextLabelBottomSuperview = textLabel?.autoPinEdge(toSuperviewEdge: .bottom, withInset: contentOffset)
        } else {
            textLabel?.addConstraint(cntTextLabelBottomSuperview)
        }
        textLabel?.autoPinEdge(toSuperviewEdge: .left, withInset: contentOffset)
        textLabel?.autoPinEdge(toSuperviewEdge: .right, withInset: contentOffset)
        
        addSubview(hudView)
        hudView.autoCenterInSuperview()
        hudView.autoPinEdge(toSuperviewEdge: .top, withInset: 32, relation: .greaterThanOrEqual)
        hudView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 32, relation: .greaterThanOrEqual)
        hudView.autoPinEdge(toSuperviewEdge: .left, withInset: 32, relation: .greaterThanOrEqual)
        hudView.autoPinEdge(toSuperviewEdge: .right, withInset: 32, relation: .greaterThanOrEqual)
    }
    
    private func removeHudView() {
        
        if self.hudView != nil {
            self.hudView.removeFromSuperview()
        }
    }
    
    @objc open func show(in view: UIView) {
        
        if superview == nil {
            view.addSubview(self)
            autoPinEdgesToSuperviewEdges()
            isVisible = true
        }
    }
    
    @objc open func show(in view: UIView, animated: Bool) {
        
        if superview == nil {
            view.addSubview(self)
            autoPinEdgesToSuperviewEdges()
            if animated {
                alpha = 0.0
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1.0
                } completion: { (_) in
                    self.isVisible = true
                }
            }
        }
    }
    
    @objc open func hide() {
        if tblButtons != nil {
            tblButtons.removeObserver(self, forKeyPath: "contentSize")
        }
        removeFromSuperview()
        self.isVisible = false
    }
    
    @objc open func hide(animated: Bool) {
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 1.0
            }) { (completed) in
                self.hide()
            }
        } else {
            hide()
        }
    }
    
    // MARK: - Buttons Handlers
    
    open func set(buttons newButtons: [SCHudButton]) {
        
        switch style {
        case .rotationOnly(image: _, duration: _):
            removeButtons()
            break
        default:
            
            self.buttons = newButtons
            
            if tblButtons == nil {
                
                tblButtons = UITableView(frame: .zero, style: .grouped)
                tblButtons.dataSource = self
                tblButtons.delegate = self
                tblButtons.backgroundColor = .clear
                tblButtons.separatorInset = .zero
                tblButtons.tableFooterView = nil
                tblButtons.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
                tblButtons.register(SCHudButtonCell.self, forCellReuseIdentifier: cellIdentifier)
                tblButtons.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
                
                let footer = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.00001))
                footer.backgroundColor = .clear
                tblButtons.tableFooterView = footer
            }
            
            switch theme {
            case .custom(hudColor: _, textColor: let textColor):
                tblButtons.separatorColor = textColor
            default: break
            }
            
            if tblButtons.superview == nil {
                
                hudView.addSubview(tblButtons)
                tblButtons.autoSetDimension(.width, toSize: 200, relation: .greaterThanOrEqual)
                tblButtons.autoPinEdge(toSuperviewEdge: .bottom)
                tblButtons.autoPinEdge(toSuperviewEdge: .left)
                tblButtons.autoPinEdge(toSuperviewEdge: .right)
                
                if cntTextLabelBottomSuperview != nil {
                    NSLayoutConstraint.deactivate([cntTextLabelBottomSuperview])
                }
                
                if cntTextLabelBottomButtons == nil {
                    cntTextLabelBottomButtons = textLabel?.autoPinEdge(.bottom, to: .top, of: tblButtons, withOffset: -contentOffset)
                } else {
                    textLabel?.addConstraint(cntTextLabelBottomButtons)
                }
            }
            
            tblButtons.reloadData()
        }
    }
    
    open func addButtons(buttons newButtons: [SCHudButton]) {
        
        buttons.append(contentsOf: newButtons)
        if tblButtons != nil {
            tblButtons.reloadData()
        }
    }
    
    private func removeButtons() {
        
        buttons = []
        
        if cntTextLabelBottomButtons != nil {
            NSLayoutConstraint.deactivate([cntTextLabelBottomButtons])
        }
        if cntTextLabelBottomSuperview == nil {
            cntTextLabelBottomSuperview = textLabel?.autoPinEdge(toSuperviewEdge: .bottom, withInset: contentOffset)
        } else {
            NSLayoutConstraint.activate([cntTextLabelBottomSuperview])
        }
        
        textLabel?.autoPinEdge(toSuperviewEdge: .bottom, withInset: contentOffset, relation: .equal)
        if tblButtons != nil {
            tblButtons.removeObserver(self, forKeyPath: "contentSize")
            tblButtons.removeFromSuperview()
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return buttonRowHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SCHudButtonCell
        cell.backgroundColor = .clear
        cell.textLabel?.textAlignment = .center
        
        let button = buttons[indexPath.row]
        switch theme {
        case .custom(hudColor: _, textColor: let textColor):
            cell.textLabel?.textColor = textColor
        case .dark:
            cell.textLabel?.textColor = .white
        case .light:
            cell.textLabel?.textColor = .black
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: button.highlighted ? .bold : .regular)
        cell.textLabel?.text = button.title
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let button = buttons[indexPath.row]
        if let action = button.action {
            action()
        }
    }
    
    // MARK: - Other Methods
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentSize" && object is UITableView {
            if tblButtons != nil {
                let height = buttons.count > 4 ? buttonRowHeight*4 : buttonRowHeight*CGFloat(buttons.count)
                tblButtons.isScrollEnabled = buttons.count > 4
                if cntTblButtonsHeight == nil {
                    cntTblButtonsHeight = tblButtons.autoSetDimension(.height, toSize: height)
                } else {
                    cntTblButtonsHeight.constant = height
                }
            }
        }
    }
}
