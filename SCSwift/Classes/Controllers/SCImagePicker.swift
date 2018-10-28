//
//  SCImagePickerController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

public typealias SCImagePickerCompletionBlock = (_ image: UIImage?, _ videoUrl: URL?, _ fileName: String) -> Void
public typealias SCImagePickerErrorBlock = (_ error: String) -> Void

public enum SCImagePickerType {
    case photoLibrary
    case videoLibrary
    case photoAndVideoLibrary
    case photoCamera
    case videoCamera
    case photoAndVideoCamera
}

public enum SCMediaType {
    case photo
    case video
    case photoAndVideo
}

public class SCImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public static let shared = SCImagePicker()
    
    private static let SCImagePickerPickTitleText = "SCImagePickerPickTitleText"
    private static let SCImagePickerPhotoCameraString = "SCImagePickerPhotoCameraString"
    private static let SCImagePickerCameraRollString = "SCImagePickerCameraRollString"
    private static let SCImagePickerCancelString = "SCImagePickerCancelString"
    
    private var completionBlock: SCImagePickerCompletionBlock!
    private var errorBlock: SCImagePickerErrorBlock?
    
    private var picker: UIImagePickerController!
    
    public override init() {
        super.init()
        
        picker = UIImagePickerController()
        picker.delegate = self
    }
    
    public var pickerTitleText : String? {
        get { return UserDefaults.standard.string(forKey: SCImagePicker.SCImagePickerPickTitleText) }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: SCImagePicker.SCImagePickerPickTitleText) }
    }
    
    public var photoCameraText : String {
        get { return UserDefaults.standard.string(forKey: SCImagePicker.SCImagePickerPhotoCameraString) ?? "Camera" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: SCImagePicker.SCImagePickerPhotoCameraString) }
    }
    
    public var cameraRollText : String {
        get { return UserDefaults.standard.string(forKey: SCImagePicker.SCImagePickerCameraRollString) ?? "Camera roll" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: SCImagePicker.SCImagePickerCameraRollString) }
    }
    
    public var cancelText : String {
        get { return UserDefaults.standard.string(forKey: SCImagePicker.SCImagePickerCancelString) ?? "Cancel" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: SCImagePicker.SCImagePickerCancelString) }
    }
    
    public func pickWithActionSheet(in viewController: UIViewController, mediaType: SCMediaType, editing: Bool, iPadStartFrame: CGRect?, completionBlock: @escaping SCImagePickerCompletionBlock, errorBlock: SCImagePickerErrorBlock?) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let alert = UIAlertController.new(title: self.pickerTitleText, message: nil, tintColor: nil, preferredStyle: .actionSheet)
            if UIDevice.isIpad {
                alert.popoverPresentationController?.sourceView = viewController.view
                if let frame = iPadStartFrame {
                    alert.popoverPresentationController?.sourceRect = frame
                } else {
                    alert.popoverPresentationController?.sourceRect = viewController.view.frame
                }
            }
            
            alert.addAction(UIAlertAction(title: self.photoCameraText, style: .default, handler: { (action) in
                let pickerType: SCImagePickerType = mediaType == .photo ? .photoCamera : mediaType == .video ? .videoCamera : .photoAndVideoCamera
                self.pick(in: viewController, type: pickerType, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
            }))
            alert.addAction(UIAlertAction(title: self.cameraRollText, style: .default, handler: { (action) in
                let pickerType: SCImagePickerType = mediaType == .photo ? .photoLibrary : mediaType == .video ? .videoLibrary : .photoAndVideoLibrary
                self.pick(in: viewController, type: pickerType, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
            }))
            alert.addAction(UIAlertAction(title: self.cancelText, style: .cancel, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
            
        } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let pickerType: SCImagePickerType = mediaType == .photo ? .photoCamera : mediaType == .video ? .videoCamera : .photoAndVideoCamera
            self.pick(in: viewController, type: pickerType, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
            
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let pickerType: SCImagePickerType = mediaType == .photo ? .photoLibrary : mediaType == .video ? .videoLibrary : .photoAndVideoLibrary
            self.pick(in: viewController, type: pickerType, editing: editing, completionBlock: completionBlock, errorBlock: errorBlock)
        }
    }
    
    public func pick(in viewController: UIViewController, type: SCImagePickerType, editing: Bool, completionBlock: @escaping SCImagePickerCompletionBlock, errorBlock: SCImagePickerErrorBlock?) {
        
        self.completionBlock = completionBlock
        self.errorBlock = errorBlock
        
        let isLibrary = type == .photoLibrary || type == .videoLibrary || type == .photoAndVideoLibrary
        let isPhoto = type == .photoLibrary || type == .photoCamera || type == .photoAndVideoLibrary || type == .photoAndVideoCamera
        let isVideo = type == .videoLibrary || type == .videoCamera || type == .photoAndVideoLibrary || type == .photoAndVideoCamera
        
        let sourceType: UIImagePickerController.SourceType = isLibrary ? .photoLibrary : .camera
        guard let mediaTypes = self.mediaTypesFor(sourceType: sourceType, photo: isPhoto, video: isVideo) else {
            if self.errorBlock != nil {
                self.errorBlock!("No picker media type available")
            }
            return
        }
        
        picker.allowsEditing = editing
        picker.sourceType = sourceType
        picker.mediaTypes = mediaTypes
        
        if isLibrary == false {
            picker.cameraCaptureMode = isPhoto ? .photo : .video
        }
        
        viewController.present(picker, animated: true, completion: nil)
    }
    
    private func mediaTypesFor(sourceType: UIImagePickerController.SourceType, photo: Bool, video: Bool) -> [String]? {
        
        guard let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType) else {
            return nil
        }
        
        var mediaTypes: [String]?
        if photo && video {
            mediaTypes = availableMediaTypes
        } else {
            for mediaType in availableMediaTypes {
                if (mediaType.compare(kUTTypeImage as String) == .orderedSame && photo == true) || (mediaType.compare(kUTTypeMovie as String) == .orderedSame && video == true) {
                    mediaTypes = [String]()
                    mediaTypes!.append(mediaType)
                    break
                }
            }
        }
        return mediaTypes
    }
    
    // MARK: - UIImagePickerController Delegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var image: UIImage?
        var videoUrl: URL?
        var fileUrl: URL?
        var fileName: String = ""
        
        if (info[.mediaType] as! String) == (kUTTypeImage as String) {
            
            if let pickedImage = info[.originalImage] as? UIImage {
                if let imageUrl = info[.referenceURL] as? URL {
                    fileUrl = imageUrl
                }
                image = pickedImage
            }
            
        } else if (info[.mediaType] as! String) == (kUTTypeMovie as String) {
            
            if let pickedVideoUrl = info[.mediaURL] as? URL {
                fileUrl = pickedVideoUrl
                videoUrl = pickedVideoUrl
            }
        }
        
        if let fileUrl = fileUrl {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    if let asset = PHAsset.fetchAssets(withALAssetURLs: [fileUrl], options: nil).firstObject {
                        PHImageManager.default().requestImageData(for: asset, options: nil, resultHandler: { _, _, _, info in
                            if let url = info!["PHImageFileURLKey"] as? URL {
                                fileName = url.lastPathComponent
                            }
                            self.completionBlock(image, videoUrl, fileName)
                            picker.dismiss(animated: true, completion: nil)
                        })
                    } else {
                        self.completionBlock(image, videoUrl, fileName)
                        picker.dismiss(animated: true, completion: nil)
                    }
                } else {
                    self.completionBlock(image, videoUrl, fileName)
                    picker.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            self.completionBlock(image, videoUrl, fileName)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
