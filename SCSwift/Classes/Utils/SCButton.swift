//
//  SCButton.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

public class SCButton : UIButton {
    
    //Background color
    @IBInspectable var standardBackgroundColor: UIColor = UIColor.clear
    @IBInspectable var highlightedBackgroundColor: UIColor = UIColor.clear
    
    //Text color
    @IBInspectable var standardTextColor: UIColor = UIColor.blue
    @IBInspectable var highlightedTextColor: UIColor = UIColor.blue
    
    //Layout
    @IBInspectable var cornerRadius: CGFloat = 0
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var borderColor: UIColor = UIColor.red
    
    override public func awakeFromNib() {
        
        self.backgroundColor = self.standardBackgroundColor
        self.setTitleColor(self.standardTextColor, for: UIControl.State())
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderWidth = self.borderWidth
        self.layer.borderColor = self.borderColor.cgColor
        
        self.titleEdgeInsets = UIEdgeInsets(top: 1.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    override public var isHighlighted: Bool {
        
        didSet {
            UIView.animate(withDuration: 0.25, animations: {
                
                if self.isHighlighted {
                    self.backgroundColor = self.highlightedBackgroundColor
                    self.titleLabel?.textColor = self.highlightedTextColor
                } else {
                    self.backgroundColor = self.standardBackgroundColor
                    self.titleLabel?.textColor = self.standardTextColor
                }
            })
        }
    }
    
    @objc public func setColors(mainBg: UIColor?, highlightedBg: UIColor?, standardTxt: UIColor?, highlightedTxt: UIColor?) {
        
        if mainBg != nil {
            self.standardBackgroundColor = mainBg!
        }
        if highlightedBg != nil {
            self.highlightedBackgroundColor = highlightedBg!
        }
        if standardTxt != nil {
            self.standardTextColor = standardTxt!
        }
        if highlightedTxt != nil {
            self.highlightedTextColor = highlightedTxt!
        }
        
        self.backgroundColor = self.standardBackgroundColor
        self.setTitleColor(self.standardTextColor, for: UIControl.State())
        self.setTitleColor(self.highlightedTextColor, for: .highlighted)
    }
    
    public func setLayout(cornerRadius: CGFloat?, borderWidth: CGFloat?, borderColor: UIColor?) {
        
        if cornerRadius != nil {
            self.cornerRadius = cornerRadius!
            self.layer.cornerRadius = self.cornerRadius
        }
        if borderWidth != nil {
            self.borderWidth = borderWidth!
            self.layer.borderWidth = self.borderWidth
        }
        if borderColor != nil {
            self.borderColor = borderColor!
            self.layer.borderColor = self.borderColor.cgColor
        }
    }
}
