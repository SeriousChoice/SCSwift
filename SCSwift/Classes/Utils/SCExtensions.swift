//
//  SCExtensions.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import Foundation
import SafariServices
import SDWebImage

extension UIScrollView {
    
    func scrollTop() {
        self.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    }
}

extension UITableViewCell {
    
    public func prepareDisclosureIndicator() {
        
        for case let button as UIButton in subviews {
            let image = button.backgroundImage(for: .normal)?.withRenderingMode(.
                alwaysTemplate)
            button.tintColor = self.tintColor
            button.setBackgroundImage(image, for: .normal)
        }
    }
    
    public class var identifier : String {
        return NSStringFromClass(UITableViewCell.self)
    }
}

public extension URL {
    
    public var fileExists : Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }
    
    public func ignoreCloudBackup() {
        
        var urlCopy = self
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        
        do {
            try urlCopy.setResourceValues(values)
        } catch {
            print("[iCloud URL] \(error.localizedDescription)")
        }
    }
}

public extension String {
    
    public var localized : String {
        return NSLocalizedString(self, comment: "")
    }
    
    public var image : UIImage? {
        return UIImage(named: self)
    }
    
    public var containsOnlyDecimals : Bool {
        
        let set = NSCharacterSet.decimalDigits.inverted
        let range = self.rangeOfCharacter(from: set)
        return range == nil
    }
    
    public var isValidEmail : Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
    public var isValidPhoneNumber : Bool {
        
        let containsNumbers = self.rangeOfCharacter(from: .decimalDigits) != nil
        let isLongEnough = self.count > 5
        return containsNumbers && isLongEnough
    }
    
    public var isValidRemoteUrl : Bool {
        
        if let _ = URL(string: self) {
            return true
        } else {
            return false
        }
    }
}

public extension UIColor {
    
    public convenience init(red: Int, green: Int, blue: Int) {
        
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    public convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    public var darker : UIColor {
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: max(r - 0.10, 0.0), green: max(g - 0.10, 0.0), blue: max(b - 0.10, 0.0), alpha: a)
        }
        return UIColor()
    }
    
    public var lighter : UIColor {
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: min(r + 0.1, 1.0), green: min(g + 0.1, 1.0), blue: min(b + 0.1, 1.0), alpha: a)
        }
        return UIColor()
    }
    
    public func getRGB() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
            
        } else {
            return nil
        }
    }
    
    public var isDark: Bool {
        
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  lum < 0.50 ? true : false
    }
}

public extension UIView {
    
    public func removeSubviews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    public func removeConstraints() {
        
        for view in subviews {
            view.removeConstraints()
        }
        for constraint in constraints {
            removeConstraint(constraint)
        }
    }
    
    public func setBorders(borderWidth: CGFloat, borderColor: UIColor?, cornerRadius: CGFloat) {
        
        self.layer.borderWidth = borderWidth
        if borderColor != nil {
            self.layer.borderColor = borderColor?.cgColor
        }
        self.layer.cornerRadius = cornerRadius
    }
    
    public func addShadow(color: UIColor, offset: CGSize, opacity: Float) {
        
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = offset.height
    }
    
    class var separatorHeight : CGFloat {
        return 1.0/UIScreen.main.scale
    }
    
    class var safeArea : UIEdgeInsets {
        if #available(iOS 11, *) {
            return UIApplication.shared.keyWindow!.safeAreaInsets
        }
        return .zero
    }
}

public extension UIDevice {
    
    public class var isIpad : Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    public var diskTotalSpace : Int64? {
        
        var value: Int64?
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let path = paths.last?.path {
            do {
                let dictionary = try FileManager.default.attributesOfFileSystem(forPath: path) as [FileAttributeKey : Any]
                if let totalSize = dictionary[.systemSize] as? NSNumber {
                    value = (totalSize.int64Value/1024)/1024
                }
            } catch {
                print("[Device Disk Space] Error: \(error.localizedDescription)")
            }
            
        }
        return value
    }
    
    public var diskFreeSpace : Int64? {
        
        var value: Int64?
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if let path = paths.last?.path {
            do {
                let dictionary = try FileManager.default.attributesOfFileSystem(forPath: path) as [FileAttributeKey : Any]
                if let freeSize = dictionary[.systemFreeSize] as? NSNumber {
                    value = (freeSize.int64Value/1024)/1024
                }
            } catch {
                print("[Device Disk Space] Error: \(error.localizedDescription)")
            }
            
        }
        return value
    }
    
    public class var isPortrait : Bool {
        return UIApplication.shared.statusBarOrientation == .portrait || UIApplication.shared.statusBarOrientation == .portraitUpsideDown
    }
}

public extension Bundle {
    
    public var appName : String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
}

public extension UIScreen {
    
    public class var width : CGFloat {
        return UIDevice.isPortrait ? UIScreen.main.bounds.size.width : UIScreen.main.bounds.size.height
    }
    
