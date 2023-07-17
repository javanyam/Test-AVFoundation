//
//  CameraViewModel.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/17.
//

import UIKit
import AVFoundation

class CaptureSession: NSObject {
    
    private var isBackCamera = true
    
    private var discoverySession: AVCaptureDevice.DiscoverySession!
    var captureFrontDevice: AVCaptureDevice!
    var captureBackDevice: AVCaptureDevice!
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    var session: AVCaptureSession!
    var videoOutput: AVCaptureVideoDataOutput!
    var videoConnection: AVCaptureConnection!
    private var sampleBuffer: CMSampleBuffer!
    var uiImage: UIImage!
    
    static let shared = CaptureSession()
}

extension CaptureSession {
    
    //MARK: - Function
    func setSession() {
        do {
            session = AVCaptureSession()
            
            session.beginConfiguration()
            
            setDeviceInput(session: session)
            setVideoDataOutput(session: session)
            
            session.commitConfiguration()
            
            session.startRunning()
        }
    }
    
    private func setDeviceInput(session: AVCaptureSession) {
        captureBackDevice = bestDevice(in: .back)
        captureFrontDevice = bestDevice(in: .front)
        
        guard let backCameraDeviceInput = try? AVCaptureDeviceInput(device: captureBackDevice) else {
            fatalError("후면 카메라로 인풋설정이 불가능합니다.")
        }
        backCameraInput = backCameraDeviceInput
        if !session.canAddInput(backCameraInput) {
            fatalError("후면 카메라 설치가 되지 않습니다.")
        }
        
        guard let frontCameraDeviceInput = try? AVCaptureDeviceInput(device: captureFrontDevice) else {
            fatalError("전면 카메라로 인풋설정이 불가능합니다.")
        }
        frontCameraInput = frontCameraDeviceInput
        if !session.canAddInput(frontCameraInput) {
            fatalError("전면 카메라 설치가 되지 않습니다.")
        }
        
        session.addInput(backCameraInput)
        setInitialZoomFactor(for: captureBackDevice)
    }
    
    private func setInitialZoomFactor(for device: AVCaptureDevice?) {
        guard let device = device else { return }
        
        do {
            try device.lockForConfiguration()
            
            if device.deviceType != .builtInWideAngleCamera {
                device.videoZoomFactor = 2.0
            } else {
                device.videoZoomFactor = 1.0
            }
            
            device.unlockForConfiguration()
        } catch {
            print("got error")
        }
    }
    
    private func setVideoDataOutput(session: AVCaptureSession) {
        let queue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        session.addOutput(videoOutput)
        
        videoConnection = videoOutput.connection(with: .video)
    }
    
    //MARK: - Selector
    @objc func tapVideoCapture(_ sender: UIButton) {
        session.stopRunning()
        
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: cvBuffer)
        
        uiImage = convertCIImageToUIImage(ciImage: ciImage)
    }
}

extension CaptureSession: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //MARK: - Delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        self.sampleBuffer = sampleBuffer
    }
}
