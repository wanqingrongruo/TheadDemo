//
//  ThreadViewController.swift
//  MultipleThreadDemo
//
//  Created by roni on 2018/1/22.
//  Copyright © 2018年 roni. All rights reserved.
//

import UIKit

class ThreadViewController: UIViewController {

    /**
     * ## Thread
     * 使用更加面向对象
     * 简单易用, 可直接操作线程对象
     * 程序员管理,偶尔使用.
     */

    @IBAction func create01(_ sender: UIButton) {
        let thread01 = Thread(target: self, selector: #selector(dosomething01(object:)), object: "Thread01")
        // 线程加入线程池等待调度, 需要 start , 几乎立刻执行
        thread01.start()
        
        /*
         * thread01.isExecuting //
         * thread01.isCancelled
         * thread01.isFinished
         * thread01.isMainThread
         * thread01.threadPriority // 线程优先级, 默认0.5
         */
    }
    @IBAction func create02(_ sender: UIButton) {
        // 创建后自己启动
        Thread.detachNewThreadSelector(#selector(dosomething02(object:)), toTarget: self, with: "Thread02")
    }
    @IBAction func create03(_ sender: UIButton) {
        // 隐式创建, 直接启动
        self.performSelector(inBackground: #selector(dosomething03(object:)), with: "Thread03")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func someClassMethods() {
        Thread.sleep(forTimeInterval: 2)
        Thread.sleep(until: Date.init(timeIntervalSinceReferenceDate: 1000))
        Thread.exit() // 退出线程
        _ = Thread.isMainThread // 是否是主线程
        Thread.isMultiThreaded() // 当前线程是否是多线程
        _ = Thread.isMainThread // 是否是主线程对象
        
        
    }
    
}

extension ThreadViewController {
   @objc func dosomething01(object: Any) {
        let str = String(describing: "dosomething01参数: \(object), 线程: \(Thread.current)")
        print(str)
    }
   @objc func dosomething02(object: Any) {
        let str = String(describing: "dosomething02参数: \(object), 线程: \(Thread.current)")
        print(str)
    }
   @objc func dosomething03(object: Any) {
        let str = String(describing: "dosomething03参数: \(object), 线程: \(Thread.current)")
        print(str)
    }
}
