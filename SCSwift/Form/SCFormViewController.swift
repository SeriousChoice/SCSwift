//
//  SCFormViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit

public extension UITableViewCell {
    
    @objc func configure(with row: SCFormRow) {
        
        accessoryType = row.type == .rowList || row.type == .rowListMulti || row.type == .rowAttachment ? .disclosureIndicator : row.accessoryType
        textLabel?.text = row.mandatory ? "\(row.title ?? "")*" : row.title
        if row.type == .rowAttachment {
            detailTextLabel?.text = row.attachmentUrl != nil ? "File" : ""
        } else if row.type == .rowList {
            if let item = row.value as? SCDataListItem {
                detailTextLabel?.text = item.title
            } else {
                detailTextLabel?.text = row.value as? String
            }
        } else if row.type == .rowListMulti {
            if let items = row.value as? [SCDataListItem] {
                detailTextLabel?.text = items.count > 0 ? "\(items.count) sel." : nil
            } else {
                detailTextLabel?.text = row.value as? String
            }
        } else {
            detailTextLabel?.text = row.type == .rowSubtitle ? row.subtitle : row.value as? String
        }
        imageView?.image = row.image
    }
}

public enum SCFormRowType {
    case rowDefault
    case rowSubtitle
    case rowTextField
    case rowPassword
    case rowEmail
    case rowTextArea
    case rowSwitch
    case rowDate
    case rowList
    case rowListMulti
    case rowAttachment
}

public enum SCFormRowValueType {
    case genericText
    case integer
    case decimal
    case email
    case url
    case letters
}

open class SCFormRow : NSObject {
    
    public var id: Any?
    public var key: String = ""
    public var title: String?
    public var subtitle: String?
    public var value: Any?
    public var placeholder: String?
    public var mandatory: Bool = false
    public var image: UIImage?
    public var extraData: Any?
    public var accessoryType: UITableViewCell.AccessoryType = .none
    public var type: SCFormRowType = .rowDefault
    public var valueType: SCFormRowValueType = .genericText
    public var valueRegex: String?
    public var dateFormat: String = ""
    public var enabled: Bool = true
    public var visible: Bool = true
    public var visibilityBindKey: String?
    public var visibilityBindValue: Any?
    public var extraInfo: String?
    public var attachmentUrl: URL?
    public var attachmentExtensions = [SCFileExtension]()
    public var attachmentMaxSize: Int?    //Byte
    
    public convenience init(default key: String?, title: String?, value: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowDefault
    }
    
    public convenience init(attachment key: String?, title: String?, value: String?, attachmentUrl: URL?, maxSize: Int?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.attachmentMaxSize = maxSize
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowAttachment
    }
    
    public convenience init(switch key: String?, title: String?, value: Bool, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowSwitch
    }
    
    public convenience init(date key: String?, title: String?, placeholder: String?, dateFormat: String, value: Date?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.dateFormat = dateFormat
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowDate
    }
    
    public convenience init(textField key: String?, title: String?, placeholder: String?, value: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowTextField
    }
    
    public convenience init(password key: String?, title: String?, placeholder: String?, value: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowPassword
    }
    
    public convenience init(email key: String?, title: String?, placeholder: String?, value: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowEmail
    }
    
    public convenience init(textArea key: String?, title: String?, placeholder: String?, value: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowTextArea
    }
    
    public convenience init(subtitle key: String?, title: String?, subtitle: String?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.subtitle = subtitle
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowSubtitle
    }
    
    public convenience init(list key: String?, title: String?, value: String?, extraData: Any?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.extraData = extraData
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowList
    }
    
    public convenience init(listMulti key: String?, title: String?, value: String?, extraData: Any?, visibilityBindKey: String?, visibilityBindValue: Any? = nil) {
        self.init()
        
        self.key = key ?? ""
        self.title = title
        self.value = value
        self.extraData = extraData
        self.visibilityBindKey = visibilityBindKey
        self.visibilityBindValue = visibilityBindValue
        self.visible = visibilityBindKey == nil
        self.type = .rowListMulti
    }
    
    public convenience init(id: Any?, key: String?, title: String?, subtitle: String?, value: Any?, placeholder: String?, image: UIImage?, extraData: Any?, dateFormat: String?, accessoryType: UITableViewCell.AccessoryType, mandatory: Bool, type: SCFormRowType, visible: Bool = true) {
        self.init()
        
        self.id = id
        self.key = key ?? ""
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.placeholder = placeholder
        self.image = image
        self.extraData = extraData
        self.dateFormat = dateFormat ?? ""
        self.accessoryType = accessoryType
        self.mandatory = mandatory
        self.type = type
        self.visible = visible
    }
}

