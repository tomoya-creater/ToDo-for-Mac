//
//  HistoryViewController.swift
//  ToDo
//
//  Created by tomoya senda on 2025/11/01.
//

import Cocoa
import CoreData

class HistoryViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource{
    @IBOutlet weak var tableView: NSTableView!
    
    // Core Dataの「作業場所」(Context) を取得する準備
    lazy var context: NSManagedObjectContext = {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    // Core Dataから取得したデータを保持する配列
    var todoItems: [TodoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // テーブルビューの管理者を自分自身に設定
        // 「データは私(self)が供給します」「操作も私(self)が担当します」
        tableView.delegate = self
        tableView.dataSource = self
    }
    // --- 💡 画面が表示される「直前」に毎回呼び出される関数 ---
    override func viewWillAppear() {
        super.viewWillAppear()
        
        // 画面が表示されるたびに、データを最新の状態に更新する
        fetchData()
    }
    
    // --- データ取得処理 ---
    func fetchData() {
        // 1. データの取得リクエストを作成 (TodoItemエンティティを対象)
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        
        // (おまけ: 締切日でソート（並び替え）する設定)
        let sortDescriptor = NSSortDescriptor(key: "deadline", ascending: true) // 昇順
        request.sortDescriptors = [sortDescriptor]
        
        // 2. データベースからデータを取得して、配列(todoItems)に入れる
        do {
            todoItems = try context.fetch(request)
            print("データ取得成功: \(todoItems.count)件")
            
            // 3. テーブルビューに「データが更新されたよ！」と伝える
            // 💡 メインスレッドでUIを更新するのがお作法です
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch {
            print("データ取得失敗: \(error)")
        }
    }
    
    
    // --- NSTableViewDataSource のお約束関数 (データ供給) ---
    
    // 1.「行の数はいくつですか？」に答える
    func numberOfRows(in tableView: NSTableView) -> Int {
        return todoItems.count // 取得したデータの個数を返す
    }
        
    
    // --- NSTableViewDelegate のお約束関数 (見た目) ---
    
    // 2.「この行（と列）には何を表示しますか？」に答える
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // 該当する行のデータを取得
        let item = todoItems[row]
        
        // 列の識別子（Identifier）で、左の列か右の列かを判定する
        let identifier = tableColumn?.identifier ?? NSUserInterfaceItemIdentifier(rawValue: "")
        
        if identifier.rawValue == "DeadlineCell" {
            // --- 左側: 締切日セルの場合 ---
            
            // "DeadlineCell" のIDを持つセルビューを取得
            guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DeadlineCell"), owner: nil) as? NSTableCellView else {
                return nil
            }
                
            // 日付(Date型)を「yyyy/MM/dd」形式の文字列(String型)に変換
            if let deadline = item.deadline {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy/MM/dd"
                cell.textField?.stringValue = formatter.string(from: deadline)
            } else {
                cell.textField?.stringValue = "--" // 日付がなければ
            }
            return cell
            
        } else if identifier.rawValue == "TaskNameCell" {
            // --- 右側: タスク名セルの場合 ---
            
            // "TaskNameCell" のIDを持つセルビューを取得
            guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TaskNameCell"), owner: nil) as? NSTableCellView else {
                return nil
            }
            
            // タスク名を設定
            cell.textField?.stringValue = item.taskName ?? "（名前なし）"
            return cell
                
        }
            
        return nil // どちらでもない場合
    }
    // --- テーブルがダブルクリックされた時に呼ばれるアクション ---
    @IBAction func tableViewDoubleClicked(_ sender: NSTableView) {
            
        let clickedRow = sender.clickedRow
        guard clickedRow >= 0 else { return }
            
        let itemToShow = todoItems[clickedRow]
            
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: "DetailWindowController") as? NSWindowController else {
            print("エラー: DetailWindowController が見つかりません")
            return
        }
            
        // 💡 修正点: 先にウィンドウをロードさせます
        _ = windowController.window

        // 5. ウィンドウの中身 (DetailViewController) を取得
        if let detailVC = windowController.contentViewController as? DetailViewController {
                
            // 6. 取得したVCに、アイテムを渡してUIを設定させる
            // (viewDidLoadを待たずに、今すぐ設定します)
            detailVC.configure(with: itemToShow) // ⬅️ ここを変更
                
        } else {
            print("エラー: DetailViewController が見つかりませんでした。")
            print("（StoryboardでWindow ControllerとView Controllerの'content View Controller'接続が切れていないか確認してください）")
        }
            
        // 7. ウィンドウを表示する
        windowController.showWindow(nil)
    }
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // 1. テーブルビューで選択されている行番号を取得
        let selectedRow = tableView.selectedRow

        // 2. 誰も選択されていなければ（-1）、何もしない
        guard selectedRow >= 0 else {
            print("削除する行が選択されていません")
            return
        }

        // 3. 削除するべきTodoItemを取得
        let itemToDelete = todoItems[selectedRow]

        // 4. Core Dataのコンテキストから、そのアイテムを削除
        context.delete(itemToDelete)

        // 5. 変更をデータベースに保存 (セーブ)
        do {
            try context.save()
            print("削除成功")

            // 6. データを再読み込みして、リストを更新
            fetchData()

        } catch {
            print("削除失敗: \(error)")
        }
    }
    @IBAction func advanceOptionButtonTapped(_ sender: Any) {
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 else{
            print("選択されていません")
            return
        }
        let itemToAdvance = todoItems[selectedRow]
                
        // --- ↓↓ この下のコードを tableViewDoubleClicked からコピー＆ペースト ↓↓ ---
                
        // 1. Storyboardから詳細ウィンドウを生成 (ID: DetailWindowController)
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: "DetailWindowController") as? NSWindowController else {
            print("エラー: DetailWindowController が見つかりません")
            return
        }
                
        // 2. ウィンドウを強制的にロード
        _ = windowController.window

        // 3. ウィンドウの中身 (DetailViewController) を取得
        if let detailVC = windowController.contentViewController as? DetailViewController {
                    
            // 4. 取得したVCに、選択されたアイテム(itemToAdvance)を渡す
            detailVC.configure(with: itemToAdvance) // ⬅️ ここを itemToAdvance にする
                    
        } else {
            print("エラー: DetailViewController が見つかりませんでした。")
        }
                
        // 5. ウィンドウを表示する
        windowController.showWindow(nil)
    }
    // 「編集」ボタンが押された時のアクション
    @IBAction func editButtonTapped(_ sender: Any) {
            
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 else {
            print("編集する行が選択されていません")
            return
        }
        let itemToEdit = todoItems[selectedRow]
            
        // 1. Storyboardから「編集ウィンドウ」をIDで探す
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: "EditWindowController") as? NSWindowController else {
            print("エラー: EditWindowController が見つかりません")
            return
        }
            
        // 2. ウィンドウをロード
        _ = windowController.window

        // 3. ウィンドウの中身（＝EditTabViewController）を取得
        if let editTabVC = windowController.contentViewController as? EditTabViewController { // ⬅️ ここを修正
                
            // 4. TabViewControllerに「編集するアイテム」と「コンテキスト」を渡す
            editTabVC.itemToEdit = itemToEdit
            editTabVC.context = self.context // 自分のコンテキストを渡す
            editTabVC.passDataToChildren() // 子タブにデータを反映させる
                
        } else {
            print("エラー: EditTabViewController が見つかりません") // ⬅️ ここを修正
        }
            
        // 5. 編集ウィンドウを表示
        windowController.showWindow(nil)
    }
}
