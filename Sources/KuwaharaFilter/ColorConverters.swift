//Created by Lugalu on 11/03/24.

import Foundation

typealias RGB = (r:UInt8, g:UInt8,b:UInt8)

func getPixelBrightness(color: RGB) throws -> Int {
    let color = (r: Double(color.r) / 255.0, g: Double(color.g) / 255.0, b: Double(color.b) / 255.0)
    
    let max = max(color.r,color.g,color.b)
   
    return Int(max * 255)
}
