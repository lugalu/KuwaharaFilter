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
    
    func getView(_ delegate: PHPickerViewControllerDelegate) -> PHPickerViewController? {
        guard self.requestStatus() else { return nil }
        var config = PHPickerConfiguration(photoLibrary: .shared())
        
        config.filter = PHPickerFilter.any(of: [.images])
        config.preferredAssetRepresentationMode = .current
        config.selection = .default
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = delegate
        
        
        return picker
    }
    
    func saveImageToGallery(img:UIImage) {
        ImageSaver().writeToPhotoAlbum(image: img)
    }
    
    class ImageSaver: NSObject {
        func writeToPhotoAlbum(image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
        }

        @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error {
                print(error)
                return
            }
            
            print("Save finished!")
        }
    }
    
    
}
