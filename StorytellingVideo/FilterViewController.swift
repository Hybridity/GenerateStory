//
//  FilterViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2017-03-11.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

/*Deprecated*/

import UIKit
import GPUImage
import AssetsLibrary
import AVFoundation

class FilterViewController: UIViewController {
    
    var renderView: RenderView!
    var videoAsset: AVAsset?
    
    init(videoURL: URL) {
        
        videoAsset = AVURLAsset(url: videoURL)
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        
        let videoTrack = videoAsset?.tracks(withMediaType: AVMediaTypeVideo).first
        var videoSize = videoTrack?.naturalSize
        
        var videoOrientation = orientationFor(track: videoTrack!)
        var renderOrientation = ImageOrientation.portrait
        
        if videoOrientation == UIInterfaceOrientation.portrait {
            videoSize = CGSize(width: (videoTrack?.naturalSize.height)!, height: (videoTrack?.naturalSize.width)!)
            print("Portrait")
            renderOrientation = ImageOrientation.landscapeLeft
        }else if videoOrientation == UIInterfaceOrientation.portraitUpsideDown {
            videoSize = CGSize(width: (videoTrack?.naturalSize.height)!, height: (videoTrack?.naturalSize.width)!)
            print("Portrait Upsidedown")
            renderOrientation = ImageOrientation.landscapeRight
        }else if videoOrientation == UIInterfaceOrientation.landscapeRight {
            print("Landscape Right")
            renderOrientation = ImageOrientation.portraitUpsideDown
        }else if videoOrientation == UIInterfaceOrientation.landscapeLeft {
            print("Landscape Left")
            renderOrientation = ImageOrientation.portrait
        }
        
        renderView = RenderView(frame: CGRect(x: 0, y: 60, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width*(videoSize?.height)!/(videoSize?.width)!))
        renderView.orientation = renderOrientation
        print("Orientation: \(renderView.orientation)")
        self.view.addSubview(renderView)
        
        do {
            let movie = try MovieInput(asset: videoAsset!, playAtActualSpeed: true, loop: true)
            
            let filter = Pixellate()
            movie --> filter --> renderView
            movie.start()
            print("RenderView Sources: \(renderView)")
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func orientationFor(track: AVAssetTrack) -> UIInterfaceOrientation {
        let videoSize = track.naturalSize
        let videoTransform = track.preferredTransform
        
        if videoSize.width == videoTransform.tx && videoSize.height == videoTransform.ty {
            return UIInterfaceOrientation.landscapeRight
        }else if videoTransform.tx == 0 && videoTransform.ty == 0 {
            return UIInterfaceOrientation.landscapeLeft
        }else if videoTransform.tx == 0 && videoTransform.ty == videoSize.width {
            return UIInterfaceOrientation.portraitUpsideDown
        }else {
            return UIInterfaceOrientation.portrait
        }
    }

}
