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
        imageOrientation = .right // 시뮬레이터에서는 .right로 설정해야 실제 장치의 세로 방향에 맞게 됩니다.
    case .landscapeLeft:
        imageOrientation = .up
    case .landscapeRight:
        imageOrientation = .down
    case .portraitUpsideDown:
        imageOrientation = .left // 시뮬레이터에서는 .left로 설정해야 실제 장치의 세로 방향에 맞게 됩니다.
    default:
        imageOrientation = .right
    }
    
    return imageOrientation
}
