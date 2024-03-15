//Created by Lugalu on 14/03/24.

import UIKit
import PhotosUI

extension ViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let item = results.first else {
            return
        }
        
        if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
            item.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                guard error == nil, let image =  image as? UIImage else {
                    return
                } // since is a sample I don't care
                DispatchQueue.main.async {
                    self.currentImage = image
                    picker.dismiss(animated: true)
                }
                
            }
        }
        
    }
    
    
    func makeNavigation(){
        let galleryAction = UIAction(){ _ in
            let gallery = GalleryComponent.shared
            if gallery.requestStatus() {
                let view = gallery.getView(self)
                view.delegate = self
                self.present(view, animated: true)
            }
        }
        let galleryBtn = UIBarButtonItem(image: UIImage(systemName: "photo"), primaryAction: galleryAction)
        
        //let photosBtn = UIBarButtonItem(systemItem: .camera)
        
        self.navigationItem.rightBarButtonItem = galleryBtn
        
    }
    
    
    func handleGallery(){
        
    }
    
    
    
}
