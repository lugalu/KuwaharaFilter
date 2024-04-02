//Created by Lugalu on 02/04/24.

import UIKit
import KuwaharaFilter

protocol KuwaharaViewDelegate {
    func onConfirmAction()
}

protocol KuwaharaViewRecieverDelegate: UIView {
    func update(image: UIImage?)
    func get() -> UIImage?
    func getParameters() -> [String:Any]
}

class KuwaharaView: UIView, KuwaharaViewRecieverDelegate {
    var delegate: KuwaharaViewDelegate?
    
    let imgView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.borderColor = UIColor.green.cgColor
        image.layer.borderWidth = 2
        
        return image
    }()
    
    let parametersScroll: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.layer.masksToBounds = false
        return scroll
    }()

    let typeSegment: UISegmentedControl = {
        let seg = UISegmentedControl()
        for i in KuwaharaTypes.allCases{
            seg.insertSegment(withTitle: i.getTitle(), at: i.rawValue, animated: false)
        }
        
        seg.selectedSegmentIndex = 0
        seg.translatesAutoresizingMaskIntoConstraints = false
        
        return seg
    }()
    
    let kernelSlider: CustomSlider = {
        var slider = CustomSlider()
        slider.configure(parameters: [.minValue: 2, .maxValue: 40, .sliderStep: 1, .normalUpperBound: 15, .warningUpperBound: 30, .titleLabel: "Kernel Size"])
        return slider
    }()
    
    let grayToggle: CustomToggleComponent = {
        let toggle = CustomToggleComponent()
        toggle.configure(withTitle: "is Gray?", isOn: false)
        return toggle
    }()
    
    let zeroCrossSlider: CustomSlider = {
        var slider = CustomSlider()
        slider.configure(parameters: [.minValue: 0.01, .maxValue: 2, .defaultValue: 0.58, .sliderStep: 10, .useColors: false, .titleLabel: "Zero Cross"])
        return slider
    }()
    
    let hardnessSlider: CustomSlider = {
        var slider = CustomSlider()
        slider.configure(parameters: [.minValue: 1, .maxValue: 100, .defaultValue: 100, .useColors: false, .titleLabel: "hardness"])
        return slider
    }()
    
    let sharpnessSlider: CustomSlider = {
        var slider = CustomSlider()
        slider.configure(parameters: [.minValue: 1, .maxValue: 18, .defaultValue: 18, .useColors: false, .titleLabel: "sharpness"])
        return slider
    }()
    
    let blurSlider: CustomSlider = {
        var slider = CustomSlider()
        slider.configure(parameters: [.minValue: 1, .maxValue: 6, .defaultValue: 2, .useColors: false, .titleLabel: "Blur"])
        return slider
    }()
    
    let angleSlider: CustomSlider = {
        var slider = CustomSlider()
        slider.configure(parameters: [.minValue: 0.01, .maxValue: 2, .defaultValue: 1, .sliderStep: 10, .useColors: false, .titleLabel: "Angle"])
        return slider
    }()
    
    let confirmButton: UIButton = {
        let button = UIButton(configuration: .borderedTinted())

        button.setTitle("Apply", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    init(delegate: KuwaharaViewDelegate?){
        super.init(frame: .zero)
        self.delegate = delegate
        setup()
    }    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup(){
        addViews()
        addConstraints()
        makeActions()
        ToggleParams()
    }
    
    func makeActions(){
        let confirmAction = UIAction{ _ in
            self.delegate?.onConfirmAction()
            self.confirmButton.isEnabled = false
        }
        
        confirmButton.addAction(confirmAction, for: .touchUpInside)
        
        let segmentAction = UIAction { _ in
            self.ToggleParams()
        }
        
        typeSegment.addAction(segmentAction, for: .valueChanged)
    }
    
    
    func ToggleParams() {
        guard let type = KuwaharaTypes(rawValue: typeSegment.selectedSegmentIndex) else {
            return
        }
        
        switch type {
        case .basic:
            zeroCrossSlider.isEnabled = false
            hardnessSlider.isEnabled = false
            sharpnessSlider.isEnabled = false
            blurSlider.isEnabled = false
            angleSlider.isEnabled = false
        case .Generalized:
            zeroCrossSlider.isEnabled = false
            hardnessSlider.isEnabled = false
            sharpnessSlider.isEnabled = true
            blurSlider.isEnabled = false
            angleSlider.isEnabled = false
        case .Polynomial:
            zeroCrossSlider.isEnabled = true
            hardnessSlider.isEnabled = true
            sharpnessSlider.isEnabled = true
            blurSlider.isEnabled = false
            angleSlider.isEnabled = false
        case .Anisotropic:
            zeroCrossSlider.isEnabled = true
            hardnessSlider.isEnabled = false
            sharpnessSlider.isEnabled = true
            blurSlider.isEnabled = true
            angleSlider.isEnabled = true
        }
        
    }
    
    
    func update(image: UIImage?) {
        DispatchQueue.main.async {
            self.imgView.image = image
            self.confirmButton.isEnabled = true
        }
    }
    
    func get() -> UIImage?{
        return imgView.image
    }
    
    func getParameters() -> [String:Any]{
        var dict: [String: Any] = [:]
        dict["inputKernelSize"] = kernelSlider.getValue()
        dict["inputKerneltype"] = KuwaharaTypes(rawValue: typeSegment.selectedSegmentIndex)
        dict["inputisGrayscale"] = grayToggle.getValue()
        dict["inputZeroCross"] = zeroCrossSlider.getValue()
        dict["inputHardness"] = hardnessSlider.getValue()
        dict["inputSharpness"] = sharpnessSlider.getValue()
        dict["inputBlurRadius"] = blurSlider.getValue()
        dict["inputAngle"] = angleSlider.getValue()
        
        return dict
    }
    
    
    
    
}
