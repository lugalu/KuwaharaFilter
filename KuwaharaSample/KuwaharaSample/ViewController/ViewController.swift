//Created by Lugalu on 10/03/24.

import UIKit
import KuwaharaFilter

class ViewController: UIViewController {
    
    var currentImage: UIImage? = UIImage(named: "testImage")
    
    let imgView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.borderColor = UIColor.green.cgColor
        image.layer.borderWidth = 2
        
        return image
    }()
    
    
    let sliderLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    let windowSizeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 50
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    let kuwaharaPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        return picker
    }()
    
    
    let confirmButton: UIButton = {
        let button = UIButton(configuration: .borderedTinted())

        button.setTitle("Confirm", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    
    //TODO: Add the picker!
    func setup(){
        imgView.image = currentImage
        addViews()
        addConstraints()
        prepareActions()
        
        kuwaharaPicker.delegate = self
        kuwaharaPicker.dataSource = self
        
    }
   


}

