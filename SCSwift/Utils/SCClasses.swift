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

public class SCObservable<T> {
    public var value: T? {
        didSet {
            for (_, value) in listeners {
                value(self.value)
            }
        }
    }
    private var listeners = [String: (value: T?) -> Void]()
    
    public init(_ value: T?) {
        self.value = value
    }
    
    public func bind(key: String?, listener: @escaping (_ value: T?) -> Void) {
        listener(self.value)
        self.listeners.updateValue(listener, forKey: key ?? UUID().uuidString)
    }
}

public class SCTableDataSource<CELL: UITableViewCell, T: Any> : NSObject, UITableViewDataSource {
    
    private var tableView: UITableView?
    private var cellIdentifier: String!
    private var items: SCObservable<[T]>!
    public var configureCell: (CELL, T, IndexPath) -> () = {_, _, _ in }
    
    public init(tableView: UITableView?, cellIdentifier: String, items: SCObservable<[T]>, configureCell: @escaping (CELL, T, IndexPath) -> ()) {
        super.init()
        self.tableView = tableView
        self.cellIdentifier = cellIdentifier
        self.items = items
        self.configureCell = configureCell
        observeChanges()
    }
    
    private let fromRow = {(row: Int) in return IndexPath(row: row, section: 0)}
    
    private func observeChanges() {
        items.bind(key: nil) {[weak self] _ in
            DispatchQueue.main.async {
                self?.tableView?.reloadData()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.value?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CELL else {
            return UITableViewCell()
        }
        if let item = items.value?[indexPath.row] {
            configureCell(cell, item, indexPath)
        }
        return cell
    }
}

public class SCCollectionDataSource<CELL: UICollectionViewCell, T: Any> : NSObject, UICollectionViewDataSource {
    
    private var collectionView: UICollectionView?
    private var cellIdentifier: String!
    private var items: SCObservable<[T]>!
    public var configureCell: (CELL, T, IndexPath) -> () = {_, _, _ in }
    
    public init(collectionView: UICollectionView?, cellIdentifier: String, items: SCObservable<[T]>, configureCell: @escaping (CELL, T, IndexPath) -> ()) {
        super.init()
        self.collectionView = collectionView
        self.cellIdentifier = cellIdentifier
        self.items = items
        self.configureCell = configureCell
        observeChanges()
    }
    
    private func observeChanges() {
        items.bind(key: nil) {[weak self] value in
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.value?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CELL else {
            return UICollectionViewCell()
        }
        if let item = items.value?[indexPath.row] {
            configureCell(cell, item, indexPath)
        }
        return cell
    }
}
