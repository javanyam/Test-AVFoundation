//
//  CameraView.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/11.
//

import UIKit
import SnapKit

class CameraView: UIView {
    
    private var torchStatus = false
    private var zoomStatus = false
    
    private var stackView: UIStackView!
    var torchButton: UIButton!
    var zoomButton: UIButton!
    private var cameraButton: UIButton!
    var transitionButton: UIButton!
    
    var testButton: UIButton!
    
    //MARK: - Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addStackView()
        addCameraButton()
        addTransitionButton()
        
        addTestButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CameraView {
    
    //MARK: - Add View
    private func addStackView() {
        stackView = UIStackView()
        stackView.spacing = 40
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(15)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        torchButton = makeButton(image: torchStatus ? customImage(.flash_on) : customImage(.flash_off), selector: #selector(tapTorchButton))
        zoomButton = makeButton(image: zoomStatus ? customImage(.zoom_in) : customImage(.zoom_out), selector: #selector(tapZoomButton))
        
        stackView.addArrangedSubview(torchButton)
        stackView.addArrangedSubview(zoomButton)
    }
    
    private func makeButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        button.snp.makeConstraints {
            $0.width.height.equalTo(44)
        }
        
        return button
    }
  
    private func addCameraButton() {
        cameraButton = UIButton()
        cameraButton.setImage(customImage(.camera_full), for: .normal)
        cameraButton.layer.cornerRadius = 40
        cameraButton.clipsToBounds = true
        cameraButton.addTarget(self, action: #selector(tapVideoCapture), for: .touchUpInside)
        
        addSubview(cameraButton)
        
        cameraButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(50)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
    }
    
    private func addTransitionButton() {
        transitionButton = UIButton()
        transitionButton.setImage(customImage(.transition), for: .normal)
        transitionButton.addTarget(self, action: #selector(switchCameraInput), for: .touchUpInside)
        
        addSubview(transitionButton)
        
        transitionButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.right.equalToSuperview().inset(50)
            $0.centerY.equalTo(cameraButton.snp.centerY)
        }
    }
    
    private func addTestButton() {
        testButton = UIButton()
        testButton.backgroundColor = .systemYellow
        testButton.addTarget(self, action: #selector(tapUltraButton), for: .touchUpInside)
        
        addSubview(testButton)
        
        testButton.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.left.equalToSuperview().inset(50)
            $0.centerY.equalTo(cameraButton.snp.centerY)
        }
        
    }
}

extension CameraView {
    
    //MARK: - Selector
    @objc private func tapTorchButton(_ sender: UIButton) {
        guard let superView = superview,
              let superViewController = superView.next as? CameraViewController else { return }
        
        superViewController.switchTorch(sender)
    }
    
    @objc private func tapZoomButton(_ sender: UIButton) {
        guard let superView = superview,
              let superViewController = superView.next as? CameraViewController else { return }
        
        superViewController.switchZoom(sender)
    }
    
    @objc private func tapVideoCapture(_ sender: UIButton) {
        guard let superView = superview,
              let superViewController = superView.next as? CameraViewController else { return }
        
        superViewController.tapVideoCapture(sender)
    }
    
    @objc private func switchCameraInput(_ sender: UIButton) {
        guard let superView = superview,
              let superViewController = superView.next as? CameraViewController else { return }
        
        superViewController.switchCameraInput(sender)
    }
    
    @objc private func tapUltraButton(_ sender: UIButton) {
        guard let superView = superview,
              let superViewController = superView.next as? CameraViewController else { return }
        
        superViewController.tapUltraButton(sender)
    }
}
