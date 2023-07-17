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

func convertCIImageToUIImage(ciImage: CIImage) -> UIImage? {
    let context = CIContext(options: nil)
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
        return nil
    }
    
    let orientation: UIImage.Orientation
    let currentDeviceOrientation = UIDevice.current.orientation
    
    switch currentDeviceOrientation {
    case .portrait:
        orientation = .right
    case .portraitUpsideDown:
        orientation = .left
    case .landscapeLeft:
        orientation = .up
    case .landscapeRight:
        orientation = .down
    default:
        orientation = .right
    }
    
    let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: orientation)
    return uiImage
}
