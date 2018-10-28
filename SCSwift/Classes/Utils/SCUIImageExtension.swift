//
//  SCUIImageExtension.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import Foundation

public extension UIImage {
    
    public func resize(percentage: CGFloat) -> UIImage? {
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let width = cgImage.width / 4
        let height = cgImage.height / 4
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        let bitmapInfo = cgImage.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        context.interpolationQuality = .default
        context.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat(width), height: CGFloat(height))))
        
        if let scaledImage = context.makeImage() {
            return UIImage(cgImage: scaledImage)
        } else {
            return nil
        }
    }
    
    public func fixOrientation() -> UIImage {
        
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi));
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(Double.pi/2));
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-(Double.pi/2)));
            
        case .up, .upMirrored:
            break
        }
        
        switch self.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1);
            
        default:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: (self.cgImage?.bitsPerComponent)!,
            bytesPerRow: 0,
            space: (self.cgImage?.colorSpace!)!,
            bitmapInfo: UInt32((self.cgImage?.bitmapInfo.rawValue)!)
        )
        
        ctx?.concatenate(transform);
        
        switch self.imageOrientation {
            
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height,height: self.size.width));
            
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width,height: self.size.height));
            break;
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx?.makeImage()
        
        let img = UIImage(cgImage: cgimg!)
        
        //CGContextRelease(ctx);
        //CGImageRelease(cgimg);
        
        return img;
    }
    
    public func flipped() -> UIImage {
        var imageOrientation: UIImage.Orientation?
        switch(self.imageOrientation){
        case .down: imageOrientation = .downMirrored; break
        case .downMirrored: imageOrientation = .down; break
        case .left: imageOrientation = .leftMirrored; break
        case .leftMirrored: imageOrientation = .left; break
        case .right: imageOrientation = .rightMirrored; break
        case .rightMirrored: imageOrientation = .right; break
        case .up: imageOrientation = .upMirrored; break
        case .upMirrored: imageOrientation = .up; break
        }
        return UIImage(cgImage: self.cgImage!, scale: self.scale, orientation: imageOrientation!)
    }
    
    public func mergeTop(bottomImage: UIImage) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: bottomImage.size.height))
        bottomImage.draw(in: CGRect(x: 0, y: 0, width: bottomImage.size.width, height: self.size.height))
        
        if let mergedImage = UIGraphicsGetImageFromCurrentImageContext() {
            return mergedImage
        }
        UIGraphicsEndImageContext()
        
        return nil
    }
    
    public class func maskImage(image: UIImage, withMask maskImage: UIImage) -> UIImage {
        
        let maskRef = maskImage.cgImage
        
        let mask = CGImage(
            maskWidth: maskRef!.width,
            height: maskRef!.height,
            bitsPerComponent: maskRef!.bitsPerComponent,
            bitsPerPixel: maskRef!.bitsPerPixel,
            bytesPerRow: maskRef!.bytesPerRow,
            provider: maskRef!.dataProvider!,
            decode: nil,
            shouldInterpolate: false)
        
        let masked = image.cgImage!.masking(mask!)
        let maskedImage = UIImage(cgImage: masked!)
        return maskedImage
    }
    
    public func paint(with color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
