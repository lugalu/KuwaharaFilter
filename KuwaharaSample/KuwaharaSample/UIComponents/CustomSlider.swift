//Created by Lugalu on 01/04/24.

import UIKit

class CustomSlider: UIView {
    enum SliderProperties{
        case minValue
        case defaultValue
        case maxValue
        case titleLabel
        case titleLabelColor
        case sliderStep
        case useColors
        case normalUpperBound
        case warningUpperBound
        case normalColor
        case warningColor
        case dangerColor
    }
    
    var isEnabled:Bool{
        set{
            slider.isEnabled = newValue
            titleLabel.isEnabled = newValue
            sliderLabel.isEnabled = newValue
        }
        get{
            return slider.isEnabled
        }
    }
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    let sliderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    let slider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    var sliderStep: Float = 1
    var useColors: Bool = true
    var normalUpperBound: Float = 1
    var normalColor: UIColor = .label
    var warningUpperBound: Float = 2
    var warningColor: UIColor = .systemYellow
    var dangerColor: UIColor = .systemRed
    
    init(){
        super.init(frame: .zero)
        basicSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func basicSetup(){
        self.addSubview(titleLabel)
        self.addSubview(slider)
        self.addSubview(sliderLabel)
        self.translatesAutoresizingMaskIntoConstraints = false
        makeConstraints()
        makeActions()
    }
    
    public func getValue() -> Float {
        return slider.value
    }

    
    private func positionLabel(_ sender: UISlider) {
        let trackRect = sender.trackRect(forBounds: slider.frame)
        let thumbRect = sender.thumbRect(forBounds: slider.bounds, trackRect: trackRect, value: slider.value)
        self.sliderLabel.center = CGPoint(x: thumbRect.midX, y: slider.frame.origin.y - 8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionLabel(slider)
    }
    
    private func makeConstraints() {
        let titleConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(titleConstraints)
        
        let sliderConstraints = [
            slider.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            slider.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            slider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            slider.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)
        ]
        
        NSLayoutConstraint.activate(sliderConstraints)
    }
    
    
    private func makeActions() {
        let sliderAction = UIAction{ _ in
            
            let value = ceil(self.slider.value * self.sliderStep) / self.sliderStep
            self.slider.value = value
            self.sliderLabel.text = "\(value)"
            self.positionLabel(self.slider)
            if self.useColors {
                self.sliderLabel.textColor = {
                    if value <= self.normalUpperBound {
                        return self.normalColor
                    }else if value <= self.warningUpperBound {
                        return self.warningColor
                    }
                    return self.dangerColor
                    
                }()
            }
        }
        
        slider.addAction(sliderAction, for: .valueChanged)
    }

    
    public func configure(parameters params: [SliderProperties: Any]) {
        params.forEach{ key, value in
            switch key {
            case .minValue:
                guard let value = value as? NSNumber else {
                    return
                }
                self.slider.minimumValue = Float(truncating: value)
                
            case .defaultValue:
                guard let value = value as? NSNumber else { return }
                self.slider.value = Float(truncating: value)
                
            case .maxValue:
                guard let value = value as? NSNumber else {
                    return
                }
                self.slider.maximumValue = Float(truncating: value)
                
            case .titleLabel:
                guard let value = value as? String else { return }
                self.titleLabel.text = value
                
            case .titleLabelColor:
                guard let value = value as? UIColor else { return }
                self.titleLabel.textColor = value
                
            case .sliderStep:
                guard let value = value as? NSNumber else { return }
                self.sliderStep = Float(truncating: value)
                
            case .useColors:
                guard let value = value as? Bool else { return }
                self.useColors = value
                
            case .normalUpperBound:
                guard let value = value as? NSNumber else { return }
                self.normalUpperBound = Float(truncating: value)
                
            case .warningUpperBound:
                guard let value = value as? NSNumber else { return }
                self.warningUpperBound = Float(truncating: value)
                
            case .normalColor:
                guard let value = value as? UIColor else { return }
                self.normalColor = value
                self.sliderLabel.textColor = value
                
            case .warningColor:
                guard let value = value as? UIColor else { return }
                self.warningColor = value
                
            case .dangerColor:
                guard let value = value as? UIColor else { return }
                self.dangerColor = value
            }
        }
        self.positionLabel(self.slider)
        self.sliderLabel.text = "\(slider.value)"
    }
    
}
