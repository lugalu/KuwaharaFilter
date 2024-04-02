//Created by Lugalu on 19/03/24.

import UIKit

class CustomToggleComponent: UIView {
    
    var isEnabled:Bool{
        set{
            toggle.isEnabled = newValue
            label.isEnabled = newValue
        }
        get{
            return toggle.isEnabled
        }
    }
    
    let label: UILabel = {
        var label = UILabel()
        label.textAlignment = .left
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: 374, height: 100)
    }
    
    func configure(withTitle title: String, isOn: Bool = true){
        label.text = title
        toggle.isOn = isOn
        
        self.addSubview(label)
        self.addSubview(toggle)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            label.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -16),
      
            toggle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func getValue() -> Bool{
        return toggle.isOn
    }

}
