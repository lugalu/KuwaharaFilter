//Created by Lugalu on 14/03/24.

import UIKit
import AVFoundation


protocol ImageReciever: UIViewController {
    var newImage: UIImage? {get set}
}

class CameraComponent{
    enum CameraErrors: LocalizedError{
        case CameraAccessDenied
        case cannotFindDevice
        case cannotAddInput
        case cannotAddOutput
        
        var errorDescription: String?{
            switch self {
            case .CameraAccessDenied:
                return "User camera is denied or restricted."
            case .cannotFindDevice:
                return "Cannot find specified device"
            case .cannotAddInput:
                return "Cannot add input to current session "
            case .cannotAddOutput:
                return "Cannot add output to current session"
            }
        }
        
    }
    
    
    static let shared = CameraComponent()
    
    private init() {}
    
    func start(delegate: ImageReciever?,
               _ device: AVCaptureDevice.DeviceType = .builtInWideAngleCamera,
               _ mediaType: AVMediaType = .video,
               _ position: AVCaptureDevice.Position = .back,
               _ preset: AVCaptureSession.Preset = .photo) throws {
        
        guard getAuthorization() else { throw CameraErrors.CameraAccessDenied }
        
        let session = try makeSession(device,mediaType,position, preset)
        let view = CameraViewController(delegate: delegate)
        view.videoPreviewLayer.session = session
        
        if let navigation = delegate?.navigationController{
            navigation.pushViewController(view, animated: true)
        }else{
            delegate?.present(view, animated: true)
        }
        
        
        
        
        
    }
    
    private func getAuthorization() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .notDetermined:
            var isAuthorized = false
            AVCaptureDevice.requestAccess(for: .video){ auth in
                isAuthorized = auth
            }
            return isAuthorized
            
        case .restricted, .denied:
            return false
            
        case .authorized:
            return true
            
        @unknown default:
            return false
        }
    }
    
    
    private func makeSession(_ device: AVCaptureDevice.DeviceType,
                             _ mediaType: AVMediaType,
                             _ position: AVCaptureDevice.Position,
                             _ preset: AVCaptureSession.Preset) throws -> AVCaptureSession {
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(device, for: mediaType, position: position) else{
            throw CameraErrors.cannotFindDevice
        }
        
        let input = try AVCaptureDeviceInput(device: videoDevice)
        
        guard session.canAddInput(input) else {
            throw CameraErrors.cannotAddInput
        }
        
        session.addInput(input)
        
       
        let output = AVCapturePhotoOutput()
        
        guard session.canAddOutput(output) else {
            throw CameraErrors.cannotAddOutput
        }
        session.sessionPreset = preset
        session.addOutput(output)
        session.commitConfiguration()
        
        return session
    }
    
}
