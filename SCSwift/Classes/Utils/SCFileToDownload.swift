//
//  SCFileToDownload.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

public class SCFileToDownload : NSObject {
    
    public var remoteStringUrl: String = ""
    public var localUrl: URL?
    
    public convenience init(remoteStringUrl: String, localUrl: URL) {
        self.init()
        
        self.remoteStringUrl = remoteStringUrl
        self.localUrl = localUrl
    }
    
    public var isInvalid : Bool {
        return self.remoteStringUrl.isEmpty || self.localUrl == nil
    }
}
