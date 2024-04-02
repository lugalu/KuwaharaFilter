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
            guard let view = gallery.getView(self) else { 
                return
            }

            self.present(view, animated: true)
        }
        
        let galleryBtn = UIBarButtonItem(image: UIImage(systemName: "photo"), primaryAction: galleryAction)
        
        let saveAction = UIAction(){ _ in
            let gallery = GalleryComponent.shared
            
            guard let img = self.viewReceiverDelegate?.get() else {
                return
            }
            
            gallery.saveImageToGallery(img: img)
            
        }
        
        let saveBtn = UIBarButtonItem(systemItem: .save, primaryAction: saveAction)
        
        self.navigationItem.rightBarButtonItems = [galleryBtn, saveBtn]
        
        let resetAction = UIAction { _ in
            self.viewReceiverDelegate?.update(image: self.currentImage)
        }
        
        let resetBtn = UIBarButtonItem(systemItem: .undo, primaryAction: resetAction)
        resetBtn.tintColor = .systemRed
        
        self.navigationItem.leftBarButtonItem = resetBtn
        
        self.navigationItem.title = "Kuwahara"
        self.navigationItem.largeTitleDisplayMode = .never
        
    }
   
    
}
