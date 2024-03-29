//Created by Lugalu on 10/03/24.

import UIKit
import KuwaharaFilter



class ViewController: UIViewController, ImageReciever {
    
    var currentImage: UIImage? = UIImage(named: "testImage") {
        didSet{
            imgView.image = currentImage
        }
    }     
    
    var newImage: UIImage? {
        set{
            currentImage = newValue
        }
        get {
            currentImage
        }
    }
    
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
        label.numberOfLines = 1
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
    
    let ciToggle = CustomToggleComponent()
    
    let confirmButton: UIButton = {
        let button = UIButton(configuration: .borderedTinted())

        button.setTitle("Confirm", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton(configuration: .borderedTinted())
        button.role = .destructive
        button.tintColor = .systemRed
        button.setTitle("Reset Image", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        positionLabel(self.windowSizeSlider)
    }
    
    //TODO: Add the picker!
    func setup(){
        imgView.image = currentImage
        addViews()
        addConstraints()
        prepareActions()
        makeNavigation()
        
        ciToggle.configure(withTitle: "Use CIFilter?")
        kuwaharaPicker.delegate = self
        kuwaharaPicker.dataSource = self
        
        
    }
    
    func positionLabel(_ sender: UISlider){
        let trackRect = sender.trackRect(forBounds: sender.frame)
        let thumbRect = sender.thumbRect(forBounds: sender.bounds, trackRect: trackRect, value: sender.value)
        self.sliderLabel.center = CGPoint(x: thumbRect.midX, y: sender.frame.origin.y - 8)
    }
   
    
    func getImage(image: CIImage, size: Int, type: KuwaharaTypes) throws -> UIImage {
        guard var filter = CIFilter(name:"Kuwahara") else {
            throw ImageErrors.failedToOutputImage(localizedDescription: "Filter Creation Failed")
        }
        
        filter.setValue(image, forKey: "inputImage")
        filter.setValue(size, forKey: "inputKernelSize")
        filter.setValue(type, forKey: "inputKernelType")
        
        guard let out = filter.outputImage else {
            throw ImageErrors.failedToOutputImage(localizedDescription: "Filter output is missing")
        }
        guard let cg = CIContext().createCGImage(out, from: out.extent) else {
            throw ImageErrors.failedToOutputImage(localizedDescription: "CIContext failed to create CGImage")
        }
        
        return UIImage(cgImage: cg)
    }
    
    func getImage(image: UIImage, size: Int, type: KuwaharaTypes) throws -> UIImage? {
        return try image.applyKuwahara(type: type, size: size)
    }

}

