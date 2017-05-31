//
//  ViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-07.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import AssetsLibrary
import AVKit
import AVFoundation
import GPUImage

class ViewController: UIViewController, VideoSectionDelegate, SelectImportVCDelegate {
    
    var videoSectionArray: NSMutableArray = []
    var videoSlotArray: NSMutableArray = []
    var slotRangeArray: NSMutableArray = []
    var currentVideoSection: VideoSectionView?
    
    var exportBtn: UIButton?
    var videoURL: URL?
    var endEditingBtn: UIButton?
    var editingMode: Bool?
    
    var loadIndicator: UIActivityIndicatorView?
    var tipLabel:UILabel?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.createVideoSections(number: 4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        
        self.setBackground()
        
        self.navigationItem.title = "Storyboard"
        //self.navigationItem.backBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "backBtn"), style: .plain, target: self, action: #selector(endEditingMode))
        
        //self.createVideoSections(number: 3)
        
        exportBtn = UIButton.init(frame: CGRect(x: (375-300)/2, y: 500, width: 300, height: 45))
        exportBtn?.setTitle("Export", for: UIControlState.normal)
        exportBtn?.addTarget(self, action: #selector(mergeVideos), for: UIControlEvents.touchUpInside)
        self.setStyleFor(button: exportBtn!)
        self.view.addSubview(exportBtn!)
        exportBtn?.isHidden = true
        
        endEditingBtn = UIButton.init(frame: (exportBtn?.frame)!)
        endEditingBtn?.setTitle("End Editing", for: UIControlState.normal)
        endEditingBtn?.addTarget(self, action: #selector(endEditingMode), for: UIControlEvents.touchUpInside)
        self.setStyleFor(button: endEditingBtn!)
        self.view.addSubview(endEditingBtn!)
        endEditingBtn?.isHidden = true
        
        editingMode = false
        
        tipLabel = UILabel.init(frame: CGRect(x: (self.view.frame.size.width-300)/2, y: self.view.frame.size.height - 100, width: 300, height: 100))
        tipLabel?.text = "Click [+] to import video."
        tipLabel?.textColor = (UIApplication.shared.delegate as! AppDelegate).brandColor1
        tipLabel?.font = UIFont(name: "SFUIDisplay-Bold", size: 16)
        tipLabel?.textAlignment = .center
        tipLabel?.numberOfLines = 0
        self.view.addSubview(tipLabel!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func tappedVideoSection(videoSection: VideoSectionView) {
        
        if !(editingMode!) {
            //If it's not in the editing mode, allow uses to tap video section.
            currentVideoSection = videoSection
            if videoSection.containVideo {
                //let moviePlayer = MPMoviePlayerViewController(contentURL: self.currentVideoSection?.videoURL)
                //self.presentMoviePlayerViewControllerAnimated(moviePlayer)
                
                let previewController = PreviewViewController.init(videoURL: (self.currentVideoSection?.videoURL)!, mergedVideo: false)
                previewController.delegate = self
                self.navigationController?.pushViewController(previewController, animated: true)
                
            }else{
                let importController : ToyViewController = ToyViewController()
                //SelectImportViewController = SelectImportViewController()
                importController.delegate = self
                self.endEditingMode()
                self.navigationController?.pushViewController(importController, animated: true)
            }
        }
    }
    
    func switchToEditingMode() {
        editingMode = true
        
        exportBtn?.isHidden = true
        endEditingBtn?.isHidden = false
        
        tipLabel?.text = "Click (x) to delete video. \n Drag loaded video around to adjust video sequence."
        
        for i in 0...(self.videoSectionArray.count-1) {
            let videoSection = self.videoSectionArray.object(at: i) as! VideoSectionView
            if videoSection.containVideo {
                videoSection.deleteBtn?.isHidden = false
                videoSection.shake()
            }
        }
    }
    
    func endEditingMode() {
        print("End Editing Mode")
        
        editingMode = false
        
        endEditingBtn?.isHidden = true
        
        self.loadIndicator?.stopAnimating()
        self.loadIndicator?.removeFromSuperview()
        
        tipLabel?.text = "Import more videos or export a new video as the videos sequence above."
        
        for i in 0...(self.videoSectionArray.count-1) {
            let videoSection = self.videoSectionArray.object(at: i) as! VideoSectionView
            videoSection.deleteBtn?.isHidden = true
            videoSection.stopShaking()
            
            if videoSection.containVideo {
                exportBtn?.isHidden = false
            }
        }
    }
    
    func setThumbnailForVideoSection(image: UIImage, videoURL: URL, videoPath: String) {
        self.currentVideoSection?.videoIcon?.image = image
        self.currentVideoSection?.containVideo = true
        self.currentVideoSection?.videoURL = videoURL
        self.currentVideoSection?.videoPath = videoPath
        
        print("Path:\(videoPath)")
        
        exportBtn?.isHidden = false
        tipLabel?.text = "Click loaded video to preview.\n Long press any loaded video to edit."
    }
    
    func resetVideoSection() {
        self.currentVideoSection?.deleteCurrentVideoSection()
        
        exportBtn?.isHidden = true
        for i in 0...(self.videoSectionArray.count-1) {
            let videoSection = self.videoSectionArray.object(at: i) as! VideoSectionView
            if videoSection.containVideo {
                exportBtn?.isHidden = false
            }
        }
    }
    
    func exportDidFinish(session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed{
            let outputURL = session.outputURL
            print("outputURL: \(session.outputURL)")
            let library = ALAssetsLibrary()
            if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: outputURL){
                library.writeVideoAtPath(toSavedPhotosAlbum: outputURL, completionBlock: { url, error in
                    self.view.isUserInteractionEnabled = true
                    
                    var title = ""
                    var message = ""
                    if error != nil {
                        title = "Error"
                        message = "Failed to save video. \(error)"
                        
                        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }else{
                        let previewController = PreviewViewController.init(videoURL: self.videoURL!, mergedVideo: true)
                        self.navigationController?.pushViewController(previewController, animated: true)
                        
                        self.loadIndicator?.stopAnimating()
                        self.loadIndicator?.removeFromSuperview()
                        
                        /*for i in 0...(self.videoSectionArray.count-1) {
                            let videoSection = self.videoSectionArray.object(at: i) as! VideoSectionView
                            videoSection.removeFromSuperview()
                        }*/
                        //self.videoSectionArray.removeAllObjects()
                        //self.createVideoSections(number: 3)
                    }
                    
                })
            }
        }
        
        
    
    }
    
    func createVideoSections(number: Int) {
        for index in 0...(number - 1) {
            var videoSectionFrame = CGRect()
            let row : Int = index / 2
            
            print("\(row)")
            
            switch index {
            case 0:
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 128)/2), y: Int(row * (128 + 50) + 128), width: 128, height: 128)
                break
            case 1:
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 128)/2 + self.view.frame.width/2), y: row * (128 + 50) + 128, width: 128, height: 128)
                break
            case 2:
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 128)/2 + self.view.frame.width/2), y: row * (128 + 50) + 128, width: 128, height: 128)
                break
            case 3:
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 128)/2), y: row * (128 + 50) + 128, width: 128, height: 128)
                break
            default:
                break
            }
            
            
            /*if index % 2 != 1 {
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 100)/2), y: row * (100 + 50) + 100, width: 100, height: 100)
            }else{
                videoSectionFrame = CGRect(x: Int((self.view.frame.width/2 - 100)/2 + self.view.frame.width/2), y: row * (100 + 50) + 100, width: 100, height: 100)
            }*/
            
            let videoSlot = SlotView(frame: videoSectionFrame)
            self.view.addSubview(videoSlot)
            videoSlotArray.add(videoSlot)
            
            let slotRange = UIView(frame: CGRect(x: 0, y: 0, width: videoSlot.frame.size.width * 1.4, height: videoSlot.frame.size.height * 1.4))
            slotRange.center = videoSlot.center
            //slotRange.alpha = 0.5
            //slotRange.backgroundColor = UIColor.red
            self.view.addSubview(slotRange)
            slotRangeArray.add(slotRange)
            
            let videoSection = VideoSectionView(frame: videoSectionFrame)
            videoSection.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            videoSection.delegate = self
            videoSectionArray.add(videoSection)
        }
        
        for i in 0...(videoSectionArray.count-1) {
            let videoSection = videoSectionArray.object(at: i) as! VideoSectionView
            self.view.addSubview(videoSection)
        }
        
        for j in 0...(videoSectionArray.count-2) {
            let videoSection1 = videoSectionArray.object(at: j) as! VideoSectionView
            let videoSection2 = videoSectionArray.object(at: j+1) as! VideoSectionView
            
            let arrow = UIImageView.init(image: UIImage.init(named: "arrow"))
            if j == 0 {
                arrow.center = CGPoint.init(x: (videoSection1.center.x + videoSection2.center.x)/2, y: videoSection1.center.y)
                
            }else if j == 1 {
                arrow.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2));
                arrow.center = CGPoint.init(x: videoSection1.center.x, y: (videoSection1.center.y + videoSection2.center.y)/2)
            }else if j == 2 {
                arrow.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI));
                arrow.center = CGPoint.init(x: (videoSection1.center.x + videoSection2.center.x)/2, y: videoSection1.center.y)
            }
            self.view.addSubview(arrow)
        }
    }
    
    func draggingVideoSection(videoSection: VideoSectionView) -> SlotView {
        
        print("Dragging")
        let intersectionArray : NSMutableArray = []
        print("Elements: \(intersectionArray.count)")
        for i in 0...(slotRangeArray.count-1) {
            
            let slotRange = slotRangeArray.object(at: i) as! UIView
            
            let intersection = slotRange.frame.intersection(videoSection.frame)
            let intersectArea: CGFloat
            
            
            if intersection.isNull {
                intersectArea = 0
            }else{
                intersectArea = intersection.width * intersection.height
            }
            
            intersectionArray.add(intersectArea)
        }
        
        var maxIntersectionSlot = 0
        print("After Adding Elements: \(intersectionArray.count)")
        
        for j in 0...(intersectionArray.count-2) {
            if (intersectionArray.object(at: j) as! CGFloat) < (intersectionArray.object(at: j+1) as! CGFloat) {
                maxIntersectionSlot = j+1
            }
        }
        
        for element in intersectionArray {
            print(element)
        }
        print("MaxSlot: \(maxIntersectionSlot)")
        let targetSlot = videoSlotArray.object(at: maxIntersectionSlot) as! SlotView
        targetSlot.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        
        return targetSlot
    }
    
    func draggedVideoSection(videoSection: VideoSectionView, targetSlot: SlotView) {
        print("Drag")
        
        let originSlotIndex = videoSectionArray.index(of: videoSection)
        let originSlot = videoSlotArray.object(at: originSlotIndex) as! SlotView
        
        
        let targetSlotIndex = videoSlotArray.index(of: targetSlot)
        let targetVideoSection = videoSectionArray.object(at: targetSlotIndex) as! VideoSectionView
        
        UIView.animate(withDuration: 0.3,
                                   delay: 0.0,
                                   options: .curveEaseInOut,
                                   animations:
        {
            videoSection.center = targetSlot.center
            targetVideoSection.center = originSlot.center
            
            targetSlot.transform = CGAffineTransform.identity
        }, completion: { finished in
            let tempVideoSection = self.videoSectionArray.object(at: originSlotIndex) as! VideoSectionView
            
            self.videoSectionArray.replaceObject(at: originSlotIndex, with: self.videoSectionArray.object(at: targetSlotIndex))
            self.videoSectionArray.replaceObject(at: targetSlotIndex, with: tempVideoSection)
        })
    }
    
    func mergeVideos() {
        
        self.view.isUserInteractionEnabled = false
        
        loadIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadIndicator?.color = (UIApplication.shared.delegate as! AppDelegate).brandColor1
        loadIndicator?.center = CGPoint(x: self.view.center.x - (loadIndicator?.frame.size.width)!/2, y: self.view.center.y - 100)
        loadIndicator?.frame = CGRect(x: (loadIndicator?.frame.origin.x)!, y: (loadIndicator?.frame.origin.y)!, width: (loadIndicator?.frame.size.width)!*2, height: (loadIndicator?.frame.size.height)!*2)
        loadIndicator?.startAnimating()
        self.view.addSubview(loadIndicator!)
        
        let mixComposition = AVMutableComposition()
        let mainInstruction = AVMutableVideoCompositionInstruction()
        
        var videoLength = kCMTimeZero
        
        for i in 0...(videoSectionArray.count-1) {
            
            let videoSection = videoSectionArray.object(at: i) as! VideoSectionView
            
            if videoSection.containVideo {
                let videoAsset = AVAsset(url: videoSection.videoURL!)
                print("\(videoAsset)")
                
                let videoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
                do {
                    try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: videoLength)
                    videoLength = CMTimeAdd(videoLength, videoAsset.duration)
                    
                    let videoInstruction = videoCompositionInstructionForTrack(videoTrack, asset: videoAsset)
                    videoInstruction.setOpacity(0.0, at: videoLength)
                    
                    mainInstruction.layerInstructions.append(videoInstruction)
                    
                } catch {
                    print("Failed to load video track")
                }
            }
            
        }
        
        // 2.1
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoLength)
        
        // 2.3
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let date = dateFormatter.string(from: Date())*/
        
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd_hh:mm:ss"
        
        let savePath = (documentDirectory as NSString).appendingPathComponent("mergeVideo-\(dateFormatter.string(from: currentDateTime)).mov")
        let url = URL(fileURLWithPath: savePath)
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        
        exporter.exportAsynchronously(){
            DispatchQueue.main.async { _ in
                self.exportDidFinish(session: exporter)
            }
        }
        
        videoURL = exporter.outputURL
    }
    
    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
            isPortrait = true
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
            isPortrait = true
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoCompositionInstructionForTrack(_ track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
        
        var orientation = "";
        if assetInfo.orientation == .left {
            orientation = "left"
        }else if assetInfo.orientation == .right {
            orientation = "right"
        }else if assetInfo.orientation == .up {
            orientation = "up"
        }else if assetInfo.orientation == .down {
            orientation = "down"
        }else {
            orientation = "N/A"
        }
        print("Orientation: \(orientation)")
        
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: -(UIScreen.main.bounds.height - assetTrack.naturalSize.width)/2)),
                                     at: kCMTimeZero)
            print("Is Protrait");
        } else {

            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: 0))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
            print("Is Landscape");
        }
        
        return instruction
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension ViewController: UINavigationControllerDelegate{
    
    func setBackground() {
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = self.view.bounds
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        let color1 = (UIApplication.shared.delegate as! AppDelegate).brandColor1
        let color2 = (UIApplication.shared.delegate as! AppDelegate).brandColor2
        gradientLayer.colors = [color1.cgColor, color2.cgColor]
        gradientLayer.locations = [0.5, 1.0]
        self.view.layer.addSublayer(gradientLayer)
        
        let whiteLayer = CALayer.init()
        whiteLayer.frame = CGRect(x: 8, y: 28, width: self.view.bounds.width - 16.0, height: self.view.bounds.height - 36.0)
        whiteLayer.backgroundColor = UIColor.white.cgColor
        self.view.layer.addSublayer(whiteLayer)
    }
    
    func setStyleFor(button: UIButton) {
        button.backgroundColor = (UIApplication.shared.delegate as! AppDelegate).brandColor1
        button.layer.cornerRadius = 6.0
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont(name: "SFUIDisplay-Semibold", size: 16)//"SFUIDisplay-Bold"
    }
}