open class SCFormSection : NSObject {
    
    public var id: Any?
    public var key: String = ""
    public var title: String?
    public var subtitle: String?
    public var value: Any?
    public var stackable: Bool = false
    public var stacked: Bool = true
    public var rows = [SCFormRow]()
    
    public convenience init(id: Any?, key: String = "", title: String?, subtitle: String?, value: Any?, stackable: Bool = false, rows: [SCFormRow]) {
        self.init()
        
        self.id = id
        self.key = key
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.stackable = stackable
        self.rows = rows
    }
}

open class SCFormViewController: SCPrimitiveViewController, UITableViewDataSource, UITableViewDelegate, SCTextFieldTableCellDelegate, SCTextViewTableCellDelegate, SCSwitchTableCellDelegate, SCDateTableCellDelegate, SCDataListViewControllerDelegate {
    
    // MARK: - Layout
    
    open var form: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.keyboardDismissMode = .interactive
        table.backgroundColor = .clear
        table.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
        table.register(SCTextFieldTableCell.self, forCellReuseIdentifier: SCTextFieldTableCell.identifier)
        table.register(SCTextViewTableCell.self, forCellReuseIdentifier: SCTextViewTableCell.identifier)
        table.register(SCSwitchTableCell.self, forCellReuseIdentifier: SCSwitchTableCell.identifier)
        table.register(SCDateTableCell.self, forCellReuseIdentifier: SCDateTableCell.identifier)
        table.register(SCAttachmentTableCell.self, forCellReuseIdentifier: SCAttachmentTableCell.identifier)
        return table
    }()
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    private var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Constraints
    
    private var cntContentHeight: NSLayoutConstraint?
    private var cntContentLeading: NSLayoutConstraint?
    private var cntContentTrailing: NSLayoutConstraint?
    
    // MARK: - Constants & Variables
    
    open var data = [SCFormSection]()
    
    open var tintColor: UIColor?
    open var switchColor: UIColor?
    open var backgroundColor: UIColor?
    open var sectionTitleColor = UIColor.lightGray
    open var titleColor = UIColor.black
    open var valueColor = UIColor.black
    open var cellBackgroundColor = UIColor.white
    open var editingEnabled: Bool = true
    open var searchTintColor: UIColor?
    open var navBackIcon: UIImage?
    open var sectionTitleFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    open var cellTitleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    open var cellValueFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    open var autoDismissListsOnSelection: Bool = true
    open var iPadMargin: CGFloat = 100
    open var maxFileSize: Int?    //Mb
    open var sectionHeaderHeight: CGFloat = 36
    
    open var currentIndexPath = IndexPath(row: 0, section: 0)
    
    private var marginsActive : Bool {
        return UIDevice.isIpad && iPadMargin > 0
    }
    
    open class var cellsMargin : CGFloat {
        get {
            let margin = CGFloat(UserDefaults.standard.float(forKey: "SCFormViewControllerCellsMargin"))
            if margin > 0 {
                return margin
            }
            return 16
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SCFormViewControllerCellsMargin")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Initialization
    
    deinit {
        if marginsActive {
            form.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    // MARK: - UIViewController Methods
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if let backIcon = navBackIcon {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: backIcon, style: .plain, target: self, action: #selector(goBack))
        }
        
        if #available(iOS 13, *) {
            
            sectionTitleColor = .secondaryLabel
            titleColor = .secondaryLabel
            valueColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                    case
                        .unspecified,
                        .light: return .black
                    case
                        .dark: return .white
                    default: return .white
                }
            }
            if backgroundColor == nil {
                backgroundColor = .systemGroupedBackground
            }
            cellBackgroundColor = .secondarySystemGroupedBackground
            searchTintColor = .label
            
        } else {
            
            if backgroundColor == nil {
                backgroundColor = UIColor(netHex: 0xf5f5f5)
            }
        }
        
        view.backgroundColor = backgroundColor
        form.dataSource = self
        form.delegate = self
        
        if marginsActive {
            view.addSubview(scrollView)
            scrollView.sc_pinEdgesToSuperViewEdges()
            
            let containerView = UIView()
            scrollView.addSubview(containerView)
            containerView.sc_pinEdgesToSuperViewEdges()
            containerView.sc_MatchDimension(.width, toDimension: .width, ofView: scrollView)
            
            containerView.addSubview(form)
            form.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIView.safeArea.bottom, right: 0)
            form.sc_pinEdge(toSuperViewEdge: .top)
            form.sc_pinEdge(toSuperViewEdge: .bottom)
            form.isScrollEnabled = false
            form.showsVerticalScrollIndicator = false
            cntContentLeading = form.sc_pinEdge(toSuperViewEdge: .leading)
            cntContentTrailing = form.sc_pinEdge(toSuperViewEdge: .trailing)
            cntContentHeight = form.sc_setDimension(.height, withValue: 100)
            form.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        } else {
            view.addSubview(form)
            form.sc_pinEdgesToSuperViewEdges()
            form.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: UIView.safeArea.bottom, right: 0)
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if marginsActive {
            cntContentLeading?.constant = UIApplication.shared.orientation.isPortrait ? iPadMargin : iPadMargin*1.8
            cntContentTrailing?.constant = UIApplication.shared.orientation.isPortrait ? -iPadMargin : -(iPadMargin*1.8)
        }
    }
    
    // MARK: - Keyboard Handlers
    
    override open func keyboardDidShow(keyboardInfo: KeyboardInfo) {
        form.contentInset.bottom = keyboardInfo.endFrame.height
    }
    
    override open func keyboardDidHide(keyboardInfo: KeyboardInfo) {
        form.contentInset.bottom = 0
    }
    
    // MARK: - UITableView DataSource & Delegate
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSection = data[section]
        return (dataSection.stackable && !dataSection.stacked) || !dataSection.stackable ? dataSection.rows.count : 0
    }
    
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dataSection = data[indexPath.section]
        let dataRow = dataSection.rows[indexPath.row]
        if dataRow.type == .rowList || dataRow.type == .rowListMulti {
            return (SCFormViewController.cellsMargin*2)+20
        }
        return dataRow.visible ? UITableView.automaticDimension : 0
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let dataSection = data[section]
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 36))
        let title = UILabel(frame: header.frame)
        header.addSubview(title)
        
        title.sc_pinEdge(toSuperViewEdge: .leading, withOffset: 20)
        title.sc_pinEdge(toSuperViewEdge: .trailing, withOffset: 20)
        title.sc_pinEdge(toSuperViewEdge: .bottom, withOffset: 8)
        title.font = sectionTitleFont
        title.textColor = sectionTitleColor
        title.text = dataSection.title?.uppercased()
        
        return header
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let dataSection = data[section]
        return dataSection.title != nil ? sectionHeaderHeight : 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = data[indexPath.section]
        let row = section.rows[indexPath.row]
        
        if row.type == .rowAttachment {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SCAttachmentTableCell.identifier, for: indexPath) as? SCAttachmentTableCell {
                cell.isHidden = !row.visible
                cell.backgroundColor = cellBackgroundColor
                cell.clipsToBounds = true
                cell.lblTitle.textColor = titleColor
                cell.lblTitle.font = cellTitleFont
                cell.lblFileName.textColor = valueColor
                cell.lblFileName.font = cellValueFont
                cell.configure(with: row)
                if tintColor != nil { cell.tintColor = tintColor }
                return cell
            }
        } else if row.type == .rowDefault || row.type == .rowAttachment || row.type == .rowList || row.type == .rowListMulti {
            var cell: UITableViewCell!
            if row.type == .rowDefault {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.identifier)
                cell.detailTextLabel?.numberOfLines = 0
            } else {
                cell = UITableViewCell(style: .value1, reuseIdentifier: UITableViewCell.identifier)
                cell.detailTextLabel?.numberOfLines = 1
            }
            cell.isHidden = !row.visible
            cell.selectionStyle = row.type != .rowDefault ? .default : .none
            cell.backgroundColor = cellBackgroundColor
            cell.clipsToBounds = true
            cell.textLabel?.textColor = titleColor
            cell.textLabel?.font = cellTitleFont
            cell.detailTextLabel?.textColor = valueColor
            cell.detailTextLabel?.font = cellValueFont
            cell.configure(with: row)
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
        } else if row.type == .rowSubtitle {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.identifier)
            cell.isHidden = !row.visible
            cell.selectionStyle = .none
            cell.backgroundColor = cellBackgroundColor
            cell.clipsToBounds = true
            cell.textLabel?.textColor = titleColor
            cell.textLabel?.font = cellTitleFont
            cell.detailTextLabel?.textColor = valueColor
            cell.detailTextLabel?.font = cellValueFont
            cell.configure(with: row)
            if tintColor != nil { cell.tintColor = tintColor }
            return cell
        } else if row.type == .rowTextField || row.type == .rowEmail || row.type == .rowPassword {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SCTextFieldTableCell.identifier, for: indexPath) as? SCTextFieldTableCell {
                cell.isHidden = !row.visible
                cell.selectionStyle = .none
                cell.delegate = self
                cell.backgroundColor = cellBackgroundColor
                cell.accessoryType = .none
                cell.lblTitle.font = cellTitleFont
                cell.lblTitle.textColor = titleColor
                cell.txfValue.placeholder = row.placeholder
                cell.txfValue.isEnabled = editingEnabled
                cell.txfValue.font = cellValueFont
                cell.txfValue.textColor = valueColor
                cell.txfValue.keyboardType = row.type == .rowEmail ? .emailAddress : .default
                cell.txfValue.isSecureTextEntry = row.type == .rowPassword
                cell.txfValue.autocapitalizationType = row.type == .rowEmail || row.type == .rowPassword ? .none : .sentences
                switch (row.valueType) {
                    case .integer: cell.txfValue.keyboardType = .numberPad
                    case .decimal: cell.txfValue.keyboardType = .decimalPad
                    case .email: cell.txfValue.keyboardType = .emailAddress
                    case .url: cell.txfValue.keyboardType = .URL
                    default: cell.txfValue.keyboardType = .default
                }
                cell.configure(with: row)
                if tintColor != nil { cell.tintColor = tintColor }
                return cell
            }
        } else if row.type == .rowTextArea {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: SCTextViewTableCell.identifier, for: indexPath) as? SCTextViewTableCell {
                cell.isHidden = !row.visible
                cell.selectionStyle = .none
                cell.delegate = self
                cell.backgroundColor = cellBackgroundColor
                cell.accessoryType = .none
                cell.lblTitle.font = cellTitleFont
                cell.lblTitle.textColor = titleColor
                cell.txwValue.isEditable = editingEnabled
                cell.txwValue.font = cellValueFont
                cell.txwValue.textColor = valueColor
                switch (row.valueType) {
                    case .integer: cell.txwValue.keyboardType = .numberPad
                    case .decimal: cell.txwValue.keyboardType = .decimalPad
                    case .email: cell.txwValue.keyboardType = .emailAddress
                    case .url: cell.txwValue.keyboardType = .URL
                    default: cell.txwValue.keyboardType = .default
                }
                cell.configure(with: row)
                if tintColor != nil { cell.tintColor = tintColor }
                return cell
            }
        } else if row.type == .rowSwitch {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SCSwitchTableCell.identifier, for: indexPath) as? SCSwitchTableCell {
                cell.isHidden = !row.visible
                cell.selectionStyle = .none
                cell.delegate = self
                cell.backgroundColor = cellBackgroundColor
                cell.accessoryType = .none
                cell.swSwitch.isEnabled = editingEnabled
                cell.lblTitle.textColor = titleColor
                cell.lblTitle.font = cellTitleFont
                cell.configure(with: row)
                if switchColor != nil { cell.swSwitch.onTintColor = switchColor }
                if tintColor != nil { cell.tintColor = tintColor }
                return cell
            }
        } else if row.type == .rowDate {
            if let cell = tableView.dequeueReusableCell(withIdentifier: SCDateTableCell.identifier, for: indexPath) as? SCDateTableCell {
                cell.isHidden = !row.visible
                cell.selectionStyle = .none
                cell.delegate = self
                cell.backgroundColor = cellBackgroundColor
                cell.accessoryType = .none
                cell.lblTitle.textColor = titleColor
                cell.lblTitle.font = cellTitleFont
                if #available(iOS 14, *) {
                    cell.datePicker.tintColor = tintColor
                } else {
                    cell.txfValue.placeholder = row.placeholder
                    cell.txfValue.textColor = valueColor
                    cell.txfValue.font = cellValueFont
                }
                cell.configure(with: row)
                if tintColor != nil { cell.tintColor = tintColor }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let section = data[indexPath.section]
        let row = section.rows[indexPath.row]
        
        if (row.type == .rowList || row.type == .rowListMulti) && editingEnabled {
            
            if let extraData = row.extraData as? [SCDataListItem] {
                
                currentIndexPath = indexPath
                let list = SCDataListViewController(data: extraData, navTitle: row.title, navBackIcon: navBackIcon, selectedValue: row.value as? String)
                list.navigationItem.title = row.title
                list.searchTintColor = searchTintColor
                list.backgroundColor = backgroundColor
                list.titleColor = titleColor
                list.valueColor = valueColor
                list.cellBackgroundColor = cellBackgroundColor
                list.multiSelect = row.type == .rowListMulti
                list.autoDismissOnSelect = autoDismissListsOnSelection
                list.delegate = self
                
                if UIDevice.isIpad {
                    let nav = UINavigationController(rootViewController: list)
                    if #available(iOS 13.0, *) {
                        
                    } else {
                        nav.modalPresentationStyle = .formSheet
                    }
                    present(nav, animated: true, completion: nil)
                } else {
                    navigationController?.pushViewController(list, animated: true)
                }
            }
            
        } else if row.type == .rowAttachment {
            
            let picker = SCFilePicker()
            picker.pickFile(on: self, fileExtensions: row.attachmentExtensions, maxSize: row.attachmentMaxSize ?? maxFileSize) { (fileUrl, message) in
                if fileUrl != nil {
                    self.data[indexPath.section].rows[indexPath.row].attachmentUrl = fileUrl
                }
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    // MARK: - SCTextFieldTableCell Delegate
    
    open func scTextFieldTableCellDidChangeText(cell: SCTextFieldTableCell) {
        if let indexPath = form.indexPath(for: cell) {
            
            data[indexPath.section].rows[indexPath.row].value = cell.txfValue.text
            let item = data[indexPath.section].rows[indexPath.row]
            showLinkedItems(key: item.key, value: cell.txfValue.text)
        }
    }
    
    // MARK: - SCTextViewTableCell Delegate
    
    public func scTextViewTableCellDidChangeText(cell: SCTextViewTableCell) {
        if let indexPath = form.indexPath(for: cell) {
            
            data[indexPath.section].rows[indexPath.row].value = cell.txwValue.text
            let item = data[indexPath.section].rows[indexPath.row]
            showLinkedItems(key: item.key, value: cell.txwValue.text)
        }
    }
    
    // MARK: - SCSwitchTableCell Delegate
    
    open func scSwitchTableCellDidChangeSelection(cell: SCSwitchTableCell) {
        if let indexPath = form.indexPath(for: cell) {
            
            data[indexPath.section].rows[indexPath.row].value = cell.swSwitch.isOn
            let item = data[indexPath.section].rows[indexPath.row]
            showLinkedItems(key: item.key, value: cell.swSwitch.isOn)
        }
    }
    
    // MARK: - SCDateTableCell Delegate
    
    open func scDateTableCellDidChangeDate(cell: SCDateTableCell) {
        if let indexPath = form.indexPath(for: cell) {
            
            data[indexPath.section].rows[indexPath.row].value = cell.datePicker.date
            let item = data[indexPath.section].rows[indexPath.row]
            showLinkedItems(key: item.key, value: cell.datePicker.date)
        }
    }
    
    // MARK: - SCDataListViewController Delegate
    
    open func scDataListViewControllerDidSelectValue(viewController: UIViewController, value: SCDataListItem) {
        data[currentIndexPath.section].rows[currentIndexPath.row].value = value
        form.reloadRows(at: [currentIndexPath], with: .none)
        
        let item = data[currentIndexPath.section].rows[currentIndexPath.row]
        showLinkedItems(key: item.key, value: value)
    }
    
    open func scDataListViewControllerDidSelectValues(viewController: UIViewController, value: [SCDataListItem]) {
        data[currentIndexPath.section].rows[currentIndexPath.row].value = value
        form.reloadRows(at: [currentIndexPath], with: .none)
        
        let item = data[currentIndexPath.section].rows[currentIndexPath.row]
        showLinkedItems(key: item.key, value: value.count > 0)
    }
    
    // MARK: - Other Methods
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showLinkedItems(key: String, value: Any?) {
        var indexPathsToUpdate = [IndexPath]()
        
        for i in 0..<data.count {
            let section = data[i]
            for j in 0..<section.rows.count {
                let row = section.rows[j]
                var show = true
                if row.visibilityBindKey == key {
                    if let visibilityValue = row.visibilityBindValue {
                        show = false
                        if let stringValue = value as? String, let visStringValue = visibilityValue as? String {
                            show = stringValue.compare(visStringValue) == .orderedSame
                        } else if let intValue = value as? Int, let visIntValue = visibilityValue as? Int {
                            show = intValue == visIntValue
                        } else if let boolValue = value as? Bool, let visBoolValue = visibilityValue as? Bool {
                            show = boolValue == visBoolValue
                        }
                        data[i].rows[j].visible = show
                        indexPathsToUpdate.append(IndexPath(row: j, section: i))
                    } else {
                       show = value != nil
                    }
                }
            }
        }
        
        form.reloadRows(at: indexPathsToUpdate, with: .automatic)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "contentSize" && object is UITableView && marginsActive {
            cntContentHeight?.constant = form.contentSize.height + form.contentInset.top
        }
    }
    
    // MARK: - Battery Warning
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
