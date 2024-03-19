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
            
            guard let img = self.imgView.image else { 
                return
            }
            
            gallery.saveImageToGallery(img: img)
            
        }
        
        let saveBtn = UIBarButtonItem(systemItem: .save, primaryAction: saveAction)
        
        //let photosBtn = UIBarButtonItem(systemItem: .camera)
        
        self.navigationItem.rightBarButtonItems = [galleryBtn, saveBtn]
        
    }	
   
    
}
