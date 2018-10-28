//
//  SCSystemInfo.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 28/10/18.
//  Copyright © 2018 Nicola Innocenti. All rights reserved.
//

import UIKit

public class SCSystemInfo : NSObject {
    
    public var osName: String = ""
    public var osVersion: String = ""
    public var deviceType: String = ""
    public var appVersion: String = ""
    public var build: String = ""
    public var appName: String = ""
    public var batteryLevel: String = ""
    public var totalDiskAvailable: String = ""
    public var freeDiskAvailable: String = ""
    
    override init() {
        super.init()
        
        self.osName = UIDevice.current.systemName
        self.osVersion = UIDevice.current.systemVersion
        
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        self.deviceType = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.build = build
        }
        self.appName = Bundle.main.appName
        self.batteryLevel = "\(UIDevice.current.batteryLevel*100.0*(-1))%"
        if let diskTotalSpace = UIDevice.current.diskTotalSpace {
            self.totalDiskAvailable = "\(diskTotalSpace) MB"
        } else {
            self.totalDiskAvailable = "Rilevazione fallita"
        }
        if let diskFreeSpace = UIDevice.current.diskFreeSpace {
            self.freeDiskAvailable = "\(diskFreeSpace) MB"
        } else {
            self.freeDiskAvailable = "Rilevazione fallita"
        }
    }
}
