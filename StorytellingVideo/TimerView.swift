//
//  TimerView.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2017-04-26.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

import Foundation
import UIKit

class TimerView: UIImageView {
    
    var timer = Timer()
    var counter = 0
    var timeLabel: UILabel?
    var recordIndicator: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = UIImage.init(named: "timerBg")
        
        timeLabel = UILabel.init(frame: CGRect(x: self.frame.size.width*0.2, y: 0, width: self.frame.size.width*0.8, height: self.frame.size.height))
        timeLabel?.text = "00:00:00"
        timeLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 12)
        timeLabel?.textColor = (UIApplication.shared.delegate as! AppDelegate).brandColor1
        timeLabel?.textAlignment = .center
        self.addSubview(timeLabel!)
        
        recordIndicator = UIImageView.init(image: UIImage.init(named: "redDot"))
        recordIndicator?.frame = CGRect(x: self.frame.size.width*0.1, y: (self.frame.size.height-self.frame.size.width*0.1)/2, width: self.frame.size.width*0.1, height: self.frame.size.width*0.1)
        self.recordIndicator?.alpha = 0
        self.addSubview(recordIndicator!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func start() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    public func reset() {
        timer.invalidate()
        timeLabel?.text = "00:00:00"
        self.recordIndicator?.alpha = 0
    }
    
    func updateTimer() {
        counter += 1
        
        UIView.animate(withDuration: 0.2, animations: {
            self.recordIndicator?.alpha = 1
        }) { (true) in
            self.recordIndicator?.alpha = 0
        }
        
        var sec = counter
        var min = 0
        var hour = 0
        
        if(sec >= 60){
            min = Int(sec/60)
            sec = sec%60
            
            if(min >= 60){
                hour = Int(min/60)
                min = min%60
            }
        }
        
        timeLabel?.text = String(format: "%02d", hour) + ":" + String(format: "%02d", min) + ":" + String(format: "%02d", sec)
    }
}
