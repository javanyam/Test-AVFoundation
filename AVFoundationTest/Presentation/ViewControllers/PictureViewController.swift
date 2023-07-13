//
//  PictureViewController.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/10.
//

import UIKit
import SnapKit
import Photos

class PictureViewController: UIViewController {
    
    private var image: UIImage!
    private var pictureView: PictureView!
    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        config()
    }
    
    //MARK: - Initialize
    convenience init(image: UIImage) {
        self.init()
        self.image = image
    }
}

extension PictureViewController {
    
    //MARK: - Configure
    private func config() {
        pictureView = PictureView(image: image)
        
        view.addSubview(pictureView)
        
        pictureView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension PictureViewController {
    
    //MARK: - Function
    private func moveToCameraViewController() {
        let cameraViewController = CameraViewController()
        cameraViewController.modalPresentationStyle = .fullScreen
        cameraViewController.modalTransitionStyle = .crossDissolve
        self.present(cameraViewController, animated: true)
    }
    
    //MARK: - Selector
    @objc func reloadCamera() {
        moveToCameraViewController()
    }
    
    @objc func savePhoto() {
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            guard status == .authorized else { return }
            
            PHPhotoLibrary.shared().performChanges({
                let creationRequest = PHAssetCreationRequest.forAsset()
                guard let imageData = self.image.pngData() else { return }
                creationRequest.addResource(with: .photo, data: imageData, options: nil)
            })
        }
        
        moveToCameraViewController()
    }
}
