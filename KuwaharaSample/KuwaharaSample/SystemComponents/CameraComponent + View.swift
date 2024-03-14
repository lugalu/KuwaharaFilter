//Created by Lugalu on 14/03/24.

import UIKit
import AVFoundation

extension CameraComponent{
    class CameraPreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    class CameraViewController: UIViewController{
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return view.layer as! AVCaptureVideoPreviewLayer
        }
        
        var delegate: ImageReciever?
        
        init(delegate: ImageReciever?){
            self.delegate = delegate
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        override func loadView() {
            view = CameraPreviewView()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            videoPreviewLayer.session?.startRunning()
        }
    }
    
    
    
}
