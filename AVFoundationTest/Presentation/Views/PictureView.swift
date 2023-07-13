//
//  PictureView.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/11.
//

import UIKit
import SnapKit

class PictureView: UIView {
    
    private var image: UIImage!
    private var imageView: UIImageView!
    private var retakeButton: UIButton!
    private var savePhotoButton: UIButton!
    
    //MARK: - Initialize
    convenience init(image: UIImage) {
        self.init()
        self.image = image
        
        addImageView()
        addRetakeButton()
        addSaveButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PictureView {
    
    //MARK: - Add View
    private func addImageView() {
        imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(100)
        }
    }
    
    private func addRetakeButton() {
        retakeButton = UIButton()
        retakeButton.setTitle(textSetting(.retake), for: .normal)
        retakeButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        retakeButton.tintColor = .white
        retakeButton.sizeToFit()
        retakeButton.addTarget(self, action: #selector(reloadCamera), for: .touchUpInside)
        
        addSubview(retakeButton)
        
        retakeButton.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
            $0.left.equalToSuperview().offset(10)
            $0.height.equalTo(50)
        }
    }
    
    private func addSaveButton() {
        savePhotoButton = UIButton()
        savePhotoButton.setTitle(textSetting(.save), for: .normal)
        savePhotoButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        savePhotoButton.tintColor = .white
        savePhotoButton.sizeToFit()
        savePhotoButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        
        addSubview(savePhotoButton)
        
        savePhotoButton.snp.makeConstraints {
            $0.top.equalTo(retakeButton.snp.top)
            $0.right.equalToSuperview().inset(10)
            $0.height.equalTo(50)
        }
    }
}

extension PictureView {
    
    //MARK: - Selector
    @objc private func reloadCamera() {
        guard let superView = superview,
              let superViewController = superView.next as? PictureViewController else { return }
        
        superViewController.reloadCamera()
    }
    
    @objc private func savePhoto() {
        guard let superView = superview,
              let superViewController = superView.next as? PictureViewController else { return }
        
        superViewController.savePhoto()
    }
}
