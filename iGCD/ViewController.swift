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
        self.testGCD()
        //self.testOperationQueue()
    }
}

// MARK: - opration queue
extension ViewController {
    final private func testOperationQueue() {
        // 設定concurrent數量 - 最大值還是取決於設備與系統
        let operationQueue = OperationQueue()
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
        // sync 結果會相同
        self.serialQueueSync()
        //self.concurrentQueueSync()
        
        // serial: async內設定的作業還是依序處理, 但與沒加在在async的工作會交互進行
        //self.serialQueueASync()
        
        // concurrent: 完全無法決定順序
        //self.concurrentQueueASync()
        
        // serial sync+async交叉應用
        //self.serialQueueComplex()
        
        
        // GCD provides an elegant solution of creating a read/write lock using dispatch barriers
        // 1 serial queue -> block -> resolve
        // 2 concurrency queue -> not block -> unsafe -> set flags(DispatchWorkItemFlags) to indicate that it should be the only item executed on the specified queue for that particular time
        // all items submitted to the queue prior to the dispatch barrier must complete before the DispatchWorkItem will execute.
        //self.testDictThreadSafety()
    }
    
    // MARK: serialQueue + sync = 完全依序處理
    final private func serialQueueSync() {
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
        
        // 驗證同步執行的結果 0-9
        serialQueue.sync {
            for i in 0 ... 9 {
                print("i: \(i)")
            }
        }
        
        // 10-19
        serialQueue.async {
            print("start...")
            for i in 10 ... 19 {
                print("i: \(i)")
            }
        }
        
        // 20-29
        serialQueue.sync {
            for i in 20 ... 29 {
                print("i: \(i)")
            }
        }
        
        // 30-39
        serialQueue.async {
            for i in 30 ... 39 {
                print("i: \(i)")
            }
        }
        
        // 40-49
        serialQueue.async {
            for i in 40 ... 49 {
                print("i: \(i)")
            }
        }
        
        // 50-59
        serialQueue.sync {
            for i in 50 ... 59 {
                print("i: \(i)")
            }
        }
        
        // 60-69
        serialQueue.async {
            for i in 60 ... 69 {
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
