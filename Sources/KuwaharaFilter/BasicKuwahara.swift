//Created by Lugalu on 11/03/24.

import Foundation

public func basicKuwaharaFilter(x: Int, y: Int, size: Int, width: Int, height: Int, bytesPerPixel: Int, imageData: UnsafeMutablePointer<UInt8>) throws -> Int{
    let xPlus = clamp(min: 0, value: x + size, max: width)
    let xMinus = clamp(min: 0, value: x - size, max: width)
    
    let yPlus = clamp(min: 0, value: y + size, max: height)
    let yMinus = clamp(min: 0, value: y - size, max: height)
    
    let quadrantA = getGrayArrSlice(x1: x, x2: xPlus, y1: y, y2: yPlus, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationA = try standardDeviation(arr: quadrantA)
    
    let quadrantB = getGrayArrSlice(x1: xMinus, x2: x, y1: y, y2: yPlus, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationB = try standardDeviation(arr: quadrantB )
    
    let quadrantC = getGrayArrSlice(x1: xMinus, x2: x, y1: yMinus, y2: y, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationC = try standardDeviation(arr: quadrantC )
    
    let quadrantD = getGrayArrSlice(x1: x, x2: xPlus, y1: yMinus, y2: y, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationD = try standardDeviation(arr: quadrantD )
    
    let minDeviation = min(deviationA, deviationB, deviationC, deviationD)
    
    var meanResult: Int = 0
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
        throw ImageErrors.failedToOutputImage(localizedDescription: "Error in deviation calculation, no equal quadrant this should never happen.")
    }
    
    return meanResult
}


