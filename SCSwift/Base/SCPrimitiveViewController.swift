//
//  SCPrimitiveViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

public struct KeyboardInfo {
    public var beginFrame: CGRect
    public var endFrame: CGRect
    public var animationDuration: Double
    public var animationCurve: UInt
}

public extension UserDefaults {
    enum SCPrimitiveViewControllerKeys {
        static let backgroundColor = "SCPrimiviteViewControllerBackgroundColor"
    }
    
    @UserDefault(key: SCPrimitiveViewControllerKeys.backgroundColor, defaultValue: 0xf7f7f7)
    static var primitiveViewControllerBackgroundColor: Int
}

open class SCPrimitiveViewController: UIViewController {
    open class var rawBackgroundColor : Int {
        get {
            return UserDefaults.primitiveViewControllerBackgroundColor
        }
        set {
            UserDefaults.primitiveViewControllerBackgroundColor = newValue
        }
    }
    
    // MARK: - Initialization
    
    deinit {
        self.unregisterForKeyboardNotifications()
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(netHex: SCPrimitiveViewController.rawBackgroundColor)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.registerForKeyboardNotifications()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unregisterForKeyboardNotifications()
    }
    
    // MARK: - Keyboard Handlers
    
    open func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardWillChangeFrame(notification:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardWillShow(notification:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardDidShow(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.internalKeyboardDidHide(notification:)), name: UIWindow.keyboardDidHideNotification, object: nil)
    }
    
    open func unregisterForKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardDidHideNotification, object: nil)
    }
    
    @objc private func internalKeyboardWillChangeFrame(notification: Notification) {
        self.keyboardWillChangeFrame(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    @objc private func internalKeyboardWillShow(notification: Notification) {
        self.keyboardWillShow(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    @objc private func internalKeyboardDidShow(notification: Notification) {
        self.keyboardDidShow(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    @objc private func internalKeyboardWillHide(notification: Notification) {
        self.keyboardWillHide(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    @objc private func internalKeyboardDidHide(notification: Notification) {
        self.keyboardDidHide(keyboardInfo: self.getKeyboardInfo(fromNotification: notification))
    }
    
    open func keyboardWillChangeFrame(keyboardInfo: KeyboardInfo) {
        
    }
    
    open func keyboardWillShow(keyboardInfo: KeyboardInfo) {
        
    }
    
    open func keyboardDidShow(keyboardInfo: KeyboardInfo) {
        
    }
    
    open func keyboardWillHide(keyboardInfo: KeyboardInfo) {
        
    }
    
    open func keyboardDidHide(keyboardInfo: KeyboardInfo) {
        
    }
    
    private func getKeyboardInfo(fromNotification: Notification) -> KeyboardInfo {
        
        let userInfo: NSDictionary = fromNotification.userInfo! as NSDictionary
        let beginFrame = (userInfo.value(forKey: UIResponder.keyboardFrameBeginUserInfoKey) as! NSValue).cgRectValue
        let endFrame = (userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        let animationDuration: Double = userInfo.value(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! Double
        let animationCurve: UInt = userInfo.value(forKey: UIResponder.keyboardAnimationCurveUserInfoKey) as! UInt
        
        let keyboardInfo = KeyboardInfo(
            beginFrame: beginFrame,
            endFrame: endFrame,
            animationDuration: animationDuration,
            animationCurve: animationCurve
        )
        
        return keyboardInfo
    }
    
    // MARK: - Others Methods
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
