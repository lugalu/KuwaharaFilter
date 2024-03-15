//Created by Lugalu on 14/03/24.

import Foundation
import UIKit

public class Kuwahara: CIFilter{
    var inputImage: CIImage?
    var inputKernelSize: Int = 2
    
    static var kernel: CIKernel = { () -> CIKernel in
        
        guard let url = Bundle.module.url(forResource: "Kuwahara", withExtension: "ci.metal") else {
            print("bundle url doens't exist")
            return CIKernel()
        }
                let data = try! Data(contentsOf: url)
        
        return try! CIKernel(functionName: "grayKuwahara",fromMetalLibraryData: data)
    }()
    
    
    
    public override var attributes: [String : Any] {
         return [
             kCIAttributeFilterDisplayName: "Kuwahara",

             "inputImage": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIImage",
                            kCIAttributeDisplayName: "Image",
                            kCIAttributeType: kCIInputImageKey],

             "inputKernelSize": [kCIAttributeIdentity: 0,
                                       kCIAttributeClass: "NSNumber",
                                       kCIAttributeDisplayName: "Kernelsize",
                                       kCIAttributeDefault: 2,
                                       kCIAttributeMin: 2,
                                       kCIAttributeType: kCIAttributeTypeScalar]
         ]
     }
    
    
    public override func setValue(_ value: Any?, forKey key: String) {
        switch key {
            case "inputImage":
            inputImage = value as? CIImage
            case "inputKernelSize":
                inputKernelSize = value as! Int
            default:
                break
        }
    }
    
    public override var outputImage : CIImage? {
            get {
                guard let input = inputImage else {
                    return nil
                }
                let callback: CIKernelROICallback = {_,_ in
                    return CGRectNull
                }
                
                let out = Kuwahara.kernel.apply(extent: input.extent,
                                                roiCallback: callback,
                                                 arguments: [input, inputKernelSize])
                return out
            }
        }
}
