//
//  PreviewViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2016-12-12.
//  Copyright © 2016 Wanqiao Wu. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices

import FBSDKLoginKit
import FBSDKShareKit

class PreviewViewController: UIViewController {
    
    var thumbnailImageView: UIImageView?
    var thumbnailImage: UIImage?
    var videoURL: URL?
    var mergedVideo: Bool
    var delegate: SelectImportVCDelegate!
    
    var fbShareBtn: UIButton?
    var fbLoginBtn: UIButton?
    var backBtn: UIButton?
    var bottomBorder: UIImageView?
    
    var shareIndicator: UIActivityIndicatorView?
    
    init(videoURL: URL, mergedVideo: Bool) {
        
        let asset = AVURLAsset(url: videoURL)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        thumbnailImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
        self.videoURL = videoURL
        self.mergedVideo = mergedVideo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "Preview"
        
        self.setBackground()
        
        backBtn = UIButton(frame: CGRect(x: 10, y: 30, width: 40, height: 40))
        backBtn?.setImage(UIImage.init(named: "backBtn"), for: UIControlState.normal)
        backBtn?.addTarget(self, action: #selector(clickBackBtn), for: .touchUpInside)
        self.view.addSubview(backBtn!)
        
        let titleLabel = UILabel.init(frame: CGRect(x: UIScreen.main.bounds.width*0.1, y: 40, width: UIScreen.main.bounds.width*0.8, height: 24))
        titleLabel.font = UIFont(name: "SFUIDisplay-Bold", size: 24)
        titleLabel.textAlignment = .center
        titleLabel.textColor = (UIApplication.shared.delegate as! AppDelegate).brandColor1
        self.view.addSubview(titleLabel)
        
        let topBorder = UIImageView(frame: CGRect(x: 8, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 50, width: UIScreen.main.bounds.width-16, height: 11))
        topBorder.image = UIImage.init(named: "topBar")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch)
        self.view.addSubview(topBorder)
        
        thumbnailImageView = UIImageView.init(frame: CGRect(x: 8, y: topBorder.frame.origin.y+topBorder.frame.size.height, width: topBorder.frame.width, height: topBorder.frame.width))
        thumbnailImageView?.image = thumbnailImage
        thumbnailImageView?.isUserInteractionEnabled = true
        thumbnailImageView?.contentMode = .scaleAspectFill
        thumbnailImageView?.clipsToBounds = true
        self.view.addSubview(thumbnailImageView!)
        
        let playIcon = UIImageView.init(frame: CGRect(x: ((thumbnailImageView?.frame.width)!-128)/2, y: ((thumbnailImageView?.frame.height)!-128)/2, width: 128, height: 128))
        playIcon.image = UIImage.init(named: "playBtn")
        thumbnailImageView?.addSubview(playIcon)
        
        bottomBorder = UIImageView(frame: CGRect(x: 8, y: (thumbnailImageView?.frame.origin.y)! + (thumbnailImageView?.frame.size.height)!, width: UIScreen.main.bounds.width-16, height: 11))
        bottomBorder?.image = UIImage.init(named: "bottomBar")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch)
        self.view.addSubview(bottomBorder!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PreviewViewController.playVideo))
        self.thumbnailImageView?.addGestureRecognizer(tapGesture)
        
        if (self.mergedVideo) {
            /*If this is the preview of merged video*/
            
            if (FBSDKAccessToken.current() != nil) {
                /*With facebook logged in. Show Share Button directly*/
                fbShareBtn = UIButton.init(frame: CGRect(x: (UIScreen.main.bounds.width-70)/2, y: (UIScreen.main.bounds.height + ((bottomBorder?.frame.origin.y)!+(bottomBorder?.frame.size.height)!) - 70)/2, width: 70, height: 70))
                fbShareBtn?.setImage(UIImage.init(named: "fbBtn"), for: .normal)
                fbShareBtn?.addTarget(self, action: #selector(shareVideo), for: UIControlEvents.touchUpInside)
                self.view.addSubview(fbShareBtn!)
            } else {
                /*Show login button first if no user has logged in Facebook.*/
                
                fbLoginBtn = UIButton.init(frame: CGRect(x: (UIScreen.main.bounds.width-70)/2, y: (UIScreen.main.bounds.height + ((bottomBorder?.frame.origin.y)!+(bottomBorder?.frame.size.height)!) - 70)/2, width: 70, height: 70))
                fbLoginBtn?.setImage(UIImage.init(named: "fbBtn"), for: .normal)
                fbLoginBtn?.addTarget(self, action: #selector(facebookLogin), for: UIControlEvents.touchUpInside)
                self.view.addSubview(fbLoginBtn!)
            }
            titleLabel.text = "Share"
        }else {
            /*If this preview is for unmerged video, show editBtn and deleteBtn*/
            let editBtn = UIButton.init(frame: CGRect(x: UIScreen.main.bounds.width/2 - 70/2, y: (UIScreen.main.bounds.height + ((bottomBorder?.frame.origin.y)!+(bottomBorder?.frame.size.height)!) - 70)/2, width: 70, height: 70))
            editBtn.addTarget(self, action: #selector(editVideo), for: UIControlEvents.touchUpInside)
            editBtn.setImage(UIImage.init(named: "trimBtn"), for: .normal)
            self.view.addSubview(editBtn)
            
            let deleteBtn = UIButton.init(frame: CGRect(x: UIScreen.main.bounds.width/2 + editBtn.frame.size.width/2 + 20, y: editBtn.frame.origin.y, width: editBtn.frame.size.width, height: editBtn.frame.size.height))
            deleteBtn.setImage(UIImage.init(named: "deleteBtn"), for: .normal)
            deleteBtn.addTarget(self, action: #selector(deleteVideo), for: UIControlEvents.touchUpInside)
            self.view.addSubview(deleteBtn)
            
            let filterBtn = UIButton.init(frame: CGRect(x: UIScreen.main.bounds.width/2 - editBtn.frame.size.width/2*3 - 20, y: editBtn.frame.origin.y, width: editBtn.frame.size.width, height: editBtn.frame.size.height))
            filterBtn.setImage(UIImage.init(named: "filterBtn"), for: .normal)
            filterBtn.addTarget(self, action: #selector(remixVideo), for: UIControlEvents.touchUpInside)
            self.view.addSubview(filterBtn)
            
            titleLabel.text = "Edit"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickBackBtn() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    

    func playVideo() {
        print("Play Preview Video")
        let moviePlayer = MPMoviePlayerViewController(contentURL: videoURL)
        self.presentMoviePlayerViewControllerAnimated(moviePlayer)
    }
    
    func deleteVideo() {
        print("Delete Video & Return to ViewController")
        self.delegate.resetVideoSection()
        self.navigationController?.popViewController(animated: true)
    }
    
    func remixVideo() {
        print("Remix Video")
        let importController : ToyViewController = ToyViewController.init(videoURL: videoURL!)
        importController.delegate = self
        self.navigationController?.pushViewController(importController, animated: true)
    }
    
    func shareVideo() {
        print("Share Video to Facebook")
        
        shareIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        shareIndicator?.color = (UIApplication.shared.delegate as! AppDelegate).brandColor1
        shareIndicator?.center = (self.fbShareBtn?.center)!
        shareIndicator?.frame = (self.fbShareBtn?.frame)!
        shareIndicator?.startAnimating()
        self.view.addSubview(shareIndicator!)
        fbShareBtn?.isHidden = true
        
        let video: FBSDKShareVideo = FBSDKShareVideo()
        video.videoURL = self.videoURL
        let content: FBSDKShareVideoContent = FBSDKShareVideoContent()
        content.video = FBSDKShareVideo(videoURL: self.videoURL)
        
        FBSDKShareAPI.share(with: content, delegate: self)
        
    }
    
    func facebookLogin() {
        let loginManager = FBSDKLoginManager.init()
        loginManager.logIn(withPublishPermissions: ["publish_actions"], from: self) { (loginResult, error) in
            if ((error) != nil) {
                print(error?.localizedDescription)
            } else if (loginResult?.isCancelled)! {
                print("Facebook Login Cancelled")
            } else {
                print("Facebook Logged In.")
                
                self.fbLoginBtn?.removeFromSuperview()
                if (self.fbShareBtn == nil) {
                    self.fbShareBtn = UIButton.init(frame: CGRect(x: (UIScreen.main.bounds.width-70)/2, y: (UIScreen.main.bounds.height + ((self.bottomBorder?.frame.origin.y)!+(self.bottomBorder?.frame.size.height)!) - 70)/2, width: 70, height: 70))
                     self.fbShareBtn?.setImage(UIImage.init(named: "fbBtn"), for: .normal)
                     self.fbShareBtn?.addTarget(self, action: #selector(self.shareVideo), for: UIControlEvents.touchUpInside)
                }
                
                self.view.addSubview(self.fbShareBtn!)
            }
        }
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
    }
}

extension PreviewViewController: FBSDKSharingDelegate {
    /**
     Sent to the delegate when the sharer is cancelled.
     - Parameter sharer: The FBSDKSharing that completed.
     */
    public func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("FB CANCEL")
        self.alert(title: "Reminder", message: "You video posting is cancelled.")
        fbShareBtn?.isHidden = false
        self.shareIndicator?.stopAnimating()
        self.shareIndicator?.removeFromSuperview()
    }
    
    /**
     Sent to the delegate when the sharer encounters an error.
     - Parameter sharer: The FBSDKSharing that completed.
     - Parameter error: The error.
     */
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("FB FAIL WITH ERROR: \(error)")
        self.alert(title: "Reminder", message: "We have error while posting your video. \(error)")
        fbShareBtn?.isHidden = false
        self.shareIndicator?.stopAnimating()
        self.shareIndicator?.removeFromSuperview()
    }
    
    /**
     Sent to the delegate when the share completes without error or cancellation.
     - Parameter sharer: The FBSDKSharing that completed.
     - Parameter results: The results from the sharer.  This may be nil or empty.
     */
    public func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        //
        print("FB SUCCESS")
        self.alert(title: "Reminder", message: "Your video has been posted successfully to Facebook.")
        fbShareBtn?.isHidden = false
        self.shareIndicator?.stopAnimating()
        self.shareIndicator?.removeFromSuperview()
    }
    
    func alert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension PreviewViewController: UIVideoEditorControllerDelegate, UINavigationControllerDelegate {
    
    func editVideo() {
        print("Edit Video")
        let editVideoViewController: UIVideoEditorController!
        
        if UIVideoEditorController.canEditVideo(atPath: (videoURL?.path)!) {
            editVideoViewController = UIVideoEditorController()
            editVideoViewController.delegate = self
            editVideoViewController.videoPath = (videoURL?.path)!
            editVideoViewController.videoQuality = .typeHigh
            present(editVideoViewController, animated: true, completion: {
                
            })
        }
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        dismiss(animated: false, completion: {
            self.videoURL = URL(fileURLWithPath: editedVideoPath)
            
            let asset = AVURLAsset(url: self.videoURL!)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let image : UIImage = try! UIImage(cgImage: imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil))
            
            self.setThumbnailForVideoSection(image: image, videoURL: self.videoURL!, videoPath: (self.videoURL?.path)!)
        })
    }
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        dismiss(animated: true, completion: {})
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        print("error=\(error.localizedDescription)")
        dismiss(animated: true, completion: {})
    }
    
    func setThumbnailForVideoSection(image: UIImage, videoURL: URL, videoPath: String) {
        self.thumbnailImage = image
        thumbnailImageView?.image = thumbnailImage
        self.videoURL = videoURL
        self.delegate.setThumbnailForVideoSection(image: image, videoURL: videoURL, videoPath: videoURL.path)
    }
}

extension PreviewViewController: SelectImportVCDelegate {
    
    func resetVideoSection() {
    
    }
}
