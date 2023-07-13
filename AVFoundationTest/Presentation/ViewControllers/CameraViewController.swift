//
//  CameraViewController.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/10.
//

import UIKit
import SnapKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    
    private var takePicture = false
    private var isBackCamera = true
    
    private var captureFrontDevice: AVCaptureDevice!
    private var captureBackDevice: AVCaptureDevice!
    private var backCameraInput: AVCaptureDeviceInput!
    private var frontCameraInput: AVCaptureDeviceInput!
    private var session: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput!
    private var videoConnection: AVCaptureConnection!
    
    private var cameraView: CameraView!
    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSession()
        addCameraView()
    }
}

extension CameraViewController {
    
    //MARK: - Add View
    private func addCameraView() {
        cameraView = CameraView()
        
        view.addSubview(cameraView)
        
        cameraView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension CameraViewController {
    
    //MARK: - Function
    private func setSession() {
        do {
            session = AVCaptureSession()
            
            guard let session = session else { return }
            
            session.beginConfiguration()
            
            setDeviceInput(session: session)
            setVideoDataOutput(session: session)
            
            session.commitConfiguration()
            
            session.startRunning()
            
            setPreviewLayer(session: session)
        }
    }
    
    private func setDeviceInput(session: AVCaptureSession) {
        captureBackDevice = getDevice(in: .back)
        captureFrontDevice = getDevice(in: .front)
        
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
    
    private func setPreviewLayer(session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = self.view.frame
        self.view.layer.addSublayer(previewLayer)
    }
    
    private func moveToPictureViewController(image: UIImage) {
        let pictureViewController = PictureViewController(image: image)
        pictureViewController.modalPresentationStyle = .fullScreen
        pictureViewController.modalTransitionStyle = .crossDissolve
        self.present(pictureViewController, animated: true)
    }
    
    private func setTorch() {
        cameraView.torchButton.setImage(captureBackDevice.torchMode == .on ? customImage(.flash_on) : customImage(.flash_off), for: .normal)
    }
    
    private func setZoom() {
        
    }
    
    //MARK: - Selector
    @objc func switchTorch(_ sender: UIButton) {
        if captureBackDevice.hasTorch, isBackCamera {
            do {
                try captureBackDevice.lockForConfiguration()
                
                if captureBackDevice.torchMode == .off {
                    captureBackDevice.torchMode = .on
                }
                else {
                    captureBackDevice.torchMode = .off
                }
                
                setTorch()
                
                captureBackDevice.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    @objc func switchZoom(_ sender: UIButton) {
        if let device = captureBackDevice {
            let zoomOutScale = 1.0
            let zoomInScale = 2.0
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = device.videoZoomFactor == zoomInScale ? zoomOutScale : zoomInScale
                
            } catch {
                return
            }
            device.unlockForConfiguration()
            
            cameraView.zoomButton.setImage(device.videoZoomFactor == zoomInScale ? customImage(.zoom_in) : customImage(.zoom_out), for: .normal)
        }
    }
    
    @objc func switchCameraInput(_ sender: UIButton) {
        cameraView.transitionButton.isUserInteractionEnabled = false
        
        guard let session = session else { return }
        
        session.beginConfiguration()
        if isBackCamera {
            session.removeInput(backCameraInput)
            session.addInput(frontCameraInput)
            cameraView.torchButton.isHidden = true
            cameraView.zoomButton.isHidden = true
            isBackCamera = false
        } else {
            session.removeInput(frontCameraInput)
            session.addInput(backCameraInput)
            cameraView.torchButton.isHidden = false
            cameraView.zoomButton.isHidden = false
            isBackCamera = true
        }
        videoOutput.connections.first?.videoOrientation = .portrait
        videoOutput.connections.first?.isVideoMirrored = !isBackCamera
        
        session.commitConfiguration()
        
        cameraView.transitionButton.isUserInteractionEnabled = true
    }
    
    @objc func handlePinchCamera(_ pinch: UIPinchGestureRecognizer) {
        if let device = captureBackDevice {
            
            var initialScale: CGFloat = device.videoZoomFactor
            let minAvailableZoomScale = 1.0
            let maxAvailableZoomScale = 5.0
            
            do {
                try device.lockForConfiguration()
                if (pinch.state == UIPinchGestureRecognizer.State.began) {
                    initialScale = device.videoZoomFactor
                }
                else {
                    if (initialScale * (pinch.scale) < minAvailableZoomScale) {
                        device.videoZoomFactor = minAvailableZoomScale
                    }
                    else if (initialScale * (pinch.scale) > maxAvailableZoomScale) {
                        device.videoZoomFactor = maxAvailableZoomScale
                    }
                    else {
                        device.videoZoomFactor = initialScale * (pinch.scale)
                    }
                }
                pinch.scale = 1.0
            } catch {
                return
            }
            device.unlockForConfiguration()
        }
    }
    
    @objc func tapVideoCapture(_ sender: UIButton) {
        takePicture = !takePicture
    }
    
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    //MARK: - Delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if !takePicture {
            return
        }
        
        self.session!.stopRunning()
        
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        self.takePicture = false
        
        DispatchQueue.main.async { [self] in
            var uiImage: UIImage
            let ciImage = CIImage(cvImageBuffer: cvBuffer)
            
            let imageOrientation = getImageOrientation()
            
            if let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) {
                uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: imageOrientation)
            } else {
                uiImage = UIImage(ciImage: ciImage, scale: 1.0, orientation: imageOrientation)
            }
            
            moveToPictureViewController(image: uiImage)
        }
    }
}
