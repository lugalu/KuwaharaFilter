//Created by Lugalu on 14/03/24.

import CoreImage

fileprivate extension KuwaharaTypes {
    func getKernel() -> String {
        switch self {
        case .basic:
            return BasicKuwahara
        case .Generalized:
            return GeneralizedKuwahara
        case .Polynomial:
            return PolynomialKuwahara
        case .Anisotropic:
            return AnisotropicKuwahara
        }
    }
}

public class Kuwahara: CIFilter {
    @objc dynamic var inputImage: CIImage?
    /** Kernel Matrix around each pixel, should be 2<=n, note that higher values take more time to compute.*/
    @objc dynamic var inputKernelSize: Int = 2
    /** The operation to be used, read the enum cases for a general explanation. */
    @objc dynamic var inputKernelType: KuwaharaTypes = .basic
    /** if image should become grayscale. */
    @objc dynamic var inputIsGrayscale: Bool = false
    /** Defines the overlap between 2 sectors of kuwahara, should be 0.01 <= n <= 2. affects Polynomial and Anisotropic*/
    @objc dynamic var inputZeroCross: Float = 0.58
    /** Image Hardness, should be between 1 <= n <= 100. affects Polynomial */
    @objc dynamic var inputHardness: Float = 100
    /** Image Sharpness, should be 1 <= n <= 18. affects all except for basic.*/
    @objc dynamic var inputSharpness: Float = 18
    /** Blur prepass, should be 1 <= n <= 6. affects Anisotropic.*/
    @objc dynamic var inputBlurRadius: Int = 2
    /** Kernel Angle  prepass, should be 0.1 <= n <= 2. affects Anisotropic */
    @objc dynamic var inputAngle: Float = 1
    
 
    private var kernel: CIKernel {
        return CIKernel(source: BaseKernelCode + inputKernelType.getKernel()) ?? CIKernel()
    }
        
    public override var outputImage : CIImage? {
            get {
                guard var input = inputImage else {
                    return nil
                }
                let callback: CIKernelROICallback = {_,rect in
                    return rect
                }
                
                if inputIsGrayscale {
                    let filter = CIFilter(name: "CIColorMonochrome")
                    filter?.setValue(input, forKey: "inputImage")
                    filter?.setValue(CIColor(red: 0.7, green: 0.7, blue: 0.7), forKey: "inputColor")
                    filter?.setValue(1.0, forKey: "inputIntensity")
                    
                    guard let out = filter?.outputImage else { return nil }
                    input = out
                }
                
                var args: [Any] = [input, inputKernelSize]
                
                switch inputKernelType {
                case .basic:
                    break
                case .Generalized:
                    guard let url = Bundle.module.url(forResource: "blackSquare", withExtension: "jpg"),
                          let ciBase = CIImage(contentsOf: url) else {
                        return nil
                    }
                    let sectorPrePass = PreSectorPass.apply(extent: ciBase.extent, roiCallback: callback, arguments: [ciBase])
                    let gaussPrePass = PreGaussianPass.apply(extent: ciBase.extent, roiCallback: callback, arguments: [sectorPrePass!])
                    
                    args.insert(gaussPrePass as Any, at: 1)
                    args.append(inputSharpness)
                    
                case .Polynomial:
                    args.append(contentsOf: [inputZeroCross, inputHardness, inputSharpness])
                    
                case .Anisotropic:

                    let tensor = PreTensorPass.apply(extent: input.extent, roiCallback: callback, arguments: [input])
                    let blur = PreHorizontalBlur.apply(extent: input.extent, roiCallback: callback, arguments: [tensor as Any, inputBlurRadius])
                    let anisotropic = PreAnisotropyPass.apply(extent: input.extent, roiCallback: callback, arguments: [blur as Any,inputBlurRadius])
                    args.insert(anisotropic as Any, at: 1)
                    args.append(contentsOf: [inputAngle,inputZeroCross, inputSharpness])
                }
                
                let out = kernel.apply(extent: input.extent,
                                                roiCallback: callback,
                                                 arguments: args)
                return out
            }
        }
}











