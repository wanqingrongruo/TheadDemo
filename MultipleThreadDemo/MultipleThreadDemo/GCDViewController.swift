//
//  GCDViewController.swift
//  MultipleThreadDemo
//
//  Created by roni on 2018/1/22.
//  Copyright © 2018年 roni. All rights reserved.
//

import UIKit

class GCDViewController: UIViewController {

    /**
     * ## GCD grand central dispatch
     * 旨在替代 Thread 等线程技术
     * 充分利用设备的多核
     * C -- 经常使用
     */
    /**
     * ## GCD 特点
     * GCD会自动管理线程的生命周期(创建线程,调到任务,销毁线程等)
     * 程序员只需要告诉 GCD想要如何执行什么任务,不需要编写任何线程管理代码
     * GCD 会自动利用更多的 CPU 内核
     */

    // GCD总结: 将任务(block)添加到队列(自己创建或使用全局并发队列)并行指定任务执行的方式(sync/async)

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 串行-并行队列
        let serialQueue = DispatchQueue(label: "com.SerialQueue")
        let concurrentQueue = DispatchQueue(label: "com.concurrentQueue", qos: .default, attributes: .concurrent)
        
        // 主队列 - 全局的并发队列
        let mainQueue = DispatchQueue.main
        let globalQueue = DispatchQueue.global()
        
//        // 同步不创建线程, 异步创建线程
//        serialQueue.sync {
//            print("串行同步")
//        }
//        serialQueue.async {
//            print("串行异步")
//        }
//        concurrentQueue.sync {
//            print("并行同步")
//        }
//        concurrentQueue.async {
//            print("并行异步")
//        }
//
//        concurrentQueue.asyncAfter(deadline: DispatchTime.now() + 2) {
//            print("延迟2s")
//        }

        dispatchBarrier()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // 栅栏方法
    // 栅栏函数不能使用全局并发队列，会丧失拦截功能
    func dispatchBarrier() {
         let concurrentQueue = DispatchQueue(label: "com.concurrentQueue02", qos: .default, attributes: .concurrent)
        
        concurrentQueue.async {  // 里面不能执行异步的网络请求---并不会等待网络请求结束,因为网络请求已经进入了新的队列
            for i in 1...3 {
                print("并发异步1 : \(i)")
            }
        }
        concurrentQueue.async {
            for i in 1...3 {
                print("并发异步2 : \(i)")
            }
        }
        
        // 拦住这里,,在 1+2 执行完之后再执行 3+4
        let workItem = DispatchWorkItem(qos: .default, flags: .barrier) {
             print("barrier-----\(Thread.current)")

            concurrentQueue.asyncAfter(deadline: .now() + 2) {
                print("==========")
            }
        }
        concurrentQueue.async(execute: workItem)
        
        concurrentQueue.async {
            for i in 1...3 {
                print("并发异步3 : \(i)")
            }
        }
        
        concurrentQueue.async {
            for i in 1...3 {
                print("并发异步4 : \(i)")
            }
        }
    }
    
    func apply() {
    
    }
    
    func grouptest() {
        /**
         * ## group 特点
         * 1. 所有任务会并发执行
         * 2. 所有的异步函数都添加到队列中,然后放进 group 中进行监听
         * group.notify 监听完成
         */

        let group = DispatchGroup()
        
        for i in 1...3 {
            let queue = DispatchQueue(label: "group\(i)", qos: .default, attributes: .concurrent)
            group.enter()
            queue.async(group: group, execute: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                    print("等2s")
                    group.leave()
                })
            })
        }
        
        // 限时结束
//       let result = group.wait(timeout: DispatchTime.now() + 60)
//        switch result {
//        case .success:
//            print("成功")
//        case .timedOut:
//            print("超时")
//        }
        
        group.notify(queue: .main) {
            print("成功")
        }
    }

    // 信号量 - 用于控制资源被多次访问的情况,保证线程安全的统计数量
    func semaphore() {
        let semaphore = DispatchSemaphore(value: 2)
        
        let queue01 = DispatchQueue(label: "ninini01", qos: .default, attributes: .concurrent)
         semaphore.wait()
        queue01.async {
            print("我是第一个")
            sleep(1)
            print("我走了")
            semaphore.signal()
        }
        semaphore.wait()
        queue01.async {
            print("我是第二个")
            sleep(2)
            print("我走了")
            semaphore.signal()
        }
        semaphore.wait()
        queue01.async {
            print("我是第三个")
            semaphore.signal()
        }
    }
    
    func once() {
        let onceToken = NSUUID().uuidString
        DispatchQueue.once(token: onceToken) {
            print("do once")
        }
    }
    
    func source() {
        // 使用 Dispatch Source 而不使用 queue.async 的唯一原因就是利用联结的优势。
        // DispatchSource 用于监听系统底层事件的发生，并协调后续的工作
        
        // [SwiftTimer](https://github.com/100mango/zen/blob/master/打造一个优雅的Timer/make%20a%20timer.md)
    }
}

extension DispatchQueue {
    private static var onceTracker = [String]()
    
    // 使用字符串token作为once的ID，执行once的时候加了一个锁，避免多线程下的token判断不准确的问题
    internal class func once(token: String, block: ()->Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}
