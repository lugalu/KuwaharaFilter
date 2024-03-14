//Created by Lugalu on 14/03/24.

import UIKit
import Photos
import PhotosUI

class GalleryComponent {
    static let shared = GalleryComponent()
    private init(){}
    
    func requestStatus() -> Bool {
        var status = PHPhotoLibrary.authorizationStatus()
        
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite){ newStatus in
                status = newStatus
            }
        }
        
        switch status {
        case .notDetermined,.restricted, .denied:
            return true
        case .authorized, .limited:
            return true
        @unknown default:
            return false
        }
    }
    
    func getView(_ delegate: PHPickerViewControllerDelegate) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        
        config.filter = PHPickerFilter.any(of: [.images])
        config.preferredAssetRepresentationMode = .current
        config.selection = .default
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = delegate
        
        
        return picker
    }
    
    
}
