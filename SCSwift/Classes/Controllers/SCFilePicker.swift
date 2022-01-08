//
//  SCFilePicker.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import MobileCoreServices

public typealias FilePickerCompletion = (_ fileUrl: URL?, _ message: String?) -> Void

public enum SCFileExtension {
    case jpg
    case png
    case pdf
    case zip
    case doc
    case gif
}

open class SCFilePicker: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    public static let shared = SCFilePicker()
    
    private static let SCFilePickerPickTitleText = "SCFilePickerPickTitleText"
    private static let SCFilePickerCancelTitleText = "SCFilePickerCancelTitleText"
    
    private var viewController: UIViewController?
    private var pickerCompletion: FilePickerCompletion?
    private var currentMaxSize: Int?   //Bytes
    
    public var pickerTitleText : String? {
        get { return UserDefaults.standard.string(forKey: SCFilePicker.SCFilePickerPickTitleText) ?? "Search document" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: SCFilePicker.SCFilePickerPickTitleText) }
    }
    
    public var pickerCancelText : String? {
        get { return UserDefaults.standard.string(forKey: SCFilePicker.SCFilePickerCancelTitleText) ?? "Cancel" }
        set (newValue) { UserDefaults.standard.set(newValue, forKey: SCFilePicker.SCFilePickerCancelTitleText) }
    }
    
    open func pickFile(on viewController: UIViewController?, fileExtensions: [SCFileExtension], maxSize: Int?, completion: @escaping FilePickerCompletion) {
        
        self.viewController = viewController
        self.pickerCompletion = completion
        self.currentMaxSize = maxSize
        
        let isJpg = fileExtensions.contains(.jpg)
        let isPng = fileExtensions.contains(.png)
        let imageExtension: SCFileExtension = isPng && isJpg ? .png : isPng ? .png : .jpg
         
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: SCImagePicker.shared.photoCameraText, style: .default, handler: { (action) in
            if let onViewController = viewController {
                SCImagePicker.shared.pick(in: onViewController, type: .photoCamera, fileExtension: imageExtension, maxSize: maxSize, editing: true, completionBlock: { (image, imageUrl, message) in
                    if let completion = self.pickerCompletion {
                        completion(imageUrl, nil)
                    }
                }) { (error) in
                    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "close".localized, style: .cancel, handler: nil))
                    onViewController.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: SCImagePicker.shared.cameraRollText, style: .default, handler: { (action) in
            if let onViewController = viewController {
                SCImagePicker.shared.pick(in: onViewController, type: .photoLibrary, fileExtension: imageExtension, maxSize: maxSize, editing: true, completionBlock: { (image, imageUrl, message) in
                    if let completion = self.pickerCompletion {
                        completion(imageUrl, nil)
                    }
                }) { (error) in
                    let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "close".localized, style: .cancel, handler: nil))
                    onViewController.present(alert, animated: true, completion: nil)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: pickerTitleText, style: .default, handler: { (action) in
            var extensions = [String]()
            for fileExtension in fileExtensions {
                switch fileExtension {
                    case .jpg: extensions.append(String(kUTTypeJPEG))
                    case .png: extensions.append(String(kUTTypePNG))
                    case .pdf: extensions.append(String(kUTTypePDF))
                    case .zip: extensions.append(String(kUTTypeZipArchive))
                    case .doc: extensions.append(String(kUTTypeText))
                    case .gif: extensions.append(String(kUTTypeGIF))
                }
            }
            let picker = UIDocumentPickerViewController(documentTypes: extensions, in: .import)
            picker.delegate = self
            viewController?.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: pickerCancelText, style: .cancel, handler: { (action) in
            if let completion = self.pickerCompletion {
                completion(nil, nil)
            }
        }))
        
        viewController?.present(alert, animated: true, completion: nil)
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        if let fileUrl = urls.first {
            
            print("[SCFilePicker] Document Url: \(fileUrl)")
            if let data = try? Data(contentsOf: fileUrl), let maxSize = currentMaxSize, maxSize < data.count {
                if let completion = pickerCompletion {
                    completion(nil, "File too big")
                    return
                }
            } else {
                if let completion = pickerCompletion {
                    completion(fileUrl, nil)
                }
            }
        }
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
        viewController?.dismiss(animated: true, completion: nil)
    }
}
