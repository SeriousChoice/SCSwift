//
//  SCMediaViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

protocol SCMediaViewControllerDelegate : class {
    func mediaDidTapView()
    func mediaDidDoubleTap()
    func mediaDidFailLoad(media: SCMedia)
}

open class SCMediaViewController: UIViewController {
    
    public var index: Int = 0
    weak var delegate: SCMediaViewControllerDelegate?
    
    private var tap: UITapGestureRecognizer!
    private var doubleTap: UITapGestureRecognizer!
    public var media: SCMedia!
    
    // MARK: - Initialization
    
    public convenience init(media: SCMedia) {
        self.init()
        
        self.media = media
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setGestures(on: view)
    }
    
    // MARK: - Other Methods
    
    func setGestures(on view: UIView) {
        
        tap = UITapGestureRecognizer(target: self, action: #selector(self.didSingleTap(gesture:)))
        tap.numberOfTapsRequired = 1
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if media.type != .pdf {
            doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.didDoubleTap))
            doubleTap.cancelsTouchesInView = false
            doubleTap.numberOfTapsRequired = 2
            view.addGestureRecognizer(doubleTap)
            
            tap.require(toFail: doubleTap)
        }
    }
    
    @objc public func didSingleTap(gesture: UITapGestureRecognizer) {
        self.didTap()
    }
    
    @objc public func didTap() {
        delegate?.mediaDidTapView()
    }
    
    @objc public func didDoubleTap() {
        delegate?.mediaDidDoubleTap()
    }
    
    open func refresh(media: SCMedia) {
        self.media = media
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