    public class var height : CGFloat {
        return UIDevice.isPortrait ? UIScreen.main.bounds.size.height : UIScreen.main.bounds.size.width
    }
    
    public class var separatorHeight : CGFloat {
        return 1/UIScreen.main.scale
    }
}

public typealias UIAlertActionBlock = (_ action: UIAlertAction) -> Void
public extension UIAlertController {
    
    public class func new(title: String?, message: String?, tintColor: UIColor?, preferredStyle: UIAlertController.Style) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if let tint = tintColor {
            alert.view.tintColor = tint
        }
        return alert
    }
    
    public func addCancelAction(title: String?, handler: UIAlertActionBlock?) {
        
        let action = UIAlertAction(title: title, style: .cancel, handler: handler)
        self.addAction(action)
    }
    
    public func addDefaultAction(title: String?, handler: UIAlertActionBlock?) {
        
        let action = UIAlertAction(title: title, style: .default, handler: handler)
        self.addAction(action)
    }
    
    public func addDestructiveAction(title: String?, handler: UIAlertActionBlock?) {
        
        let action = UIAlertAction(title: title, style: .destructive, handler: handler)
        if #available(iOS 9, *) {
            action.setValue(UIColor.red, forKey: "titleTextColor")
        }
        self.addAction(action)
        
    }
}

extension UIApplication: SFSafariViewControllerDelegate {
    
    public func openUrl(stringUrl: String?, on viewController: UIViewController?) {
        
        guard let stringUrl = stringUrl else { return }
        guard let url = URL(string: stringUrl) else { return }
        
        openUrl(url: url, on: viewController)
    }
    
    public func openUrl(url: URL, on viewController: UIViewController?) {
        
        if #available(iOS 9.0, *) {
            
            if let viewController = viewController {
                let safari = SFSafariViewController(url: url)
                safari.modalPresentationStyle = .overFullScreen
                viewController.present(safari, animated: true, completion: nil)
            } else {
                if self.canOpenURL(url) {
                    self.openURL(url)
                }
            }
            
        } else {
            
            if self.canOpenURL(url) {
                self.openURL(url)
            }
        }
    }
    
    @available(iOS 9.0, *)
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension DateFormatter {
    
    var fixedShortWeekDays : [String] {
        
        var days = self.shortWeekdaySymbols!
        let first = days.first!
        days.removeFirst()
        days.append(first)
        return days
    }
}

public extension UICollectionViewCell {
    
    public func fixedContentSize(width: CGFloat) -> CGSize {
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        let size = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: width, height: size.height)
    }
}

public extension UINavigationController {
    
    public func addFirst(viewController: UIViewController?) {
        
        guard let viewController = viewController else { return }
        viewControllers.insert(viewController, at: 0)
    }
    
    public func addLast(viewController: UIViewController?) {
        
        guard let viewController = viewController else { return }
        viewControllers.append(viewController)
    }
}

public extension UIImageView {
    
    public func setImage(with url: URL?, placeholder: UIImage?, completion: ((_ image: UIImage?) -> Void)?) {
        
        self.sd_setImage(with: url, placeholderImage: placeholder, options: .continueInBackground) { (image, error, cacheType, url) in
            
            if let error = error {
                print("[Image] Error: \(error.localizedDescription)")
            }
            
            if let completion = completion {
                completion(image)
            }
        }
    }
    
    public func setImage(url: String?, placeholder: UIImage?) {
        
        guard let url = url else {
            self.image = nil
            return
        }
        
        self.setImage(stringUrl: url, placeholder: placeholder, completion: nil)
    }
    
    public func setImage(stringUrl: String?, placeholder: UIImage?, completion: ((_ image: UIImage?) -> Void)?) {
        
        guard let stringUrl = stringUrl else {
            self.image = nil
            if let completion = completion {
                completion(nil)
            }
            return
        }
        
        var url: URL?
        if let remoteUrl = URL(string: stringUrl) {
            url = remoteUrl
        } else {
            url = URL(fileURLWithPath: stringUrl)
        }
        
        guard url != nil else {
            self.image = nil
            if let completion = completion {
                completion(nil)
            }
            return
        }
        
        self.sd_setImage(with: url) { (image, error, cacheType, url) in
            
            if error == nil && image != nil {
                
                self.image = image
                
                if cacheType == .none {
                    let transition = CATransition()
                    transition.type = CATransitionType.fade
                    transition.duration = 0.3
                    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                    self.layer.add(transition, forKey: nil)
                }
            }
            
            if let completion = completion {
                completion(image)
            }
        }
    }
    
    public func rotate(by degrees: CGFloat) {
        transform = CGAffineTransform(rotationAngle: degrees)
    }
    
    public func cancelTransform() {
        transform = .identity
    }
}

