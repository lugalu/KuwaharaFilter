//Created by Lugalu on 10/03/24.

import UIKit
import KuwaharaFilter



class ViewController: UIViewController, KuwaharaViewDelegate {

    lazy var currentImage: UIImage? = nil {
        didSet{
            viewReceiverDelegate?.update(image: currentImage)
        }
    }
    var viewReceiverDelegate: KuwaharaViewRecieverDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    func setup(){
        let v = KuwaharaView(delegate: self)
        self.view = v
        self.viewReceiverDelegate = v
        makeNavigation()
        self.view.backgroundColor = UIColor(named: "Background")
        
        
    }
    
    func onConfirmAction() {
        guard let baseImg = self.currentImage,
              let img = baseImg.ciImage ?? CIImage(image: baseImg),
              var params = self.viewReceiverDelegate?.getParameters() else {
            self.viewReceiverDelegate?.update(image: self.currentImage)
            return
        }
        
        DispatchQueue.global().async {

            
            params["inputImage"] = img
            
            guard let filter = CIFilter(name: "Kuwahara", parameters: params),
                  let CIOut = filter.outputImage else {
                self.viewReceiverDelegate?.update(image: self.currentImage)
                return
            }
            let out = UIImage(ciImage: CIOut)
            self.viewReceiverDelegate?.update(image: out)
            
        }
    }
}

