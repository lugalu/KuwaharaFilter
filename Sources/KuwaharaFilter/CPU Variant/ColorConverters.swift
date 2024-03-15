//Created by Lugalu on 11/03/24.

import Foundation

typealias RGB = (r:UInt8, g:UInt8,b:UInt8)
package typealias RGBInt = (r:Int, g:Int,b:Int)

func getPixelBrightness(color: RGB) -> Int {
    let color = (r: Double(color.r) / 255.0, g: Double(color.g) / 255.0, b: Double(color.b) / 255.0)
    
    let max = max(color.r,color.g,color.b)
   
    return Int(max * 255)
}

func getRGBAverage(rgbInt rgb: Array<RGBInt>) -> (rAvg:Int,gAvg:Int,bAvg:Int) {
    var rSum = 0
    var gSum = 0
    var bSum = 0
    
    for px in rgb{
        rSum += px.r
        gSum += px.g
        bSum += px.b
    }
    
    rSum /= rgb.count
    gSum /= rgb.count
    bSum /= rgb.count
    
    return (rSum,gSum,bSum)
    
}
