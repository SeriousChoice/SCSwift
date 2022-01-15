//
//  SCFileToDownload.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

public struct SCFileToDownload {
    public var remoteStringUrl: String = ""
    public var localUrl: URL?
    
    public init(remoteStringUrl: String, localUrl: URL) {
        self.remoteStringUrl = remoteStringUrl
        self.localUrl = localUrl
    }
    
    public var isInvalid : Bool {
        return self.remoteStringUrl.isEmpty || self.localUrl == nil
    }
}
