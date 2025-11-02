//
//  DetailViewController.swift
//  ToDo
//
//  Created by tomoya senda on 2025/11/01.
//

import Cocoa
import CoreData

class DetailViewController: NSViewController {

    @IBOutlet weak var taskNameLabel: NSTextField!
    @IBOutlet weak var deadlineLabel: NSTextField!
    @IBOutlet var detailsTextView: NSTextView!
    
    // この変数は残しますが、viewDidLoadでは使いません
    var selectedItem: TodoItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        // viewDidLoadでは、UIの準備だけにしておきます。
        // データの設定は configure(with:) 関数から行います。
        detailsTextView.isEditable = false // 詳細を表示するだけにする
    }
    
    // ⬇️ この関数を新しく追加します ⬇️
    // 外部からTodoItemを受け取り、UIに反映させるための専用関数
    public func configure(with item: TodoItem) {
        
        // 1. タスク名をセット
        self.title = item.taskName // ウィンドウのタイトルにも設定
        
        // 💡 UIがロードされる前に呼ばれる可能性があるので、
        // 💡 IBOutletがnilでないか確認しながらセットします
        taskNameLabel?.stringValue = item.taskName ?? "（名前なし）"
        
        // 2. 締切日をセット
        if let deadline = item.deadline {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            deadlineLabel?.stringValue = "締切: " + formatter.string(from: deadline)
        } else {
            deadlineLabel?.stringValue = "（締切なし）"
        }
        
        // 3. 詳細をセット
        detailsTextView?.string = item.taskDetails ?? "（詳細なし）"
    }
}
