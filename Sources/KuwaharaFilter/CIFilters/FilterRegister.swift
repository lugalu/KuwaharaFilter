//Created by Lugalu on 14/03/24.

import UIKit

public class FilterRegister: NSObject, CIFilterConstructor{
    public func filter(withName name: String) -> CIFilter? {
        switch name {
        case "Kuwahara":
            return Kuwahara()
        default:
            return nil
        }
    }
    
    static public func registerFilters(){
        CIFilter.registerName("Kuwahara", constructor: FilterRegister())
    }
}
