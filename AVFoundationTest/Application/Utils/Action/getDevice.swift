//
//  getDevice.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/11.
//

import UIKit
import AVFoundation

func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
    var deviceTypes: [AVCaptureDevice.DeviceType]!

    if #available(iOS 11.1, *) {
        deviceTypes = [.builtInTrueDepthCamera, .builtInTelephotoCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera]
    } else {
        deviceTypes = [.builtInDualCamera, .builtInWideAngleCamera]
    }

    let discoverySession = AVCaptureDevice.DiscoverySession(
        deviceTypes: deviceTypes,
        mediaType: .video,
        position: .unspecified
    )

    let devices = discoverySession.devices
    guard !devices.isEmpty else { fatalError("Missing capture devices.")}

    return devices.first(where: { device in device.position == position })!
}