//MARK: Key-Value coding compliance methods
extension Kuwahara {
    public override var attributes: [String : Any] {
         return [
             kCIAttributeFilterDisplayName: "Kuwahara",

             "inputImage": [kCIAttributeIdentity: 0,
                            kCIAttributeClass: "CIImage",
                            kCIAttributeDisplayName: "Image",
                            kCIAttributeType: kCIAttributeTypeImage],

             "inputKernelSize": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "NSNumber",
                                 kCIAttributeDisplayName: "kernelSize",
                                 kCIAttributeDefault: 2,
                                 kCIAttributeMin: 2,
                                 kCIAttributeType: kCIAttributeTypeScalar],
             
             "inputKernelType": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "KuwaharaTypes",
                                 kCIAttributeDisplayName: "Kernel type",
                                 kCIAttributeDefault: KuwaharaTypes.basic],
             
             "inputIsGrayscale": [kCIAttributeIdentity: 0,
                                 kCIAttributeClass: "Bool",
                                 kCIAttributeDisplayName: "is Grayscale",
                                 kCIAttributeDefault: false,
                                 kCIAttributeDefault: kCIAttributeTypeBoolean],
             
             "inputZeroCross": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "NSNumber",
                                kCIAttributeDisplayName: "Zero Crossing value",
                                kCIAttributeDefault: 0.58,
                                kCIAttributeMin: 0.01,
                                kCIAttributeMax: 2,
                                kCIAttributeDefault: kCIAttributeTypeScalar],
             
             "inputHardness": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDisplayName: "Hardness value",
                               kCIAttributeDefault: 100,
                               kCIAttributeMin: 1,
                               kCIAttributeMax: 100,
                               kCIAttributeDefault: kCIAttributeTypeScalar],
             
             "inputSharpness": [kCIAttributeIdentity: 0,
                              kCIAttributeClass: "NSNumber",
                              kCIAttributeDisplayName: "Sharpness value",
                              kCIAttributeDefault: 15,
                              kCIAttributeMin: 0,
                              kCIAttributeMax: 18,
                              kCIAttributeDefault: kCIAttributeTypeScalar],
             "inputBlurRadius": [kCIAttributeIdentity: 0,
                                    kCIAttributeClass: "NSNumber",
                                    kCIAttributeDisplayName: "Blur Radius",
                                    kCIAttributeDefault: 2,
                                    kCIAttributeMin: 1,
                                    kCIAttributeMax: 6,
                                    kCIAttributeDefault: kCIAttributeTypeScalar],
             "inputAngle": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDisplayName: "Anisotropic angle value",
                               kCIAttributeDefault: 1,
                                 kCIAttributeMin: 0.1,
                               kCIAttributeMax: 2,
                               kCIAttributeDefault: kCIAttributeTypeScalar]
         ]
     }
    
    
    public override func setValue(_ value: Any?, forKey key: String) {
        switch key {
        case "inputImage":
            inputImage = value as? CIImage
            
        case "inputKernelSize":
            guard let kernelSize = value as? NSNumber else {
                return
            }
            inputKernelSize = Int(truncating: kernelSize)
            
        case "inputKernelType":
            guard let type = value as? KuwaharaTypes else {
                return
            }
            inputKernelType = type
            
        case "inputIsGrayscale":
            guard let type = value as? Bool else {
                return
            }
            inputIsGrayscale = type
            
        case "inputZeroCross":
            guard let type = value as? NSNumber else {
                return
            }
            inputZeroCross = Float(truncating: type)
            
        case "inputHardness":
            guard let type = value as? NSNumber else {
                return
            }
            inputHardness = Float(truncating: type)
            
        case "inputSharpness":
            guard let type = value as? NSNumber else {
                return
            }
            inputSharpness = Float(truncating: type)
            
        case "inputBlurRadius":
            guard let type = value as? NSNumber else {
                return
            }
            inputBlurRadius = Int(truncating: type)
            
        case "inputAngle":
            guard let type = value as? NSNumber else {
                return
            }
            inputAngle = Float(truncating: type)
            
            default:
                break
        }
    }
    
    public override class func value(forKey key: String) -> Any? {
        return switch key {
        case "inputImage":
            nil
            
        case "inputKernelSize":
            2
            
        case "inputIsGrayscale":
            false
      
        case "inputKernelType":
            KuwaharaTypes.basic
            
        case "inputZeroCross":
            0.58
          
            
        case "inputHardness":
            100
            
        case "inputQuality":
            18
            
        case "inputBlurRadius":
            2
        
        case "inputAngle":
            1
            
        default:
            nil
        }
    }
}
