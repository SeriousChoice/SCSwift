//
//  ViewController.swift
//  SCSwiftExample
//
//  Created by Nicola Innocenti on 08/01/2022.
//  Copyright © 2022 Nicola Innocenti. All rights reserved.
//

import UIKit
import SCSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var btnImagePicker: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Left", style: .plain, target: self, action: #selector(self.didTapLeftButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Right", style: .plain, target: self, action: #selector(self.didTapRightButton))
        
        btnImagePicker.observe(event: .touchUpInside) {
            SCImagePicker.shared.pickWithActionSheet(in: self, mediaType: .photo, fileExtension: .png, maxSize: nil, editing: false, iPadStartFrame: nil, completionBlock: { (image, videoUrl, fileName) in
                print("Image: \(image != nil)\nVideo: \(videoUrl != nil)")
            }, errorBlock: nil)
        }
    }

	@objc func didTapLeftButton() {
        self.openLeftDrawerView()
    }
    
   @objc func didTapRightButton() {
        self.openRightDrawerView()
    }
    
    @IBAction func didTapMediaPlayerButton(_ sender: Any) {
        
		let image1 = SCMedia(id: nil, title: nil, description: nil, remoteUrl: URL(string: "https://foto.sportal.it/2017-44/ludovica-pagani_1106643Photogallery.jpg"), localUrl: nil, type: .image, fileExtension: .jpg)
		let image2 = SCMedia(id: nil, title: nil, description: nil, remoteUrl: URL(string: "https://images2.corriereobjects.it/methode_image/2017/10/21/Sport/Foto%20Gallery/21317799_1682669915084905_5303942900951660357_n.jpg"), localUrl: nil, type: .image, fileExtension: .jpg)
		let video1 = SCMedia(id: nil, title: nil, description: nil, remoteUrl: Bundle.main.url(forResource: "solo_video", withExtension: "mp4"), localUrl: nil, type: .video, fileExtension: .mp4)
        
        let viewController = SCMediaPlayerViewController(medias: [video1, image1, image2], selectedIndex: nil)
        self.present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func didTapHudButton(_ sender: Any) {
        
        let hud = SCHud(theme: .dark, style: .linearProgress)
        hud.textLabel?.text = "Ciao sono una label"
        hud.enableShadow(enable: true)
        hud.setProgressColors(emptyColor: UIColor(netHex: 0xdddddd), filledColor: UIColor(netHex: 0x00ba0e))
        //hud.setShadow(color: .red, offset: .zero, radius: 10, opacity: 0.5)
        hud.show(in: navigationController!.view, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            hud.set(style: .indeterminate)
            hud.set(buttons: [
                SCHudButton(title: "Button 1", highlighted: false, action: {
                    print("Tapped Button 1")
                }),
                SCHudButton(title: "Button 2", highlighted: false, action: {
                    print("Tapped Button 2")
                })
            ])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            hud.addButtons(buttons: [
                SCHudButton(title: "Button 3", highlighted: false, action: {
                    print("Tapped Button 3")
                }),
                SCHudButton(title: "Button 4", highlighted: true, action: {
                    print("Tapped Button 4")
                })
            ])
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+6) {
            hud.hide(animated: true)
        }
    }
    
    @IBAction func didTapFormButton(_ sender: Any) {
        
        let viewController = SCFormViewController()
        viewController.tintColor = .red
        
        viewController.data = [
            SCFormSection(id: nil, title: "Standard", subtitle: nil, value: nil, rows: [
                SCFormRow(default: "standard_1", title: "Title 1-1", value: "Value 1-1", visibilityBindKey: "list_2"),
                SCFormRow(default: "standard_2", title: "Title 1-2", value: "Value 1-2", visibilityBindKey: nil)
            ]),
            SCFormSection(id: nil, title: "TextField", subtitle: nil, value: nil, rows: [
                SCFormRow(textField: "textfield_1", title: "Title 2-1", placeholder: nil, value: nil, visibilityBindKey: nil),
                SCFormRow(textField: "textfield_2", title: "Title 2-2", placeholder: nil, value: nil, visibilityBindKey: nil)
            ]),
            SCFormSection(id: nil, title: "TextArea", subtitle: nil, value: nil, rows: [
                SCFormRow(textArea: "textarea_1", title: "Title 3-1", placeholder: nil, value: nil, visibilityBindKey: nil),
                SCFormRow(textArea: "textarea_2", title: "Title 3-2", placeholder: nil, value: nil, visibilityBindKey: nil)
            ]),
            SCFormSection(id: nil, title: "Subtitle", subtitle: nil, value: nil, rows: [
                SCFormRow(subtitle: "subtitle_1", title: "Title 4-1", subtitle: "Subtitle 3-1", visibilityBindKey: "textfield_1"),
                SCFormRow(subtitle: "subtitle_2", title: "Title 4-2", subtitle: "Subtitle 3-2", visibilityBindKey: nil)
            ]),
            SCFormSection(id: nil, title: "Switch", subtitle: nil, value: nil, rows: [
                SCFormRow(switch: "switch_1", title: "Title 5-1", value: false, visibilityBindKey: nil),
                SCFormRow(switch: "switch_2", title: "Titleeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee 5-2", value: false, visibilityBindKey: nil)
            ]),
            SCFormSection(id: nil, title: "Date", subtitle: nil, value: nil, rows: [
                SCFormRow(date: "date_1", title: "Title 6-1", placeholder: nil, dateFormat: "dd/MM/YYYY", value: nil, visibilityBindKey: nil),
                SCFormRow(date: "date_2", title: "Title 6-2", placeholder: nil, dateFormat: "HH:mm", value: nil, visibilityBindKey: "switch_1")
            ]),
            SCFormSection(id: nil, title: "List", subtitle: nil, value: nil, rows: [
                SCFormRow(list: "list_1", title: "Title 7-1", value: nil, extraData: [
                    SCDataListItem(key: nil, title: "A", subtitle: nil, selected: false),
                    SCDataListItem(key: nil, title: "B", subtitle: nil, selected: false),
                    SCDataListItem(key: nil, title: "C", subtitle: nil, selected: false)
                ], visibilityBindKey: nil),
                SCFormRow(listMulti: "list_2", title: "Title 7-2", value: nil, extraData: [
                    SCDataListItem(key: nil, title: "1", subtitle: nil, selected: false),
                    SCDataListItem(key: nil, title: "2", subtitle: nil, selected: false),
                    SCDataListItem(key: nil, title: "3", subtitle: nil, selected: false)
                ], visibilityBindKey: nil)
            ]),
            SCFormSection(id: nil, title: "Attachment", subtitle: nil, value: nil, rows: [
                SCFormRow(attachment: "attachment_1", title: "Title 7-1", value: nil, attachmentUrl: nil, maxSize: nil, visibilityBindKey: nil),
                SCFormRow(attachment: "attachment_2", title: "Title 7-2", value: nil, attachmentUrl: nil, maxSize: nil, visibilityBindKey: nil)
            ])
        ]
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func didTapChatButton(_ sender: Any) {
        
        let chat = SCChatViewController()
        chat.playButtonImage = "ico_play.png".image
        navigationController?.pushViewController(chat, animated: true)
    }
    
    @IBAction func didTapBottomMenu(_ sender: Any) {
        
        let menu = SCBottomMenu(data: [
            SCBottomMenuSection(key: "section1", title: "Section 1", items: [
                SCBottomMenuItem(key: "item1", title: "Item 1", image: nil, action: {
                    print("Pressed Item 1")
                }),
                SCBottomMenuItem(key: "item2", title: "Item 2", image: nil, action: {
                    print("Pressed Item 2")
                }),
                SCBottomMenuItem(key: "item3", title: "Item 3", image: nil, action: {
                    print("Pressed Item 3")
                })
            ]),
            SCBottomMenuSection(key: "section2", title: "Section 2", items: [
                SCBottomMenuItem(key: "item4", title: "Item 4", image: nil, action: {
                    print("Pressed Item 4")
                }),
                SCBottomMenuItem(key: "item5", title: "Item 5", image: nil, action: {
                    print("Pressed Item 5")
                })
            ])
        ])
        menu.transitioningDelegate = self
        present(menu, animated: true, completion: nil)
    }
    
    @IBAction func didTapFilePickerButton(_ sender: Any) {
        
        let picker = SCFilePicker()
        picker.pickFile(on: self, fileExtensions: [.png, .jpg], maxSize: nil) { (fileUrl, message) in

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
