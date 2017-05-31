//
//  ToyViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2017-04-03.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import GPUImage
import AssetsLibrary
import AVFoundation
import Filterchain

class ToyViewController: UIViewController, UINavigationControllerDelegate {
    
    var filterChain = FilterChain()
    let filterView = RenderView(frame: UIScreen.main.bounds)
    
    var delegate: SelectImportVCDelegate!
    
    public var albumBtn: UIButton?
    var captureBtn: UIButton?
    var backBtn: UIButton?
    var loadIndicator: UIActivityIndicatorView?
    var flipCameraBtn: UIButton?
    
    var timerView: TimerView?
    
    var videoURL: URL?
    
    init(videoURL: URL) {
        super.init(nibName: nil, bundle: nil)
        self.videoURL = videoURL
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.videoURL = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setBackground()
        self.navigationItem.title = "Toy"
        
        self.view.addSubview(filterView)
        
        let topToolBoxView = UIView.init(frame: CGRect(x: 8, y: 28, width: self.view.frame.size.width-16, height: 80))
        topToolBoxView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.view.addSubview(topToolBoxView)
        
        timerView = TimerView.init(frame: CGRect(x: (topToolBoxView.frame.size.width-88)/2, y: 22, width: 88, height: 24))
        topToolBoxView.addSubview(timerView!)
        
        backBtn = UIButton(frame: CGRect(x: 4, y: 12, width: 40, height: 40))
        backBtn?.setImage(UIImage.init(named: "backBtn"), for: UIControlState.normal)
        backBtn?.addTarget(self, action: #selector(clickBackBtn), for: .touchUpInside)
        topToolBoxView.addSubview(backBtn!)
        
        flipCameraBtn = UIButton(frame: CGRect(x: topToolBoxView.frame.size.width - 50, y: 12, width: 40, height: 40))
        flipCameraBtn?.setImage(UIImage.init(named: "flipCameraBtn"), for: .normal)
        flipCameraBtn?.addTarget(self, action: #selector(clickFlipCameraBtn), for: UIControlEvents.touchUpInside)
        topToolBoxView.addSubview(flipCameraBtn!)
        
        let bottomToolBoxView = UIView.init(frame: CGRect(x: 8, y: self.view.frame.size.height-8-180, width: self.view.frame.size.width-16, height: 180))
        bottomToolBoxView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.25)
        self.view.addSubview(bottomToolBoxView)
        
        let randomizeBtn = UIButton(frame: CGRect(x: bottomToolBoxView.frame.size.width - 60, y: bottomToolBoxView.frame.size.height - 60, width: 60, height: 60))
        randomizeBtn.setImage(UIImage.init(named: "randomBtn"), for: .normal)
        randomizeBtn.addTarget(self, action: #selector(randomizeFilter), for: UIControlEvents.touchUpInside)
        bottomToolBoxView.addSubview(randomizeBtn)
        
        albumBtn = UIButton(frame: CGRect(x: 0, y: randomizeBtn.frame.origin.y, width: 60, height: 60))
        albumBtn?.setImage(UIImage.init(named: "albumBtn"), for: .normal)
        albumBtn?.addTarget(self, action: #selector(clickAlbumBtn), for: UIControlEvents.touchUpInside)
        bottomToolBoxView.addSubview(albumBtn!)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.touchEventRecognizer (_:)))
        self.filterView.addGestureRecognizer(gesture)
        
        filterChain.start()
        //Shoot from camera.
        filterChain.startCameraWithView(view: filterView)
        if self.videoURL != nil {
            //Remix based on existing video
            var asset: AVAsset?
            asset = AVURLAsset(url: self.videoURL!)
            if asset != nil {
                filterChain.teardownChain()
                filterChain.currentInput = .LibraryVideo
                filterChain.videoAsset = AVURLAsset.init(url: self.videoURL!)
                filterChain.videoPreProcess(videoAsset: filterChain.videoAsset!)
            } else {
                print("Asset Nil")
            }
            
        }
        
        
        captureBtn = createVideoCaptureButton()
        captureBtn?.setImage(UIImage(named:"captureBtn_1"), for: UIControlState.normal)
        captureBtn?.addTarget(self, action: #selector(videoCaptureButtonAction(sender:)), for: .touchUpInside)
        self.view.addSubview(captureBtn!)
        
    }
    
    func clickAlbumBtn() -> Void {
        print("Click Album Button.")
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) == false{
            return
        }
        filterChain.picker.allowsEditing = true
        filterChain.picker.sourceType = .savedPhotosAlbum //.photoLibrary
        filterChain.picker.mediaTypes = [kUTTypeMovie as NSString as String]
        present(filterChain.picker, animated: true, completion: nil)
    }
    
    func clickBackBtn() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func clickFlipCameraBtn() -> Void {
        filterChain.flipCamera()
    }
    
    func createVideoCaptureButton() -> UIButton{
        let bSize = 72; // This should be an even number
        let loc = CGRect(x: Int(UIScreen.main.bounds.width/2)-(bSize/2), y: Int(UIScreen.main.bounds.height)-bSize-10, width: bSize, height: bSize)
        let captureButton = UIButton(frame: loc)
        
        //captureButton.setTitle("V", for: .normal)
        return captureButton
    }
    
    func videoCaptureButtonAction(sender: UIButton!) {
        print("Video Capture Button tapped")
        // Start capturing video
        filterChain.captureVideo()
        
        // Update UI elements to indicate that we are recording
        if (filterChain.isRecording) {
            self.captureBtn?.setImage(UIImage(named:"captureBtn_2"), for: UIControlState.normal)
            timerView?.start()
        }
        else {
            // Not recording, but not done saving either...i
            print("Setting video capture button color to yellow")
            self.captureBtn?.setImage(UIImage(named:"captureBtn_1"), for: UIControlState.normal)
            timerView?.reset()
            self.displaySavingIndicator()
            
        }
        
        // Check if video is done saving
        filterChain.videoDidSave = { result, fileURL in
            print("ViewController -> videoCaptureButtonAction -> filterChain.videoDidSave result:  \(result)")
            if result {
                print("Video Saved Successfully at \(fileURL)")
            }
            else {
                print("There was a problem saving the video.")
            }
            
            // Update UI elements
            print("Setting video capture button color to red")
            // Put UI updating on the main queue to prevent a delay
            DispatchQueue.main.async {
                self.captureBtn?.setImage(UIImage(named:"captureBtn_1"), for: UIControlState.normal)
                self.loadIndicator?.stopAnimating()
                self.loadIndicator?.removeFromSuperview()
                
                let asset = AVURLAsset(url: fileURL)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let image : UIImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
                self.delegate.setThumbnailForVideoSection(image: image, videoURL: fileURL, videoPath: fileURL.path)
                
                //Switch to Video Trimming.
                self.editVideo(path: fileURL.path)
            }
        }
    }
    
    func randomizeFilter() {
        filterChain.randomizeFilterChain()
    }
    
    // Touch recognizer action
    func touchEventRecognizer(_ sender:UITapGestureRecognizer){
        // do other task
        print("Touch Event!!!, randomizing filter")
        filterChain.randomizeFilterChain()
        //        filterChain.removeFilterAtIndex(index: tempFilterNum)
        //        tempFilterNum-=1;
        
        //        filterChain.appendFilter(filter: tempFilterNum)
        //        tempFilterNum+=1;
        
        //print("tempFilterNum", tempFilterNum);
        
    }
    
    func displaySavingIndicator() {
        loadIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        loadIndicator?.color = UIColor.white
        loadIndicator?.center = (captureBtn?.center)!
        //loadIndicator?.frame = CGRect(x: (loadIndicator?.frame.origin.x)!, y: (loadIndicator?.frame.origin.y)!, width: (loadIndicator?.frame.size.width)!*2, height: (loadIndicator?.frame.size.height)!*2)
        loadIndicator?.startAnimating()
        self.view.addSubview(loadIndicator!)
    }
    
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
        
        filterView.frame = whiteLayer.frame
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ToyViewController: UIVideoEditorControllerDelegate {
    func editVideo(path: String) {
        print("Edit Video After Recording.")
        let editVideoViewController: UIVideoEditorController!
        
        if UIVideoEditorController.canEditVideo(atPath: path) {
            editVideoViewController = UIVideoEditorController()
            editVideoViewController.delegate = self
            editVideoViewController.videoPath = path
            editVideoViewController.videoQuality = .typeHigh
            present(editVideoViewController, animated: true, completion: {
                
            })
        }
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        dismiss(animated: false, completion: {
            let videoURL = URL(fileURLWithPath: editedVideoPath)
            
            let asset = AVURLAsset(url: videoURL)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let image : UIImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
            
            self.delegate.setThumbnailForVideoSection(image: image, videoURL: videoURL, videoPath: editedVideoPath)
            
            //Switch back to ViewController View.
            self.navigationController?.popViewController(animated: false)
        })
    }
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        dismiss(animated: true, completion: {})
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        print("error=\(error.localizedDescription)")
        dismiss(animated: true, completion: {})
    }
    
}
























