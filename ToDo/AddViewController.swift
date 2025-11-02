//
//  AddViewController.swift
//  ToDo
//
//  Created by tomoya senda on 2025/11/01.
//

import Cocoa
import CoreData

class AddViewController: NSViewController {
    @IBOutlet var taskDetailsView: NSTextView!
    @IBOutlet weak var taskNameField: NSTextField!
    @IBOutlet weak var datePicker: NSDatePicker!
    
    // Core Dataの「作業場所」(ManagedObjectContext) を取得する準備
    // (AppDelegate.swift にある persistentContainer から context を取り出す)
    lazy var context: NSManagedObjectContext = {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        print("--- viewDidLoadが呼ばれました ---")
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        // 1. UIからデータを取得
        let taskName = taskNameField.stringValue
        let deadline = datePicker.dateValue
        let taskDetails = taskDetailsView.string
        
        // 2. タスク名が空っぽだったら、何もせず処理を終了
        if taskName.isEmpty {
            print("タスク名が入力されていません")
            // (アラートを出すと親切だが、今は省略)
            return
        }
        
        // 3. Core Dataに保存する新しい「TodoItem」オブジェクトを作成
        // (さきほど .xcdatamodeld で定義した TodoItem です)
        let newTask = TodoItem(context: context)
        newTask.taskName = taskName
        newTask.deadline = deadline
        newTask.taskDetails = taskDetails // 修正された taskDetails を保存
        
        // 4. 変更をデータベースに保存 (セーブ)
        do {
            try context.save()
            print("保存成功！")
            
            // 5. 保存が成功したら、入力欄をクリアする
            taskNameField.stringValue = ""
            datePicker.dateValue = Date() // 日付を現在日時にリセット
            taskDetailsView.string = ""
        } catch {
            // 5b. 保存に失敗した場合 (エラー処理)
            print("保存失敗: \(error)")
            // (実際にはユーザーにエラーを通知する)
        }
    }
}
