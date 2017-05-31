//
//  AVAssetNormalizeOrientation.swift
//  Filterchain
//
//  Created by Ronald Ho on 2017-04-27.
//  Copyright © 2017 Hybridity Media Inc. All rights reserved.
//

import AVFoundation

extension AVAsset {
    
    public func videoOrientation() -> (UIInterfaceOrientation) {
        var orientation: UIInterfaceOrientation = .unknown
        
        let tracks :[AVAssetTrack] = self.tracks(withMediaType: AVMediaTypeVideo)
        if let videoTrack = tracks.first {
            
            let t = videoTrack.preferredTransform
            
            if (t.a == 0 && t.b == 1.0 && t.d == 0) {
                orientation = .portrait
                print("portrait")
            }
            else if (t.a == 0 && t.b == -1.0 && t.d == 0) {
                orientation = .portraitUpsideDown
                print("portrait upside down")
            }
            else if (t.a == 1.0 && t.b == 0 && t.c == 0) {
                orientation = .landscapeRight
                print("landscape right")
            }
            else if (t.a == -1.0 && t.b == 0 && t.c == 0) {
                orientation = .landscapeLeft
                print("landscape left")

            }
        }
        
        return (orientation)
    }
    
    
    func videoOrientationOld() -> (orientation: UIInterfaceOrientation, device: AVCaptureDevicePosition) {
        var orientation: UIInterfaceOrientation = .unknown
        var device: AVCaptureDevicePosition = .unspecified
        
        let tracks :[AVAssetTrack] = self.tracks(withMediaType: AVMediaTypeVideo)
        if let videoTrack = tracks.first {
            
            let t = videoTrack.preferredTransform
            
            if (t.a == 0 && t.b == 1.0 && t.d == 0) {
                orientation = .portrait
                
                if t.c == 1.0 {
                    device = .front
                } else if t.c == -1.0 {
                    device = .back
                }
            }
            else if (t.a == 0 && t.b == -1.0 && t.d == 0) {
                orientation = .portraitUpsideDown
                
                if t.c == -1.0 {
                    device = .front
                } else if t.c == 1.0 {
                    device = .back
                }
            }
            else if (t.a == 1.0 && t.b == 0 && t.c == 0) {
                orientation = .landscapeRight
                
                if t.d == -1.0 {
                    device = .front
                } else if t.d == 1.0 {
                    device = .back
                }
            }
            else if (t.a == -1.0 && t.b == 0 && t.c == 0) {
                orientation = .landscapeLeft
                
                if t.d == 1.0 {
                    device = .front
                } else if t.d == -1.0 {
                    device = .back
                }
            }
        }
        
        return (orientation, device)
    }
}
