//
//  OperationQueueViewController.swift
//  MultipleThreadDemo
//
//  Created by roni on 2018/1/22.
//  Copyright © 2018年 roni. All rights reserved.
//

import UIKit

class OperationQueueViewController: UIViewController {
    
    /**
     * ## Operation
     * 基于 GCD 之上的更高一层的封装
     * 需要配合 OperationQueue 来实现多线程
    */
    /**
     * ## 实现步骤
     * 创建任务, 先将要执行的操作封装到 Operation 对象中
     * 创建队列 OperationQueue
     * 将任务加入到队列中
     */

    /**
     * ## Operation 是个抽象类, 实际运用中需要使用它的子类, 有三种方式
     * 1. 使用子类 NSInvocationOperation -- 貌似 swift 中没有实现
     * 2. 使用子类 BlockOperation
     * 3. 自定义继承自 Operation 的子类,通过实现内部的响应方法来封装任务
     */



    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       // dependencyOp()
        
        customOp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    func invocationOp() {
        
    }
    
    func blockOp() {
        let blockOp = BlockOperation {
            print("img")
        }
        blockOp.completionBlock = {
            print("完成")
        }
        let queue = OperationQueue()
        queue.addOperation(blockOp)
        
       // OperationQueue.main
        
        // OperationQueue 分为 主队列和其他队列
        queue.maxConcurrentOperationCount = 3// 默认-1, 表示并行, = 1 时表示串行, > 1 表示并行,由于系统资源有限, 值过大系统会自动调节
        queue.cancelAllOperations() // 取消所有未开始的任务
        
        blockOp.cancel() // 取消这个操作
        
       let b = queue.isSuspended // 队列是否挂起
    
        
    }

    func customOp() {
       let blockOp01 = customOperation()
        blockOp01.compeltedBlock = { des in
            print(des)
        }
        let blockOp02 = BlockOperation {
            print("终于特么轮到我custom")
        }
        
        blockOp02.addDependency(blockOp01) // 2 依赖于 1
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.addOperation(blockOp01)
        queue.addOperation(blockOp02)
    }
    
    
    func dependencyOp() {
        let blockOp01 = BlockOperation { // 里面不能执行异步的网络请求---并不会等待网络请求结束,因为网络请求已经进入了新的队列
//            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
//                print("等2s")
//            })
            DispatchQueue.global().async {
                print("等2s")
            }
        }
        
        let blockOp02 = BlockOperation {
            print("终于特么轮到我了")
        }
        
        blockOp02.addDependency(blockOp01) // 2 依赖于 1
        
        let queue = OperationQueue()
        queue.addOperation(blockOp01)
        queue.addOperation(blockOp02)
        
    }
}

class customOperation: Operation {
    
    var isExcuting: Bool
    
    var compeltedBlock: ((String)->())?  // 回调
    
    override init() {
        isExcuting = false
        super.init()
    }
    
    override func main() {
        
        print("开始执行任务")
        // 具体下载任务放这里
        DispatchQueue.global().async {
            sleep(2)
            self.compeltedBlock?("任务完成")
        }
    }
    override var isExecuting: Bool {
        return self.isExecuting
    }
}
