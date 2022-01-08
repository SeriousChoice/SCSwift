//
//  SCSystemInfo.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

public struct SCSystemInfo {
    public var osName: String
    public var osVersion: String
    public var deviceType: String
    public var appVersion: String
    public var build: String
    public var appName: String
    public var batteryLevel: String
    public var totalDiskAvailable: String
    public var freeDiskAvailable: String
    
    init() {
        osName = UIDevice.current.systemName
        osVersion = UIDevice.current.systemVersion
        
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        deviceType = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unavailable"
        appName = Bundle.main.appName
        batteryLevel = "\(UIDevice.current.batteryLevel*100.0*(-1))%"
        if let diskTotalSpace = UIDevice.current.diskTotalSpace {
            totalDiskAvailable = "\(diskTotalSpace) MB"
        } else {
            totalDiskAvailable = "Unavailable"
        }
        if let diskFreeSpace = UIDevice.current.diskFreeSpace {
            freeDiskAvailable = "\(diskFreeSpace) MB"
        } else {
            freeDiskAvailable = "Unavailable"
        }
    }
}
