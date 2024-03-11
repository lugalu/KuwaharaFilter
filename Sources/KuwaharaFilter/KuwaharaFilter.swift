import UIKit
import Accelerate

public enum KuwaharaTypes{
    case basicKuwahara
    case colored
}

public extension UIImage {
    
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
        
        
        try baseKuwahara(&imageData, size: size, width: cgImage.width, height: cgImage.height, bytesPerPixel: bytesPerPixel)

        guard let outputCGImage = context.makeImage() else {
                  throw ImageErrors
                      .failedToRetriveCGImage(localizedDescription: "makeImage Failed to create an CGImage! Please generate an issue in the github repository with the image.")
                  
              }
        
        return UIImage(cgImage: outputCGImage, scale: 1, orientation: self.imageOrientation)
    }
}


package func baseKuwahara(_ imageData: inout UnsafeMutablePointer<UInt8>, size: Int, width: Int, height: Int, bytesPerPixel: Int) throws {
    
    #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
    #endif
    let size = size
    //TODO: Remove the Coercion this is just to simplify the reduction of space during debug!
    DispatchQueue.concurrentPerform(iterations: Int(Double(height) )) { y in
        DispatchQueue.concurrentPerform(iterations: Int(Double(width) )) { x in
                    autoreleasepool {
                        let meanResult = CalculateKuwahara(x: x, y: y, size: size, width: width, height: height, imageData: imageData, bytesPerPixel: bytesPerPixel)
                        let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
                        imageData[index] = UInt8(clamping: meanResult)
                    }
                }
            }
        
    
    #if DEBUG
        print("Kuwaraha: \(CFAbsoluteTimeGetCurrent() - start)")
    #endif
}

package func CalculateKuwahara(x: Int, y: Int, size: Int, width: Int, height: Int, imageData: UnsafeMutablePointer<UInt8>, bytesPerPixel: Int) -> Int {
    let xPlus = clamp(min: 0, value: x + size, max: width)
    let xMinus = clamp(min: 0, value: x - size, max: width)
    
    let yPlus = clamp(min: 0, value: y + size, max: height)
    let yMinus = clamp(min: 0, value: y - size, max: height)
    
    let quadrantA = getArrSlice(x1: x, x2: xPlus, y1: y, y2: yPlus, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationA = standardDeviation(arr: quadrantA)

    let quadrantB = getArrSlice(x1: xMinus, x2: x, y1: y, y2: yPlus, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationB = standardDeviation(arr: quadrantB )

    let quadrantC = getArrSlice(x1: xMinus, x2: x, y1: yMinus, y2: y, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationC = standardDeviation(arr: quadrantC )
    
    let quadrantD = getArrSlice(x1: x, x2: xPlus, y1: yMinus, y2: y, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationD = standardDeviation(arr: quadrantD )
    
    var minDeviation = min(deviationA, deviationB, deviationC, deviationD)

    var meanResult: Int
    switch minDeviation{
    case deviationA:
        meanResult = mean(arr: quadrantA)
    case deviationB:
        meanResult = mean(arr: quadrantB)
    case deviationC:
        meanResult = mean(arr: quadrantC)
    case deviationD:
        meanResult = mean(arr: quadrantD)
    default:
        //throw ImageErrors.failedToOutputImage(localizedDescription: "Error calculating deviation")
        fatalError("Error calculating Deviation")
    }
  
    return meanResult
}

package func standardDeviation(arr: Array<Int>)  -> Double {
    let expression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue: arr)])
    let standardDeviation = expression.expressionValue(with: nil, context: nil)
    guard let standardDeviation = standardDeviation as? Double else {
        print(standardDeviation ?? "Standart Deviation is Null")
        fatalError("Standart Deviation Failed remove this later")
        //throw ImageErrors.failedToConvertimage(localizedDescription: "StandartDeviation failed")
    }
    return standardDeviation
}
package func mean(arr: Array<Int>) -> Int {
    return arr.reduce(0, +) / arr.count
}

package func getArrSlice(x1: Int, x2: Int, y1: Int, y2: Int, width:Int, bytesPerPixel: Int,arr: UnsafeMutablePointer<UInt8>) -> Array<Int> {
    var newArr : [UInt8] = []
    
    for i in y1...y2 {
        for j in x1...x2 {
            let idx = indexCalculator(x: j, y: i, width: width, bytesPerPixel: bytesPerPixel)
            newArr.append(arr[idx])
        }
    }
    
    return newArr.map { Int($0) }
}




