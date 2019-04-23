//
//  ViewController.swift
//  ReactiveSwiftCoundDownSample
//
//  Created by park kyung suk on 2019/04/23.
//  Copyright © 2019 park kyung suk. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

class ViewController: UIViewController {

    @IBOutlet weak var countdownLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startCountdown(sec: 3, targetLabel: self.countdownLabel)
            .startWithCompleted {
                print("Finished Countdown")
                //カウントダウンが完了後処理したいコードを書く
            }
        
    }
    
    
    func startCountdown(sec: Double, targetLabel: UILabel) -> SignalProducer<Void, NoError> {
        targetLabel.isHidden = false
        
        return SignalProducer<Void, NoError> { (observer, lifetime) in
            
            self.createCountdownSignalProducer(sec: sec)
                .skipRepeats()
                .observe(on: UIScheduler())
                .startWithSignal { (signal, disposable) in
                    lifetime += targetLabel.reactive.text <~ signal.map { String($0) }
                    lifetime += signal.observeCompleted {
                        targetLabel.isHidden = true
                        //takeによりcompletedが送信されたら
                        //observerもcompletedを送信して呼び先に知らせる
                        observer.sendCompleted()
                    }
                }
        }
    }
    
    private func createCountdownSignalProducer(sec: Double) -> SignalProducer<Int, NoError> {
        let endTargetDate = Date().addingTimeInterval(sec)
        
        return SignalProducer.timer(interval: .milliseconds(50), on: QueueScheduler()).map { timeDate in
            // 発火したタイミングより指定した秒までに .millisecond(50)ごとにシグナルを送信
            endTargetDate.timeIntervalSince(timeDate)
            } // .take { } は 条件が成立すると 自動的に.completedされる
            .take { timeInterval in timeInterval > 0 }
            // TimeIntervalを Intに整形して送信
            .map { timeInterval in Int(timeInterval) + 1}
    }


}

