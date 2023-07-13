//
//  Images.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/11.
//

import UIKit

enum CustomImage: String {
    case transition = "transition"
    case camera_full = "camera_full"
    case camera_empty = "camera_empty"
    case flash_on = "flash_on"
    case flash_off = "flash_off"
    case zoom_in = "zoom_in"
    case zoom_out = "zoom_out"
}

//MARK: - 이미지 호출 함수
func customImage(_ name: CustomImage) -> UIImage {
    return UIImage(named: name.rawValue) ?? UIImage(named: "transition")!
}
