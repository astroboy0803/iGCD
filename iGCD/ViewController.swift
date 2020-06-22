//
//  ViewController.swift
//  iGCD
//
//  Created by i9400506 on 2020/6/19.
//

import UIKit

class ViewController: UIViewController {

    private let _serialQueue = DispatchQueue(label: "tw.com.BruceHuang.iGCD.serial")
    
    private let _concurrentQueue = DispatchQueue(label: "tw.com.BruceHuang.iGCD.concurrent", attributes: .concurrent)
    
    private var _dict = [String: DictElement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.testGCD()
        self.testOperationQueue()
    }
}

// MARK: - opration queue
extension ViewController {
    final private func testOperationQueue() {
        // Operations are an object-oriented way to encapsulate work that you want to perform asynchronously. Operations are designed to be used either in conjunction with an operation queue or by themselves
        // 與GCD差異:
        // 1 OperationQueue不遵循FIFO
        // 2 OperationQueue僅能以concurrent運作 - 雖然沒有serial模式，但還是可以設定task間的依賴達到serial效果
        // 3 Operation的task以sync方式執行 - 想要有非同步效果就必須在Operation加到OperationQueue
        // 4 易於取消或中斷執行的作業
        // 5 Operation queues是OperationQueue的instance, OperationQueue被封裝在Operation
        
        // OperationQueue接受到的task必須為Operation(抽象類別), Cocoa/Cocoa Touch Framework已實作兩個Operation子類別
        // 1 BlockOperation - 可以建立一個或多個block, 當全部Black的都執行完才視為任務完成
        // 2 InvocationOperation - 可用於執行指定對象的選擇器（Selector）, swift無此類別
        
        let operationQueue = OperationQueue()
        // 設定concurrent數量
        //operationQueue.maxConcurrentOperationCount = 2
        for idx in 0...10 {
            operationQueue.addOperation {
                print("idx = \(idx)")
            }
        }
        
        // blocking
        operationQueue.waitUntilAllOperationsAreFinished()
        print("end...")
        
        // 執行完成後task就被移除 - 符合queue定義
        operationQueue.waitUntilAllOperationsAreFinished()
        print("end...")
        
        for idx in 0...10 {
            let sTask = BlockOperation {
                print("start idx = \(idx)")
            }
            let eTask = BlockOperation {
                print("end idx = \(idx)")
            }
            // 加入相依性
            eTask.addDependency(sTask)
            operationQueue.addOperation(sTask)
            operationQueue.addOperation(eTask)
        }
        operationQueue.waitUntilAllOperationsAreFinished()
        print("end...")
    }
}

// MARK: - GCD
extension ViewController {
    final private func testGCD() {
        // GCD is a low-level API (c語言)
        // Note that GCD decides how much parallelism it requires based on the system and available system resources. It’s important to note that parallelism requires concurrency, but concurrency does not guarantee parallelism
        
        // Dispatch queues are thread-safe which means that you can access them from multiple threads simultaneously
        
        // queue的執行順位:
        // high > default > low > background
        // 程式中透過quality of service(qos)決定執行順位
        // userInteractive > userInitiated > default > utility > background > unspecified
        // 對應到的queue與priorities
        // userInteractive(main)
        // userInitiated(global.high)
        // default(global.default)
        // utility(global.low)
        // background(global.background)
        // unspecified(global.background)
        
        // sync: A synchronous function returns control to the caller after the task completes(block) -> 等設定的工作執行完才離開 -> 每間店餐點完成後再到另一間店
        // async: returns immediately, ordering the task to start but not waiting for it to complete(not block) -> 不管工作是否完成，就直接離開 -> 打電話叫餐點
        // sync和async會接收待處理的事情(工作) - clousre(blocks of code) or workitem
        // 完成工作的定義: 是指程式有每一行都有執行
        // p.s. 執行的程式若有非同步作業(如發送網路請求)，同定義，掃過不等待
        
        // queue處理工作方式:
        // serial: 同時間只會處理一件工作 -> 只有一個人 -> 自己取餐
        // concurrent: 同時間會處理很多工作 -> 有很多個人 -> 讓外送員送餐
        
        // iOS queue種類:
        // 1 main - serial
        // 2 global - concurrent
        // 3 custom - serial or concurrent
        
        // sync 結果會相同
        //self.serialQueueSync()
        //self.concurrentQueueSync()
        
        // serial: async內設定的作業還是依序處理, 但與沒加在在async的工作會交互進行
        //self.serialQueueASync()
        
        // concurrent: 完全無法決定順序
        //self.concurrentQueueASync()
        
        // serial sync+async交叉應用
        //self.serialQueueComplex()
        
        
        // Thread safe code can be safely called from multiple threads or concurrent tasks without causing any problems such as data corruption or app crashes
        // thread safety cases to consider
        // 1 initialization -> initializes static variables when they are first accessed, and it guarantees initialization is atomic
        // 2 during reads and writes to the instance -> Declare the variable with the var keyword however, and it becomes mutable and not thread-safe -> collection types like Array and Dictionary are not thread-safe when declared mutable -> it’s not safe to let one thread modify the array while another is reading it
        // GCD provides an elegant solution of creating a read/write lock using dispatch barriers
        // 1 serial queue -> block -> resolve
        // 2 concurrency queue -> not block -> unsafe -> set flags(DispatchWorkItemFlags) to indicate that it should be the only item executed on the specified queue for that particular time
        // all items submitted to the queue prior to the dispatch barrier must complete before the DispatchWorkItem will execute.
        self.testDictThreadSafety()
    }
        
