//
//  Preview.swift
//  AVFoundationTest
//
//  Created by SNAPTAG on 2023/07/17.
//

import UIKit
import SnapKit
import AVFoundation

class PreviewView: UIView {

    private var preview: AVCaptureVideoPreviewLayer!
    private var session: AVCaptureSession!
    private var viewController: UIViewController!

    //MARK: - Initialize
    convenience init(viewController: UIViewController, session: AVCaptureSession) {
        self.init()
        self.session = session
        self.viewController = viewController

        addPreview()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PreviewView {

    //MARK: - Add View
    private func addPreview() {
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.connection?.videoOrientation = .portrait
        preview.frame = viewController.view.frame
        
        viewController.view.layer.addSublayer(preview)
    }
}
