import Foundation

@objc public enum KuwaharaTypes: Int, CaseIterable {
    /** the original colored Kuwahara filter.*/
    case basic
    /** Upgrade of the original kuwahara that uses gaussian functions, expensive, but better*/
    case Generalized
    /** generalized kuwahara using polynomial weights instead of gaussian, with the right parameters contains the same result as Generalized but faster..*/
    case Polynomial
    /** Like Polynomial but with better edge detection.*/
    case Anisotropic
    
    public func getTitle() -> String{
        return switch self {
        case .basic:
            "Basic Kuwahara"
        case .Generalized:
            "Generalized"
        case .Polynomial:
            "Polynomial"
        case .Anisotropic:
            "Anisotropic"
        }
    }
}