    // MARK: serialQueue + sync = 完全依序處理
    final private func serialQueueSync() {
        let serialQueue: DispatchQueue = DispatchQueue(label: "serialQueue")

        // 驗證同步執行的結果
        serialQueue.sync {
            for i in 0 ... 9 {
                print("i: \(i)")
            }
        }
        
        serialQueue.sync {
            for i in 10 ... 19 {
                print("i: \(i)")
            }
        }
        
        serialQueue.sync {
            for i in 20 ... 29 {
                print("i: \(i)")
            }
        }
        
        for j in 100 ... 109 {
            print("j: \(j)")
        }
    }
    
    final private func serialQueueASync() {
        let serialQueue: DispatchQueue = DispatchQueue(label: "serialQueue")

        // 驗證同步執行的結果
        serialQueue.async {
            for i in 0 ... 9 {
                print("i: \(i)")
            }
        }
        
        serialQueue.async {
            for i in 10 ... 19 {
                print("i: \(i)")
            }
        }
        
        serialQueue.async {
            for i in 20 ... 29 {
                print("i: \(i)")
            }
        }
        
        for j in 100 ... 109 {
            print("j: \(j)")
        }
    }
    
    final private func concurrentQueueSync() {
        let concurrentQueue: DispatchQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)
        // 驗證同步執行的結果
        concurrentQueue.sync {
            for i in 0 ... 9 {
                print("i: \(i)")
            }
        }
        
        concurrentQueue.sync {
            for i in 10 ... 19 {
                print("i: \(i)")
            }
        }
        
        concurrentQueue.sync {
            for i in 20 ... 29 {
                print("i: \(i)")
            }
        }
        
        for j in 100 ... 109 {
            print("j: \(j)")
        }
    }
    
    final private func concurrentQueueASync() {
        let concurrentQueue: DispatchQueue = DispatchQueue(label: "concurrentQueue", attributes: .concurrent)

        // 驗證同步執行的結果
        concurrentQueue.async {
            for i in 0 ... 9 {
                print("i: \(i)")
            }
        }
        
        concurrentQueue.async {
            for i in 10 ... 19 {
                print("i: \(i)")
            }
        }
        
        concurrentQueue.async {
            for i in 20 ... 29 {
                print("i: \(i)")
            }
        }
        
        for j in 100 ... 109 {
            print("j: \(j)")
        }
    }
    
    final private func serialQueueComplex() {
        let serialQueue: DispatchQueue = DispatchQueue(label: "serialQueue")
        
        // 驗證同步執行的結果
        serialQueue.sync {
            for i in 0 ... 9 {
                print("i: \(i)")
            }
        }
        
        serialQueue.async {
            for i in 10 ... 19 {
                print("i: \(i)")
                sleep(1)
            }
        }
        
        serialQueue.async {
            for i in 20 ... 29 {
                print("i: \(i)")
            }
        }
        
        for j in 100 ... 109 {
            print("j: \(j)")
        }
        
//        // 驗證同步執行的結果
//        serialQueue.async {
//            for i in 0 ... 9 {
//                print("i: \(i)")
//                //sleep(1)
//            }
//        }
//
//        serialQueue.sync {
//            for i in 10 ... 19 {
//                print("i: \(i)")
//            }
//        }
//
//        serialQueue.async {
//            for i in 20 ... 29 {
//                print("i: \(i)")
//            }
//        }
//
//        for j in 100 ... 109 {
//            print("j: \(j)")
//        }
    }
    
    final private func testDictThreadSafety() {
//        // unsafe thread
//        for idx in 0...100 {
//            DispatchQueue.global().async {
//                let element = DictElement(serNo: idx)
//                self._dict["Element"] = element
//                element.description()
//            }
//        }
//
//        // fix by serial queue
//        for idx in 0...100 {
//            self._serialQueue.async {
//                let element = DictElement(serNo: idx)
//                self._dict["Element"] = element
//                element.description()
//            }
//        }

//        // unsafe thread - concurrent queue(same global queue)
//        for idx in 0...100 {
//            self._concurrentQueue.async {
//                let element = DictElement(serNo: idx)
//                self._dict["Element"] = element
//                element.description()
//            }
//        }
        
        // fix by concurrent queue
        for idx in 0...100 {
            self._concurrentQueue.async(flags: .barrier) {
                let element = DictElement(serNo: idx)
                self._dict["Element"] = element
                element.description()
            }
        }
    }
}

// MARK: -  DictElement
class DictElement {
    private var serNo: Int
    private var eName: String
    init(serNo: Int) {
        self.serNo = serNo
        self.eName = UUID().uuidString
    }
    func description() {
        print("description >>>> \(self.serNo) -> \(self.eName)")
    }
}
