import UIKit
import Accelerate

public enum KuwaharaTypes: Int, CaseIterable{
    case basicKuwahara
    case colored
    
    public func getTitle() -> String{
        return switch self {
        case .basicKuwahara:
            "B&W Kuwahara"
        case .colored:
            "Colored Kuwahara"
        }
    }
}

public extension UIImage {
    /*
     WARNING: DO NOT USE, this is for learning purposes only, if you want to use Kuwahara, use the CIFilter variant.
     */
    func applyKuwahara(type: KuwaharaTypes, size: Int) throws -> UIImage?{
        guard size > 1 else { return self }
        guard var cgImage = self.cgImage else { return nil }
        
        var filter: kuwaharaFilterFunc = basicKuwaharaRoutine
        switch type {
        case .basicKuwahara:
            cgImage = try convertColorSpaceToGrayScale(cgImage)
            filter = basicKuwaharaRoutine
        case .colored:
            cgImage = try convertToRGB(cgImage)
            filter = coloredKuwaharaRoutine
        }
        
        
        var (context, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage, width: cgImage.width, height: cgImage.height)
        
        defer{
            imageData.deallocate()
        }
        
        
        try baseKuwahara(&imageData, size: size, width: cgImage.width, height: cgImage.height, bytesPerPixel: bytesPerPixel, filter: filter)

        guard let outputCGImage = context.makeImage() else {
                  throw ImageErrors
                      .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
                  
              }
        
        return UIImage(cgImage: outputCGImage, scale: 1, orientation: self.imageOrientation)
    }
}

package typealias kuwaharaFilterFunc = (Int,Int,Int,Int,Int,Int,inout UnsafeMutablePointer<UInt8>) throws -> Void
package func baseKuwahara(_ imageData: inout UnsafeMutablePointer<UInt8>, size: Int, width: Int, height: Int, bytesPerPixel: Int, filter: kuwaharaFilterFunc) throws {
    
    #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
    #endif
    let size = size
    var imageError: Error?
    let iterations = 8
    
    DispatchQueue.concurrentPerform(iterations: iterations) { i in
        let fixed = height / iterations
        let lowBound = i * fixed
        let highBound = lowBound + fixed
        
        for y in lowBound..<highBound {
            for x in 0..<width {
                autoreleasepool {
                    do {
                      try filter(x, y, size, width, height, bytesPerPixel,&imageData)
                    } catch {
                        objc_sync_enter(error as Any)
                        imageError = error
                        objc_sync_exit(error as Any)
                        return
                    }
                }
            }
        }
    }
        
    
    #if DEBUG
        print("Kuwaraha: \(CFAbsoluteTimeGetCurrent() - start)")
    #endif
    
    if let error = imageError {
        throw error
    }
}








