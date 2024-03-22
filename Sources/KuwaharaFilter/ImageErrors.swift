//Created by Lugalu on 22/03/24.

import Foundation

public enum ImageErrors: Error{
    case failedToRetriveCGImage(localizedDescription:String)
    case failedToCreateContext(localizedDescription:String)
    case failedToOutputImage(localizedDescription:String)
    case failedToConvertimage(localizedDescription:String)
    case failedToDownsample(localizedDescription: String)
}
