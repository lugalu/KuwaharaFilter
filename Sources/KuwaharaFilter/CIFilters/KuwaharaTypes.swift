import Foundation

@objc public enum KuwaharaTypes: Int, CaseIterable {
    /** the original colored Kuwahara filter.*/
    case basic
    /** generalized kuwahara using polynomial weights instead of gaussian.*/
    case generalized
    
    public func getTitle() -> String{
        return switch self {
        case .basic:
            "Basic Kuwahara"
        case .generalized:
            "Generalized"
        }
    }
}




