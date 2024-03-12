//Created by Lugalu on 07/03/24.

import Accelerate
import UIKit

/**
    Creates the CGContext and Image Data needed for other operations in case of  bytes per pixel be nil also calculates it as is needed for other operations.
    - Parameters:
      - cgImage: the cgImage that will be converted into context and image buffer the color space is kept
      - bytesPerPixel: override of bytes per pixel if nothing is provided the value is calculated based on bytes per row / width
      - width: the width of the image
      - height: the height of the image
    - Returns: A tuple containg the context, image buffer and bytes per pixel, remember to deallocate the image buffer once it's not needed
 */
internal func createContextAndData(cgImage: CGImage, bytesPerPixel: Int? = nil, width: Int, height: Int) throws -> (imageContext: CGContext, imageData: UnsafeMutablePointer<UInt8>, bytesPerPixel: Int){
    #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
    #endif
    let colorSpace = cgImage.colorSpace!
    let bytesPerRow = cgImage.bytesPerRow
    let bytesPerPixel = bytesPerPixel ?? bytesPerRow / width
    let bitsPerComponent = cgImage.bitsPerComponent
    
    let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * bytesPerPixel)
    
    guard let imageContext = CGContext(data: imageData,
                                 width: width,
                                 height: height,
                                 bitsPerComponent: bitsPerComponent,
                                 bytesPerRow: bytesPerRow,
                                 space: colorSpace,
                                       bitmapInfo: cgImage.bitmapInfo.rawValue
    )
    else {
        throw ImageErrors.failedToCreateContext(localizedDescription: "Context Creation failed! Please generate an issue in the github repository with the image.")
    }
    imageContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    #if DEBUG
        print("Create Context and Data total time: \(CFAbsoluteTimeGetCurrent() - start)")
    #endif
    
    return (imageContext, imageData, bytesPerPixel)
}


package func convertToRGB(_ cgImage: CGImage)  throws -> CGImage{
    guard
        let sourceImageFormat = vImage_CGImageFormat(cgImage: cgImage),
        let rgbDestinationBuffer = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8 * 4,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue))
    else {
            throw ImageErrors.failedToConvertimage(localizedDescription: "Unable to initialize")
        }

    let result = try createCGImage(source: sourceImageFormat, destination: rgbDestinationBuffer, image: cgImage)
    
    return result
}


public enum ImageErrors: Error{
    case failedToRetriveCGImage(localizedDescription:String)
    case failedToCreateContext(localizedDescription:String)
    case failedToOutputImage(localizedDescription:String)
    case failedToConvertimage(localizedDescription:String)
    case failedToDownsample(localizedDescription: String)
}

/**
    Creates a new CGImage with the color space modified to the destination format.
    - Parameters:
      - source: Original format of the Image
      - destination: Desired format of the image
      - image: the image that will be converted
    - Returns: the  CGImage with the new color space format
 */
internal func createCGImage(source: vImage_CGImageFormat, destination: vImage_CGImageFormat, image: CGImage) throws -> CGImage {
    
    let converter = try vImageConverter.make(sourceFormat: source, destinationFormat: destination, flags: .printDiagnosticsToConsole)
    
    let sourceBuffer = try vImage_Buffer(cgImage: image)
    defer {
        sourceBuffer.free()

    }
    
    var destinationBuffer = try vImage_Buffer(width: Int(sourceBuffer.width),
                                              height: Int(sourceBuffer.height),
                                              bitsPerPixel: destination.bitsPerPixel)
    
    defer {
        destinationBuffer.free()
    }
    
    try converter.convert(source: sourceBuffer, destination: &destinationBuffer)
    
    let result = try destinationBuffer.createCGImage(format: destination)
    
    return result
}


/**
    Converts image to the GrayScale format accepted by Quartz2D containing 16 bits in total (color(0-255) and alpha (0-255))
    - Parameters:
      - cgImage: the image to be converted and re-rendered
    - Returns: the converted image
 - Tag: convertColorSpaceToGrayScale
 */
public func convertColorSpaceToGrayScale(_ cgImage: CGImage) throws -> CGImage{
    #if DEBUG
        let start = CFAbsoluteTimeGetCurrent()
    #endif
    guard
        let sourceImageFormat = vImage_CGImageFormat(cgImage: cgImage),
        let grayDestinationBuffer = vImage_CGImageFormat(
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            colorSpace: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)) else {
        throw ImageErrors.failedToConvertimage(localizedDescription: "Unable to initialize")
    }

    let result = try createCGImage(source: sourceImageFormat, destination: grayDestinationBuffer, image: cgImage)
    #if DEBUG
        print("Convert Color Space to Gray total time: \(CFAbsoluteTimeGetCurrent() - start)")
    #endif
    return result
}

public func clamp<T: Comparable & Numeric>(min minValue:T, value:T, max maxValue:T) -> T {
    return min(maxValue, max(minValue,value))
}

internal func indexCalculator(x: Int, y: Int, width: Int, bytesPerPixel: Int) -> Int{
    return (y * width + x) * bytesPerPixel
}

package func standardDeviation(arr: Array<Int>) throws  -> Double {
    let expression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue: arr)])
    let standardDeviation = expression.expressionValue(with: nil, context: nil)
    
    guard let standardDeviation = standardDeviation as? Double else {
        throw ImageErrors.failedToConvertimage(localizedDescription: "StandartDeviation failed")
    }
    
    return standardDeviation
}
package func mean(arr: Array<Int>) -> Int {
    return arr.reduce(0, +) / arr.count
}

package func getGrayArrSlice(x1: Int, x2: Int, y1: Int, y2: Int, width:Int, bytesPerPixel: Int,arr: UnsafeMutablePointer<UInt8>) -> Array<Int> {
    var newArr : [UInt8] = []
    
    for i in y1...y2 {
        for j in x1...x2 {
            let idx = indexCalculator(x: j, y: i, width: width, bytesPerPixel: bytesPerPixel)
            newArr.append(arr[idx])
        }
    }
    
    return newArr.map { Int($0) }
}

