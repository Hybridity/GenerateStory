//
//  VideoSectionView.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-07.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit

protocol VideoSectionDelegate {
    func tappedVideoSection(videoSection: VideoSectionView)
    func switchToEditingMode()
    func draggedVideoSection(videoSection: VideoSectionView, targetSlot: SlotView)
    func draggingVideoSection(videoSection: VideoSectionView) -> SlotView
}
class VideoSectionView: UIView {
    
    var delegate : VideoSectionDelegate!
    public var videoIcon : UIImageView?
    public var containVideo : Bool
    public var videoURL : URL? //Used to store selected video and preview it later.
    public var videoPath: String!
    var deleteBtn : UIButton?
    var targetSlot : SlotView?

    override init(frame: CGRect) {
        containVideo = false
        
        super.init(frame: frame)
        
        videoIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        //videoIcon?.backgroundColor = UIColor.white
        videoIcon?.layer.cornerRadius = 10.0
        videoIcon?.contentMode = .scaleAspectFill
        videoIcon?.clipsToBounds = true
        
        //videoIcon?.layer.borderWidth = 6
        //videoIcon?.layer.borderColor = UIColor.gray.cgColor
        self.addSubview(videoIcon!)
        
        deleteBtn = UIButton.init(frame: CGRect(x: -15, y: -15, width: self.frame.width/1.5, height: self.frame.width/1.5))
        deleteBtn?.setImage(UIImage.init(named: "crossBtn"), for: UIControlState.normal)
        deleteBtn?.center = CGPoint(x: 0, y: 0)
        deleteBtn?.addTarget(self, action: #selector(deleteCurrentVideoSection), for: UIControlEvents.touchUpInside)
        self.addSubview(deleteBtn!)
        deleteBtn?.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(VideoSectionView.beTapped))
        self.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(VideoSectionView.handlePressGesture(gesture:)))
        //longPressGesture.minimumPressDuration = 1
        self.addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beTapped() {
        print("Be Tapped")
        delegate.tappedVideoSection(videoSection: self)
    }
    
    func handlePressGesture(gesture: UILongPressGestureRecognizer) {
        
        if self.containVideo {
            if gesture.state == UIGestureRecognizerState.began {
                print("Begin")
                deleteBtn?.isHidden = false
                //self.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                
                let panGesture = UIPanGestureRecognizer(target: self, action: #selector(VideoSectionView.beDragged(gesture:)))
                self.addGestureRecognizer(panGesture)
                
            }else if gesture.state == UIGestureRecognizerState.ended {
                print("Ended")
                //deleteBtn?.removeFromSuperview()
            }
            
            self.delegate.switchToEditingMode()
        }
        
    }
    
    func deleteCurrentVideoSection() {
        videoIcon?.image = nil
        containVideo = false
        videoURL = nil
        videoPath = nil
        deleteBtn?.isHidden = true
        self.stopShaking()
    }
    
    func beDragged(gesture: UIPanGestureRecognizer) {
        //print("Be Dragged")
        self.superview?.bringSubview(toFront: self)
        let translation = gesture.translation(in: self.superview)
        self.center = CGPoint(x: ((gesture.view?.center.x)! + translation.x), y: (gesture.view?.center.y)! + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.superview)
        
        if gesture.state == UIGestureRecognizerState.began {
            self.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            
        } else if gesture.state == UIGestureRecognizerState.changed {
            
            if (targetSlot != nil) {
                 targetSlot?.transform = CGAffineTransform.identity
            }
            self.targetSlot = self.delegate.draggingVideoSection(videoSection: self)
        } else if gesture.state == UIGestureRecognizerState.ended {
            self.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)

            self.delegate.draggedVideoSection(videoSection: self, targetSlot: self.targetSlot!)
        }
        
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.3
        animation.repeatCount = .infinity
        animation.values = [0, -5.0/180.0*M_PI, 0, 5.0/180.0*M_PI, 0]
        self.layer.add(animation, forKey: "shake")
    }
    
    func stopShaking() {
        self.layer.removeAnimation(forKey: "shake")
    }

}
