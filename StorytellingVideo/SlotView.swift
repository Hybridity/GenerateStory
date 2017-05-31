//
//  SlotView.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-14.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit

class SlotView: UIView {

    override init(frame: CGRect){

        super.init(frame: frame)
        
        let bgImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        bgImageView.image = UIImage.init(named: "videoBg")
        /*bgImageView.layer.cornerRadius = 14.0
        bgImageView.clipsToBounds = true
        bgImageView.layer.borderWidth = 6
        bgImageView.layer.borderColor = UIColor.init(colorLiteralRed: 144.0/255.0, green: 19.0/255.0, blue: 254.0/255.0, alpha: 0.2).cgColor*/
        self.addSubview(bgImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
