//
//  G8Filter.swift
//  Filterchain
//
//  Created by Ronald Ho on 2017-03-20.
//  Copyright © 2017 Hybridity Media Inc. All rights reserved.
//

import UIKit

protocol G8FilterProtocol {
    var name: String { get set }
//    var thumbnail: UIImage { get set }
//    var parameters: [String: String] { get set }
    var needsClock: Bool { get set }
    
    func updateParameter(filter:String, value: Float)
//    func updateShader()
}


class G8FilterSuper: NSObject {
    
//    //Default properties
//    var name: String?
//    var thumbnail: UIImage?
//    var parameters: [String: String]?
//    var needsClock: Bool = false
    
    
//    //Update Parameter (Public Method)
//    
//    public func updateParameter(filter:String){
//        
//    }
    
    //Private function to modify the actual shader
    
//    func updateShader(){
//        preconditionFailure("Method must be overridden")
//    }
 
    
    
}
