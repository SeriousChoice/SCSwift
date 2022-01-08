//
//  SCMediaViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import SDWebImage

open class SCImageViewController: SCMediaViewController, UIScrollViewDelegate {
    
    // MARK: - Xibs
    
    private var scrollView: UIScrollView!
    public var imgImage: UIImageView!
    private var spinner: UIActivityIndicatorView!
    
    // MARK: - Constants & Variables
    
    var maxZoomScale: CGFloat = 4.0
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        scrollView = UIScrollView(frame: view.frame)
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        view.addSubview(scrollView)
        
        imgImage = UIImageView(frame: scrollView.frame)
        imgImage.center = scrollView.center
        scrollView.addSubview(imgImage)
        
        if maxZoomScale > 4.0 {
            print("[Image] Error: Max zoom scale is 5.0")
        }
        
        scrollView.maximumZoomScale = maxZoomScale > 4.0 ? 4.0 : maxZoomScale
        scrollView.minimumZoomScale = 1.0
        
        imgImage.isUserInteractionEnabled = true
        imgImage.clipsToBounds = true
        imgImage.contentMode = .scaleAspectFit
        
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.startAnimating()
        spinner.center = view.center
        
        self.showImage()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.frame
        imgImage.frame = scrollView.frame
        spinner.center = view.center
    }
    
    // MARK: - Image Methods
    
    func showImage() {
        
        spinner.isHidden = false
        spinner.startAnimating()
        if let image = media.image {
            spinner.stopAnimating()
            imgImage.image = image
        } else if let url = media.url {
            imgImage.setImage(with: url, placeholder: nil, completion: { (image) in
                self.spinner.stopAnimating()
                if image == nil {
                    self.delegate?.mediaDidFailLoad(media: self.media)
                }
            })
        } else if let url = media.localUrl {
            spinner.stopAnimating()
            imgImage.image = UIImage(contentsOfFile: url.path)
        }
    }
    
    // MARK: - UIScrollView Delegate
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgImage
    }
    
    // MARK: - Other Methods
    
    override public func didDoubleTap() {
        super.didDoubleTap()
        
        let zoomScale = scrollView.zoomScale
        
        if zoomScale >= maxZoomScale {
            scrollView.setZoomScale(1.0, animated: true)
            return
        }
        
        if zoomScale >= 1.0 && zoomScale < 2.5 {
            scrollView.setZoomScale(2.5, animated: true)
        } else if zoomScale >= 2.5 && zoomScale < 4.0 {
            scrollView.setZoomScale(4.0, animated: true)
        }
    }
    
    open override func refresh(media: SCMedia) {
        super.refresh(media: media)
        showImage()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

