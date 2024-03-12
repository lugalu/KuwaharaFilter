//Created by Lugalu on 12/03/24.

import UIKit
import KuwaharaFilter

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return KuwaharaTypes.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return KuwaharaTypes.allCases[row].getTitle()
    }
    
    
}
