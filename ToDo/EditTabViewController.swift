//
//  EditTabViewController.swift
//  ToDo
//
//  Created by SendaTomoya on 2025/11/04.
//

import Cocoa
import CoreData

// 編集ウィンドウ専用のタブコントローラー
class EditTabViewController: NSTabViewController {

    // 外部から「編集するアイテム」を受け取るための変数
    var itemToEdit: TodoItem?
    
    // Core Dataコンテキストも受け取る
    var context: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 起動時に、子タブ（「編集」と「オプション」）にデータを渡す
        passDataToChildren()
    }
    
    // この関数が、受け取ったデータを各タブに配る
    func passDataToChildren() {
        guard let item = itemToEdit, let ctx = context else { return }

        // すべての子タブをループ
        for childVC in self.children {
            
            // もし「編集」タブなら (EditTaskViewController)
            if let editVC = childVC as? EditTaskViewController {
                editVC.itemToEdit = item
                editVC.context = ctx
            }
            
            // もし「オプション」タブなら (EditOptionsViewController)
            if let optionsVC = childVC as? EditOptionsViewController {
                optionsVC.itemToEdit = item
                optionsVC.context = ctx
            }
        }
    }
}
