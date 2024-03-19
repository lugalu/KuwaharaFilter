//Created by Lugalu on 12/03/24.

import UIKit
import KuwaharaFilter

extension ViewController{

    func addViews(){
        view.addSubview(imgView)
        view.addSubview(sliderLabel)
        view.addSubview(windowSizeSlider)
        view.addSubview(kuwaharaPicker)
        view.addSubview(ciToggle)
        view.addSubview(confirmButton)
        view.addSubview(resetButton)
    }
    
    func addConstraints(){
        addImageViewConstraints()
        addSliderConstraints()
        addPickerConstraints()
        addToggleConstraints()
        addResetButtonConstraints()
        addConfirmButtonConstraints()
    }
    
    func prepareActions() {
        createConfirmButtonAction()
        createSliderAction()
        createResetButtonAction()
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
    
    private func addSliderConstraints(){
        let constraints = [
            windowSizeSlider.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 24),
            windowSizeSlider.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            windowSizeSlider.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addPickerConstraints(){
        let constraints = [
            kuwaharaPicker.topAnchor.constraint(equalTo: windowSizeSlider.bottomAnchor, constant: 16),
            kuwaharaPicker.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            kuwaharaPicker.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
            kuwaharaPicker.heightAnchor.constraint(equalToConstant: 100)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addToggleConstraints(){
        let constraints = [
            ciToggle.topAnchor.constraint(equalTo: kuwaharaPicker.bottomAnchor, constant: 16),
            ciToggle.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            ciToggle.trailingAnchor.constraint(equalTo: imgView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    
    private func addResetButtonConstraints(){
        let constraints = [
            resetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            resetButton.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addConfirmButtonConstraints(){
        let constraints = [
            confirmButton.bottomAnchor.constraint(equalTo: resetButton.topAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func createConfirmButtonAction(){
        let buttonAction = UIAction(title: "Confirm"){ _ in
            guard let baseImage = self.currentImage else {
                return
            }
            
            let kernelSize = Int(self.windowSizeSlider.value)
            let selectionIdx = self.kuwaharaPicker.selectedRow(inComponent: 0)
            let kuwaharaType = KuwaharaTypes(rawValue: selectionIdx)!
            let isCI = self.ciToggle.retrieveValue()
            
            var out: UIImage?
            do{
                if isCI{
                    guard let img = baseImage.ciImage ?? CIImage(image: baseImage) else {
                        return
                    }
                    
                    out = try self.getImage(image: img, size: kernelSize, type: kuwaharaType)
                    DispatchQueue.main.async {
                        self.imgView.image = out
                    }
                }else{
                    DispatchQueue.global().async{
                        out = try? self.getImage(image: baseImage, size: kernelSize, type: kuwaharaType)
                        
                        DispatchQueue.main.async {
                            self.imgView.image = out
                        }
                    }
                }
            }catch{
                fatalError(error.localizedDescription)
            }
        }
        
        confirmButton.addAction(buttonAction, for: .primaryActionTriggered)
    }
    
    
    func createSliderAction() {
        let action =  UIAction(){ _ in
            let value = round(self.windowSizeSlider.value)
            self.windowSizeSlider.value = value
            self.sliderLabel.text = "\(Int(value))"
            self.sliderLabel.textColor = {
                if value < 6 {
                    UIColor.label
                }else if value < 10 {
                    UIColor.yellow
                }else{
                    UIColor.red
                }
            }()
            
            self.positionLabel(self.windowSizeSlider)
        }
        
        self.windowSizeSlider.addAction(action, for: .valueChanged)
    }
    
    func createResetButtonAction(){
        let buttonAction = UIAction(title: "Reset"){ _ in
            self.imgView.image = self.currentImage
        }
        
        resetButton.addAction(buttonAction, for: .primaryActionTriggered)
    }
    

}






