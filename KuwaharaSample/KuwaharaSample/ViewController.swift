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
    
    lazy var windowSizeSlider: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 1
        slider.maximumValue = 50
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        slider.addAction(UIAction(){ _ in
            self.windowSizeSlider.value = round(self.windowSizeSlider.value)
            self.sliderLabel.text = "\(Int(self.windowSizeSlider.value))"
        }, for: .valueChanged)
        
        return slider
    }()
    
    lazy var confirmButton: UIButton = {
        let action = UIAction(title: "Confirm"){ _ in
            let sliderValue = self.windowSizeSlider.value
            let image = self.currentImage
            DispatchQueue.global().async {
                do{
                    
                    let img = try image?.applyKuwahara(type: .colored, size: Int(sliderValue))
                    
                    DispatchQueue.main.async {
                        self.imgView.image = img
                    }
                } catch {
                    print(error.localizedDescription)
                    fatalError("OPS")

                }
            }
        }
        let button = UIButton(configuration: .bordered(),primaryAction: action)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    func setup(){
        imgView.image = currentImage
        addViews()
        addImageViewConstraints()
        addLabelConstraints()
        addSliderConstraints()
        addButtonConstraints()
    }
    
    func addViews(){
        view.addSubview(imgView)
        view.addSubview(sliderLabel)
        view.addSubview(windowSizeSlider)
        view.addSubview(confirmButton)
    }
    
    private func addImageViewConstraints(){
        let constraints = [
            imgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            imgView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            imgView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            imgView.heightAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    private func addLabelConstraints() {
        let constraints = [
            sliderLabel.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 16),
            sliderLabel.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            sliderLabel.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addSliderConstraints(){
        let constraints = [
            windowSizeSlider.topAnchor.constraint(equalTo: sliderLabel.bottomAnchor, constant: 8),
            windowSizeSlider.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            windowSizeSlider.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addButtonConstraints(){
        let constraints = [
            confirmButton.topAnchor.constraint(equalTo: windowSizeSlider.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

}

