//
//  CameraViewController.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/10.
//

import UIKit
import SnapKit
import Photos

class CameraViewController: UIViewController {
    
    private var isBackCamera = true
    
    private var previewView: PreviewView!
    private var cameraView: CameraView!
    private var captureSession = CaptureSession.shared
    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }
}

extension CameraViewController {
    
    //MARK: - Configure
    private func config() {
        captureSession.setSession()
        addPreviewLayer()
        addCameraView()
        addPinchGesture()
    }
    
    //MARK: - Add View
    private func addPreviewLayer() {
        previewView = PreviewView(session: captureSession.session)
        previewView.preview.frame = view.frame
        
        view.layer.addSublayer(previewView.preview)
    }
    
    private func addCameraView() {
        cameraView = CameraView()
        
        view.addSubview(cameraView)
        
        cameraView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func addPinchGesture() {
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchCamera(_:)))
        self.view.addGestureRecognizer(pinch)
    }
}

extension CameraViewController {
    
    //MARK: - Function
    private func setTorch() {
        cameraView.torchButton.setImage(captureSession.captureBackDevice.torchMode == .on ? customImage(.flash_on) : customImage(.flash_off), for: .normal)
    }
    
    private func setZoom() {
        cameraView.zoomButton.setImage(captureSession.captureBackDevice.videoZoomFactor == 2.0 ? customImage(.zoom_in) : customImage(.zoom_out), for: .normal)
    }
    
    private func moveToPictureViewController(image: UIImage) {
        let pictureViewController = PictureViewController(image: image)
        pictureViewController.modalPresentationStyle = .fullScreen
        pictureViewController.modalTransitionStyle = .crossDissolve
        self.present(pictureViewController, animated: true)
    }
    
    //MARK: - Selector
    @objc func handlePinchCamera(_ pinch: UIPinchGestureRecognizer) {
        guard let device = captureSession.captureBackDevice else { return }
        
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
    
    @objc func switchTorch(_ sender: UIButton) {
        guard let device = captureSession.captureBackDevice else { return }
        
        if device.hasTorch, isBackCamera {
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .off {
                    device.torchMode = .on
                }
                else {
                    device.torchMode = .off
                }
                
                setTorch()
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    @objc func switchZoom(_ sender: UIButton) {
        if let device = captureSession.captureBackDevice,
           device.deviceType == .builtInDualWideCamera {
            let zoomOutScale = 2.0
            let zoomInScale = 3.0
            
            do {
                try device.lockForConfiguration()
                device.ramp(toVideoZoomFactor: device.videoZoomFactor == zoomInScale ? zoomOutScale : zoomInScale, withRate: 2.0)
            } catch {
                return
            }
            device.unlockForConfiguration()
            
            setZoom()
        }
    }
    
    @objc func switchCameraInput(_ sender: UIButton) {
        cameraView.transitionButton.isUserInteractionEnabled = false
        guard let session = captureSession.session else { return }
        
        session.beginConfiguration()
        if isBackCamera {
            session.removeInput(captureSession.backCameraInput)
            session.addInput(captureSession.frontCameraInput)
            cameraView.torchButton.isHidden = true
            cameraView.zoomButton.isHidden = true
            isBackCamera = false
            captureSession.videoOutput.connections.first?.videoOrientation = .portrait
        } else {
            session.removeInput(captureSession.frontCameraInput)
            session.addInput(captureSession.backCameraInput)
            cameraView.torchButton.isHidden = false
            cameraView.zoomButton.isHidden = false
            isBackCamera = true
        }
        
        captureSession.videoOutput.connections.first?.isVideoMirrored = !isBackCamera
        
        session.commitConfiguration()
        
        cameraView.transitionButton.isUserInteractionEnabled = true
    }
    
    @objc func tapVideoCapture(_ sender: UIButton) {
        captureSession.tapVideoCapture(isBack: isBackCamera)
        moveToPictureViewController(image: captureSession.uiImage)
    }
}
