//Created by Lugalu on 12/03/24.

import UIKit
import KuwaharaFilter

extension ViewController{

    func addViews(){
        view.addSubview(imgView)
        view.addSubview(sliderLabel)
        view.addSubview(windowSizeSlider)
        view.addSubview(kuwaharaPicker)
        view.addSubview(confirmButton)
    }
    
    func addConstraints(){
        addImageViewConstraints()
        addSliderConstraints()
        addPickerConstraints()
        addButtonConstraints()
    }
    
    func prepareActions() {
        createButtonAction()
        createSliderAction()
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
    
    
    private func addButtonConstraints(){
        let constraints = [
            confirmButton.topAnchor.constraint(equalTo: kuwaharaPicker.bottomAnchor, constant: 16),
            confirmButton.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func createButtonAction(){
        let buttonAction = UIAction(title: "Confirm"){ _ in
            
            //TODO: Wait for complete metal support in Swift packages.
            guard let baseImage = self.currentImage,
                  let image = baseImage.ciImage ?? CIImage(image: baseImage),
                  let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": image as Any, "inputKernelSize": Int(self.windowSizeSlider.value)]) else {
                print("didn't work")
                return
            }
            
           
            let out = filter.outputImage
            
            DispatchQueue.main.async {
                guard let out = out else {
                    return
                }
                
                self.imgView.image = UIImage(ciImage: out)
            }

//            let sliderValue = self.windowSizeSlider.value
//            let image = self.currentImage
//            
//            let selectionIdx = self.kuwaharaPicker.selectedRow(inComponent: 0)
//            let kuwaharaType = KuwaharaTypes(rawValue: selectionIdx) ?? .basicKuwahara
//            DispatchQueue.global().async {
//                do{
//                    
//                    let img = try image?.applyKuwahara(type: kuwaharaType, size: Int(sliderValue))
//                    
//                    DispatchQueue.main.async {
//                        self.imgView.image = img
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                    fatalError("OPS")
//
//                }
//            }
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
    

}






