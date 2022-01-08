//
//  SCNavigationViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

open class SCNavigationController: UINavigationController, UINavigationControllerDelegate {
    var shouldIgnorePush = false
    
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if shouldIgnorePush == false {
            super.pushViewController(viewController, animated: true)
        }
    }
    
    open func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        shouldIgnorePush = true
    }
    
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        shouldIgnorePush = false
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
