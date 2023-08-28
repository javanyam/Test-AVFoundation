//
//  getImageOrientation.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/12.
//

import UIKit

func getImageOrientation() -> UIImage.Orientation {
    let currentDevice: UIDevice = UIDevice.current
    let orientation: UIDeviceOrientation = currentDevice.orientation
    var imageOrientation: UIImage.Orientation
    
    switch orientation {
    case .portrait:
        imageOrientation = .right
    case .landscapeLeft:
        imageOrientation = .up
    case .landscapeRight:
        imageOrientation = .down
    case .portraitUpsideDown:
        imageOrientation = .left 
    default:
        imageOrientation = .right
    }
    
    return imageOrientation
}
