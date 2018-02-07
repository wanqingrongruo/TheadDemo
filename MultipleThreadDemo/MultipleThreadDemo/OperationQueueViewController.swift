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
    
    /**
     * ## Operation 特性
     * 支持在 operation 之间建立依赖关系，只有当一个 operation 所依赖的所有 operation 都执行完成时，这个 operation 才能开始执行；
     * 支持一个可选的 completion block ，这个 block 将会在 operation 的主任务执行完成时被调用；
     * 支持通过 KVO 来观察 operation 执行状态的变化；
     * 支持设置执行的优先级，从而影响 operation 之间的相对执行顺序；
     * 支持取消操作，可以允许我们停止正在执行的 operation
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

    // 自定义 operation 实现异步转同步
    func customOp() {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        
        var lastOp: customOperation? = nil
        
        // 我们应该在手动执行一个 operation 或将它添加到 operation queue 前配置好依赖关系
        for i in 0...4 {
            let op = customOperation(number: i)
            if let la = lastOp {  // 加依赖 a->b->c->d  -> e  , 不加依赖 abcd -> e
                op.addDependency(la)
            }
            lastOp = op
            
            queue.addOperation(op)
        }
        
        let allOp = BlockOperation {
            print("全部任务都完成了")
        }
        
        allOp.addDependency(lastOp!)
        queue.addOperation(allOp)
    }
}

class customOperation: Operation {
    
    // [iOS 并发编程之 Operation Queues](http://blog.leichunfeng.com/blog/2015/07/29/ios-concurrency-programming-operation-queues/)
    
    /**
     * ## 响应取消事件
     * 在真正开始执行任务之前；
     * 至少在每次循环中检查一次，而如果一次循环的时间本身就比较长的话，则需要检查得更加频繁；
     * 在任何相对来说比较容易中止 operation 的地方
    
     */
    
    /**
     * ## 你想要手动地执行一个 operation ，又想这个 operation 能够异步执行的话，你需要做一些额外的配置来让你的 operation 支持并发执行。下面列举了一些你可能需要重写的方法
     * start ：必须的，所有并发执行的 operation 都必须要重写这个方法，替换掉 NSOperation 类中的默认实现。start 方法是一个 operation 的起点，我们可以在这里配置任务执行的线程或者一些其它的执行环境。另外，需要特别注意的是，在我们重写的 start 方法中一定不要调用父类的实现；
     *  main ：可选的，通常这个方法就是专门用来实现与该 operation 相关联的任务的。尽管我们可以直接在 start 方法中执行我们的任务，但是用 main 方法来实现我们的任务可以使设置代码和任务代码得到分离，从而使 operation 的结构更清晰；
     * isExecuting 和 isFinished ：必须的，并发执行的 operation 需要负责配置它们的执行环境，并且向外界客户报告执行环境的状态。因此，一个并发执行的 operation 必须要维护一些状态信息，用来记录它的任务是否正在执行，是否已经完成执行等。此外，当这两个方法所代表的值发生变化时，我们需要生成相应的 KVO 通知，以便外界能够观察到这些状态的变化；
     * isConcurrent ：必须的，这个方法的返回值用来标识一个 operation 是否是并发的 operation ，我们需要重写这个方法并返回 YES 。
     */

    /**
     * ## 关于优先级
     * 队列优先级只应用于相同 operation queue 中的 operation 之间，不同 operation queue 中的 operation 不受此影响
     * operation 的队列优先级只决定当前所有 isReady 状态为 YES 的 operation 的执行顺序
     
     /*
     注意，我们只能够在执行一个 operation 或将其添加到 operation queue 前，通过 operation 的 QueuePriority 属性来修改它的线程优先级。当 operation 开始执行时，NSOperation 类中默认的 start 方法会使用我们指定的值来修改当前线程的优先级。另外，我们指定的这个线程优先级只会影响 main 方法执行时所在线程的优先级。所有其它的代码，包括 operation 的 completion block 所在的线程会一直以默认的线程优先级执行。因此，当我们自定义一个并发的 operation 类时，我们也需要在 start 方法中根据指定的值自行修改线程的优先级。
     */
     
     */
    
    /**
     * ## completion block
     注意，当一个 operation 被取消时，它的 completion block 仍然会执行，所以我们需要在真正执行代码前检查一下 isCancelled 方法的返回值。另外，我们也没有办法保证 completion block 被回调时一定是在主线程，理论上它应该是与触发 isFinished 的 KVO 通知所在的线程一致的，所以如果有必要的话我们可以在 completion block 中使用 GCD 来保证从主线程更新 UI 。
     */

    // queue.maxConcurrentOperationCount = 1 // 串行
    // 一个串行的 operation queue 与一个串行的 dispatch queue 还是有本质区别的，因为 dispatch queue 的执行顺序一直是 FIFO 的, 而 operation 的执行顺序还是一样会受其他因素影响的，比如 operation 的 isReady 状态、operation 的队列优先级等
    
    /*
     手动执行 Operation
     
     尽管使用 operation queue 是执行一个 operation 最方便的方式，但是我们也可以不用 operation queue 而选择手动地执行一个 operation 。从原理上来说，手动执行一个 operation 也是非常简单的，只需要调用它的 start 方法就可以了。但是从严格意义上来说，在调用 start 方法真正开始执行一个 operation 前，我们应该要做一些防范性的判断，比如检查 operation 的 isReady 状态是否为 YES ，这个取决于它所依赖的 operation 是否已经执行完成；又比如检查 operation 的 isCancelled 状态是否为 YES ，如果是，那么我们就根本不需要再花费不必要的开销去启动它。
     
     另外，我们应该一直通过 start 方法去手动执行一个 operation ，而不是 main 或其他的什么方法。因为默认的 start 方法会在真正开始执行任务前为我们做一些安全性的检查，比如检查 operation 是否已取消等。另外，正如我们前面说的，在默认的 start 方法中会生成一些必要的 KVO 通知，比如 isExcuting 和 isFinished ，而这些 KVO 通知正是 operation 能够正确处理好依赖关系的关键所在。
     
     更进一步说，如果我们需要实现的是一个并发的 operation ，我们也应该在启动 operation 前检查一下它的 isConcurrent 状态。如果它的 isConcurrent 状态为 NO ，那么我们就需要考虑一下是否可以在当前线程同步执行这个 operation ，或者是先为这个 operation 创建一个单独的线程，以供它异步执行。
     */
    
    
    /*
     取消 Operation
     
     从原则上来说，一旦一个 operation 被添加到 operation queue 后，这个 operation 的所有权就属于这个 operation queue 了，并且不能够被移除。唯一从 operation queue 中出队一个 operation 的方式就是调用它的 cancel 方法取消这个 operation ，或者直接调用 operation queue 的 cancelAllOperations 方法取消这个 operation queue 中所有的 operation 。另外，我们前面也提到了，当一个 operation 被取消后，这个 operation 的 isFinished 状态也会变成 YES ，这样处理的好处就是所有依赖它的 operation 能够接收到这个 KVO 通知，从而能够清除这个依赖关系正常执行。
     */
    
    /*
     等待 Operation 执行完成
     
     一般来说，为了让我们的应用拥有最佳的性能，我们应该尽可能地异步执行所有的 operation ，从而让我们的应用在执行这些异步 operation 的同时还能够快速地响应用户事件。当然，我们也可以调用 NSOperation 类的 waitUntilFinished 方法来阻塞当前线程，直到这个 operation 执行完成。虽然这种方式可以让我们非常方便地处理 operation 的执行结果，但是却给我们的应用引入了更多的串行，限制了应用的并发性，从而降低了我们应用的响应性。
     
     注意，我们应该要坚决避免在主线程中去同步等待一个 operation 的执行结果，阻塞的方式只应该用在辅助线程或其他 operation 中。因为阻塞主线程会大大地降低我们应用的响应性，带来非常差的用户体验。
     
     除了等待一个单独的 operation 执行完成外，我们也可以通过调用 NSOperationQueue 的 waitUntilAlloperationsAreFinished 方法来等待 operation queue 中的所有 operation 执行完成。有一点需要特别注意的是，当我们在等待一个 operation queue 中的所有 operation 执行完成时，其他的线程仍然可以向这个 operation queue 中添加 operation ，从而延长我们的等待时间。
     */
    
    /*
     暂停和恢复 Operation Queue
     
     如果我们想要暂停和恢复执行 operation queue 中的 operation ，可以通过调用 operation queue 的 setSuspended: 方法来实现这个目的。不过需要注意的是，暂停执行 operation queue 并不能使正在执行的 operation 暂停执行，而只是简单地暂停调度新的 operation 。另外，我们并不能单独地暂停执行一个 operation ，除非直接 cancel 掉。
     */
    
    
    private var _executing: Bool = false
    private var _finished: Bool = false
    private var number: Int = 0
    
    override var isExecuting: Bool {
        return _executing
    }
    override var isFinished: Bool {
        return _finished
    }
    
    override var isConcurrent: Bool {
        return true
    }

    init(number: Int) {
        self.number = number
    }
    
    override func start() {
        // 不要调父类的 start 方法
        if isCancelled {
            // 即使一个 operation 是被 cancel 掉了，我们仍然需要手动触发 isFinished 的 KVO 通知
            self.willChangeValue(forKey: "isFinished")
            _finished = true
            self.didChangeValue(forKey: "isFinished")
            return
        }
        self.willChangeValue(forKey: "isExecuting")
        // 为 main 分离一个新线程
        Thread.detachNewThreadSelector(#selector(main), toTarget: self, with: nil)
        _executing = true
        self.didChangeValue(forKey: "isExecuting")
    }
    
    override func main() {
        
        if isCancelled {
            self.willChangeValue(forKey: "isFinished")
            _finished = true
            self.didChangeValue(forKey: "isFinished")
            return
        }
        
        self.willChangeValue(forKey: "isExecuting")
        _executing = true
        print("开始任务.... \(self.number)")
        DispatchQueue.global().async { [weak self] in
            sleep(2)
            print("任务完成.... \(self?.number)")
            self?.completeOperation()
        }
        self.didChangeValue(forKey: "isExecuting")
    }
    
    private func completeOperation() {
        self.willChangeValue(forKey: "isFinished")
        self.willChangeValue(forKey: "isExecuting")
        _executing = false
        _finished = true
        self.didChangeValue(forKey: "isFinished")
        self.didChangeValue(forKey: "isExecuting")
    }
    
    deinit {
        print("SwiftOperation deinit: \(self.number)")
    }
}
