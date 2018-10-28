//
//  SCCollectionCell.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import Foundation

public protocol SCCollectionCellDelegate : class {
    func SCCollectionCellDidPress(cell: UICollectionViewCell)
}

open class SCCollectionCell : UICollectionViewCell, UIGestureRecognizerDelegate {
    
    // MARK: - Constants & Variables
    
    public weak var SCDelegate: SCCollectionCellDelegate?
    private var animationDuration: TimeInterval = 0.0
    public var pressGesture: UILongPressGestureRecognizer?
    
    // MARK: - Cell Methods
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
    
    // MARK: - Gestures Methods
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if pressGesture != nil {
            UIView.animate(withDuration: animationDuration, animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            })
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if pressGesture != nil {
            if let touch = touches.first {
                let location = touch.location(in: self)
                UIView.animate(withDuration: animationDuration, animations: {
                    self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
                if (location.x > 0 && location.x < frame.size.width) && (location.y > 0 && location.y < frame.size.height) {
                    SCDelegate?.SCCollectionCellDidPress(cell: self)
                }
            }
        }
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if pressGesture != nil {
            UIView.animate(withDuration: animationDuration, animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
        }
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @available(iOS 9.0, *)
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }
    
    // MARK: - Custom Methods
    
    public func applyPressAnimation(duration: TimeInterval) {
        
        animationDuration = duration
        
        pressGesture = UILongPressGestureRecognizer(target: self, action: nil)
        pressGesture?.cancelsTouchesInView = false
        pressGesture?.minimumPressDuration = 0
        pressGesture?.delegate = self
        self.addGestureRecognizer(pressGesture!)
    }
    
    public func applyCornerRadius(value: CGFloat) {
        contentView.setBorders(borderWidth: UIScreen.separatorHeight, borderColor: .clear, cornerRadius: value)
        contentView.layer.masksToBounds = true
    }
    
    public func applyShadow(color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: contentView.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }
}

