//Created by Lugalu on 02/04/24.

import UIKit

extension KuwaharaView {
    func addViews(){
        addSubview(imgView)
        addSubview(parametersScroll)
        
        parametersScroll.addSubview(typeSegment)
        parametersScroll.addSubview(grayToggle)
        parametersScroll.addSubview(kernelSlider)
        parametersScroll.addSubview(zeroCrossSlider)
        parametersScroll.addSubview(hardnessSlider)
        parametersScroll.addSubview(sharpnessSlider)
        parametersScroll.addSubview(blurSlider)
        parametersScroll.addSubview(angleSlider)
        
        addSubview(confirmButton)
    }
    
    func addConstraints(){
        addImageViewConstraints()
        addConfirmButtonConstraints()
        addScrollConstraints()
        addToggleConstraints()
        addKernelConstraints()
        addZeroCrossConstraints()
        addHardnessConstraints()
        addSharpnessConstraints()
        addBlurConstraints()
        addAngleConstraints()
    }
    
    private func addImageViewConstraints() {
        let constraints = [
            imgView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            imgView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            imgView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
            imgView.heightAnchor.constraint(equalToConstant: 200)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addScrollConstraints(){
        let constraints = [
            parametersScroll.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            parametersScroll.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            parametersScroll.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 8),
            parametersScroll.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -8 )
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    
    private func addSegmentConstraints() {
        let constraints = [
            typeSegment.leadingAnchor.constraint(equalTo: parametersScroll.leadingAnchor),
            typeSegment.trailingAnchor.constraint(equalTo: parametersScroll.trailingAnchor),
            typeSegment.topAnchor.constraint(equalTo: parametersScroll.topAnchor),
            typeSegment.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addToggleConstraints() {
        let constraints = [
            grayToggle.leadingAnchor.constraint(equalTo: parametersScroll.leadingAnchor),
            grayToggle.trailingAnchor.constraint(equalTo: parametersScroll.trailingAnchor),
            grayToggle.topAnchor.constraint(equalTo: typeSegment.bottomAnchor, constant: 8),
            grayToggle.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addKernelConstraints() {
        let constraints = [
            kernelSlider.leadingAnchor.constraint(equalTo: parametersScroll.leadingAnchor),
            kernelSlider.trailingAnchor.constraint(equalTo: parametersScroll.trailingAnchor),
            kernelSlider.topAnchor.constraint(equalTo: grayToggle.bottomAnchor, constant: 8),
            kernelSlider.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addZeroCrossConstraints() {
        let constraints = [
            zeroCrossSlider.leadingAnchor.constraint(equalTo: parametersScroll.leadingAnchor),
            zeroCrossSlider.trailingAnchor.constraint(equalTo: parametersScroll.trailingAnchor),
            zeroCrossSlider.topAnchor.constraint(equalTo: kernelSlider.bottomAnchor, constant: 8),
            zeroCrossSlider.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addHardnessConstraints() {
        let constraints = [
            hardnessSlider.leadingAnchor.constraint(equalTo: parametersScroll.leadingAnchor),
            hardnessSlider.trailingAnchor.constraint(equalTo: parametersScroll.trailingAnchor),
            hardnessSlider.topAnchor.constraint(equalTo: zeroCrossSlider.bottomAnchor, constant: 8),
            hardnessSlider.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addSharpnessConstraints() {
        let constraints = [
            sharpnessSlider.leadingAnchor.constraint(equalTo: parametersScroll.leadingAnchor),
            sharpnessSlider.trailingAnchor.constraint(equalTo: parametersScroll.trailingAnchor),
            sharpnessSlider.topAnchor.constraint(equalTo: hardnessSlider.bottomAnchor, constant: 8),
            sharpnessSlider.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    private func addBlurConstraints() {
        let constraints = [
            blurSlider.leadingAnchor.constraint(equalTo: parametersScroll.leadingAnchor),
            blurSlider.trailingAnchor.constraint(equalTo: parametersScroll.trailingAnchor),
            blurSlider.topAnchor.constraint(equalTo: sharpnessSlider.bottomAnchor, constant: 8),
            blurSlider.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addAngleConstraints() {
        let constraints = [
            angleSlider.leadingAnchor.constraint(equalTo: parametersScroll.leadingAnchor),
            angleSlider.trailingAnchor.constraint(equalTo: parametersScroll.trailingAnchor),
            angleSlider.topAnchor.constraint(equalTo: blurSlider.bottomAnchor, constant: 8),
            angleSlider.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addConfirmButtonConstraints() {
        let constraints = [
            confirmButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            confirmButton.leadingAnchor.constraint(equalTo:  imgView.leadingAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: imgView.trailingAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
