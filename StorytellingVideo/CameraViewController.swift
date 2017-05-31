//
//  CameraViewController.swift
//  StorytellingVideo
//
//  Created by Wanqiao Wu on 2017-03-27.
//  Copyright © 2017 Wanqiao Wu. All rights reserved.
//

/*Deprecated*/

import UIKit
import Filterchain
import GPUImage

class CameraViewController: UIViewController {
    
    var filterChain = FilterChain()
    let filterView = RenderView(frame: UIScreen.main.bounds)
    
    var captureBtn : UIButton?
    
    init() {
        super.init(nibName: nil, bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.addSubview(filterView)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.touchEventRecognizer (_:)))
        self.filterView.addGestureRecognizer(gesture)
        
        captureBtn = createVideoCaptureButton()
        captureBtn?.addTarget(self, action: #selector(videoCaptureButtonAction(sender:)), for: .touchUpInside)
        self.view.addSubview(captureBtn!)
        
        filterChain.start()
        filterChain.startCameraWithView(view: filterView)
    }
    
    func createVideoCaptureButton() -> UIButton{
        let bSize = 72; // This should be an even number
        let loc = CGRect(x: Int(UIScreen.main.bounds.width/2)-(bSize/2)+bSize*2, y: Int(UIScreen.main.bounds.height)-Int(UIScreen.main.bounds.height/7), width: bSize, height: bSize)
        let captureButton = UIButton(frame: loc)
        
        captureButton.setTitle("V", for: .normal)
        captureButton.backgroundColor = .red
        // Make the button round
        captureButton.layer.cornerRadius = 0.5 * captureButton.bounds.size.width
        captureButton.clipsToBounds = true
        return captureButton
    }
    
    func videoCaptureButtonAction(sender: UIButton!) {
        print("Video Capture Button tapped")
        // Start capturing video
        filterChain.captureVideo()
        
        // Update UI elements to indicate that we are recording
        if (filterChain.isRecording) {
            self.captureBtn?.backgroundColor = .green
        }
        else {
            // Not recording, but not done saving either...i
            print("Setting video capture button color to yellow")
            self.captureBtn?.backgroundColor = .yellow
        }
        
        // Check if video is done saving
        filterChain.videoDidSave = { result, fileURL in
            print("ViewController -> videoCaptureButtonAction -> filterChain.videoDidSave result:  \(result)")
            if result {
                print("Video Saved Successfully")
            }
            else {
                print("There was a problem saving the video.")
            }
            
            // Update UI elements
            print("Setting video capture button color to red")
            // Put UI updating on the main queue to prevent a delay
            DispatchQueue.main.async {
                self.captureBtn?.backgroundColor = .red
            }
        }
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveVideoSuccessfully(fileURL: URL) {
        print("Complete Saving at URL: \(fileURL)")
    }

}
