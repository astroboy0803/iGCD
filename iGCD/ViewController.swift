//
//  ViewController.swift
//  iGCD
//
//  Created by i9400506 on 2020/6/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // sync: 等設定的工作執行完才離開 > 每間店餐點完成後再到另一間店
        // async: 不管工作是否完成，就直接離開 > 打電話叫餐點
        // sync和async會接收待處理的事情(工作) - clousre or workitem
        // 完成工作的定義: 是指程式有每一行都有執行
        // p.s. 執行的程式若有非同步作業(如發送網路請求)，同定義，掃過不等待
        
        // serial: 同時間只會處理一件工作 > 只有一個人
        // concurrent: 同時間會處理很多工作 > 有很多個人
        
        // sync 結果會相同
        //self.serialQueueSync()
        //self.concurrentQueueSync()
        
        // serial: 裡面設定的作業還是依序處理
        //self.serialQueueASync()
        
        // concurrent: 完全無法決定順序
        //self.concurrentQueueASync()
        
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
    
    final private func testDictThreadSafety() {
        var dict = [String: DictElement]()
        
        for idx in 0...10 {
            DispatchQueue.global().async {
                let element = DictElement(serNo: idx)
                dict["Element"] = element
                element.description()
            }
        }
    }
}

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
