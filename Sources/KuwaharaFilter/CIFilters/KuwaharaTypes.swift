import Foundation

@objc public enum KuwaharaTypes: Int, CaseIterable{
    case colored
    case generalized
    
    public func getTitle() -> String{
        return switch self {
        case .colored:
            "Colored Kuwahara"
        case .generalized:
            "Generalized"
        }
    }
}




