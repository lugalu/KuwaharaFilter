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
    DispatchQueue.concurrentPerform(iterations: height) { y in
        DispatchQueue.concurrentPerform(iterations: width) { x in
                    autoreleasepool {
                        let meanResult = CalculateKuwahara(x: x, y: y, size: size, width: width, height: height, imageData: imageData, bytesPerPixel: bytesPerPixel)
                        let index = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
                        imageData[index] = UInt8(clamping: meanResult)
                    }
                }
            }
        
    
    #if DEBUG
        print("Convert Color Space to Gray total time: \(CFAbsoluteTimeGetCurrent() - start)")
    #endif
}

package func CalculateKuwahara(x: Int, y: Int, size: Int, width: Int, height: Int, imageData: UnsafeMutablePointer<UInt8>, bytesPerPixel: Int) -> Int{
    let xPlus = clamp(min: 0, value: x+size, max: width)
    let xMinus = clamp(min: 0, value: x-size, max: width)
    
    let yPlus = clamp(min: 0, value: y+size, max: height)
    let yMinus = clamp(min: 0, value: y-size, max: height)
    
    let quadrantA = getArrSlice(start: indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel),
                                end: indexCalculator(x: xPlus, y: yPlus, width: width, bytesPerPixel: bytesPerPixel) + 1,
                                arr: imageData)
    let deviationA = standardDeviation(arr:  quadrantA)

    
    let quadrantB = getArrSlice(start: indexCalculator(x: xMinus, y: y, width: width, bytesPerPixel: bytesPerPixel),
                                end: indexCalculator(x: x, y: yPlus, width: width, bytesPerPixel: bytesPerPixel) + 1,
                                arr: imageData)
    let deviationB = standardDeviation(arr: quadrantB)

    let quadrantC = getArrSlice(start: indexCalculator(x: xMinus, y: yMinus, width: width, bytesPerPixel: bytesPerPixel),
                                end: indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel) + 1,
                                arr: imageData)
    let deviationC = standardDeviation(arr: quadrantC )
    
    let quadrantD = getArrSlice(start: indexCalculator(x: x, y: yMinus, width: width, bytesPerPixel: bytesPerPixel),
                                end: indexCalculator(x: xPlus, y: y, width: width, bytesPerPixel: bytesPerPixel) + 1,
                                arr: imageData)
    let deviationD = standardDeviation(arr: quadrantD)
    
    var minDeviation = min(deviationA, deviationB)
    minDeviation = min(minDeviation, deviationC)
    minDeviation = min(minDeviation, deviationD)
    
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

package func standardDeviation(arr: Array<Int>)  -> Int {
    let expression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue: arr)])
    let standardDeviation = expression.expressionValue(with: nil, context: nil)
    guard let standardDeviation = standardDeviation as? Double else {
        print(standardDeviation ?? "Standart Deviation is Null")
        fatalError("Standart Deviation Failed remove this later")
        //throw ImageErrors.failedToConvertimage(localizedDescription: "StandartDeviation failed")
    }
    
    return Int(standardDeviation)
}
package func mean(arr: Array<Int>) -> Int {
    return arr.reduce(0, +) / arr.count
}

package func getArrSlice(start: Int, end: Int, arr: UnsafeMutablePointer<UInt8>) -> Array<Int> {
    var newArr : [Int] = Array<Int>(repeating: 0, count: end - start + 1)
    for i in start...end {
        newArr[i - start] = Int(arr[i])
    }
    return newArr
}

