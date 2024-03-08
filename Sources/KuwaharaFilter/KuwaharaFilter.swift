import UIKit
import Accelerate

enum KuwaharaTypes{
    case basicKuwahara
    case colored
}

extension UIImage {

    
    
    
    func applyKuwahara(type: KuwaharaTypes, size: Int) throws -> UIImage?{
        guard var cgImage = self.cgImage else { return nil }
        
        
        switch type {
        case .basicKuwahara:
            cgImage = try convertColorSpaceToGrayScale(cgImage)
        default:
            cgImage = try convertToRGB(cgImage)
        }
        
        
        var (context, imageData, bytesPerPixel) = try createContextAndData(cgImage: cgImage, width: cgImage.width, height: cgImage.height)
        
        defer{
            imageData.deallocate()
        }
        
        
        baseKuwahara(&imageData, size: size, width: cgImage.width, height: cgImage.height, bytesPerPixel: bytesPerPixel)

        guard let outputCGImage = context.makeImage() else {
                  throw ImageErrors
                      .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
                  
              }
        
        return UIImage(cgImage: outputCGImage, scale: 1, orientation: self.imageOrientation)
    }
}


package func baseKuwahara(_ imageData: inout UnsafeMutablePointer<UInt8>, size: Int, width: Int, height: Int, bytesPerPixel: Int) {
    let quadrant = size / 2
    
    for y in 0..<height {
        for x in 0..<width {
            let top_x = x - (quadrant % 2)
            let top_y = y - (quadrant % 2)
            
            let xPlus = clamp(min: 0, value: x+size, max: width)
            let xMinus = clamp(min: 0, value: x-size, max: width)
            
            let yPlus = clamp(min: 0, value: y+size, max: height)
            let yMinus = clamp(min: 0, value: y-size, max: height)
            
            
            let quadrantA = [indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)...indexCalculator(x: xPlus, y: yPlus, width: width, bytesPerPixel: bytesPerPixel)+3]
            
            let quadrantB = [indexCalculator(x: xMinus, y: y, width: width, bytesPerPixel: bytesPerPixel)...indexCalculator(x: x, y: yPlus, width: width, bytesPerPixel: bytesPerPixel)+3]
            
            let quadrantC = [indexCalculator(x: xMinus, y: yMinus, width: width, bytesPerPixel: bytesPerPixel)...indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)+3]
            
            let quadrantD = [indexCalculator(x: x, y: yMinus, width: width, bytesPerPixel: bytesPerPixel)...indexCalculator(x: xPlus, y: y, width: width, bytesPerPixel: bytesPerPixel)+3]
            
            
            
            
        }
    }
}

package func standartDeviation(arr: ArraySlice<Int>) throws -> Int{
    let expression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue: arr)])
    guard let standardDeviation = expression.expressionValue(with: nil, context: nil) as? Int else { throw ImageErrors.failedToConvertimage(localizedDescription: "StandartDeviation failed") }

    return standardDeviation
}

