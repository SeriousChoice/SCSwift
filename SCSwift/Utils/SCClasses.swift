//
//  SCUIImageExtension.swift
//  SCSwift
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import Foundation
import Cache

open class Cache : NSObject {
    
    static let shared = Cache()
    private var storage: Storage<String, Data>!
    
    override init() {
        
        let diskConfig = DiskConfig(
            name: "DiskCache",
            expiry: .date(Date().addingTimeInterval(2*3600)),
            maxSize: 10000,
            directory: try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask,
                                                    appropriateFor: nil, create: true).appendingPathComponent("Cache"),protectionType: .complete
        )
        
        let memoryConfig = MemoryConfig(
            expiry: .date(Date().addingTimeInterval(2*60)),
            countLimit: 50,
            totalCostLimit: 0
        )
        
        storage = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forData())
    }
    
    public func setObject(_ object: Data, forKey key: String) {
        
        do {
            try storage.setObject(object, forKey: key)
        } catch {
            print("[Cache] Error: \(error.localizedDescription)")
        }
    }
    
    public func object(forKey key: String) -> Data? {
        
        do {
            let object = try storage.object(forKey: key)
            return object
        } catch {
            print("[Cache] Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    public func removeObject(forKey key: String) {
        
        do {
            try storage.removeObject(forKey: key)
        } catch {
            print("[Cache] Error: \(error.localizedDescription)")
        }
    }
    
    public func clearAll() {
        
        do {
            try storage.removeAll()
        } catch {
            print("[Cache] Error: \(error.localizedDescription)")
        }
    }
}

@propertyWrapper
public struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    let container: UserDefaults = .standard
    
    public var wrappedValue: Value {
        get {
            container.value(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}
