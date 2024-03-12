//Created by Lugalu on 12/03/24.

import Foundation


package func coloredKuwaharaRoutine(x: Int, y: Int, size: Int, width: Int, height: Int, bytesPerPixel: Int, imageData: inout UnsafeMutablePointer<UInt8>) throws {
    let avg = try coloredKuwaharaFilter(x: x, y: y, size: size, width: width, height: height, bytesPerPixel: bytesPerPixel, imageData: imageData)
    
    let idx = indexCalculator(x: x, y: y, width: width, bytesPerPixel: bytesPerPixel)
    imageData[idx] = UInt8(clamping: avg.r)
    imageData[idx + 1] = UInt8(clamping: avg.g)
    imageData[idx + 2] = UInt8(clamping: avg.b)
    
}

package func coloredKuwaharaFilter(x: Int, y: Int, size: Int, width: Int, height: Int, bytesPerPixel: Int, imageData: UnsafeMutablePointer<UInt8>) throws -> RGBInt {
    let xPlus = clamp(min: 0, value: x + size, max: width)
    let xMinus = clamp(min: 0, value: x - size, max: width)
    
    let yPlus = clamp(min: 0, value: y + size, max: height)
    let yMinus = clamp(min: 0, value: y - size, max: height)
    
    
    let (luminanceA,quadrantA) = getColoredArrSlice(x1: x, x2: xPlus, y1: y, y2: yPlus, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationA = try standardDeviation(arr: luminanceA)
    
    let (luminanceB,quadrantB) = getColoredArrSlice(x1: xMinus, x2: x, y1: y, y2: yPlus, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationB = try standardDeviation(arr: luminanceB )
    
    let (luminanceC,quadrantC) = getColoredArrSlice(x1: xMinus, x2: x, y1: yMinus, y2: y, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationC = try standardDeviation(arr: luminanceC )
    
    let (luminanceD,quadrantD) = getColoredArrSlice(x1: x, x2: xPlus, y1: yMinus, y2: y, width: width, bytesPerPixel: bytesPerPixel, arr: imageData)
    let deviationD = try standardDeviation(arr: luminanceD )
    
    let minDeviation = min(deviationA, deviationB, deviationC, deviationD)
    
    var rgbAVG: (Int,Int,Int)
    switch minDeviation{
    case deviationA:
        rgbAVG = getRGBAverage(rgbInt: quadrantA)
    case deviationB:
        rgbAVG = getRGBAverage(rgbInt: quadrantB)
    case deviationC:
        rgbAVG = getRGBAverage(rgbInt: quadrantC)
    case deviationD:
        rgbAVG = getRGBAverage(rgbInt: quadrantD)
    default:
        throw ImageErrors.failedToOutputImage(localizedDescription: "Error in deviation calculation, no equal quadrant this should never happen.")
    }
    
    return rgbAVG
}

