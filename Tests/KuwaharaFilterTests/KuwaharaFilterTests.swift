import XCTest
@testable import KuwaharaFilter

final class KuwaharaFilterTests: XCTestCase {
    var image: CIImage = {
        #if os(iOS)
        let image: UIImage = UIImage(named: "testImage", in: Bundle.module, with: nil)!
        let cImage = CIImage(cgImage: image.cgImage!)
        return cImage
        #elseif os(OSX)
        let data: Data = Bundle.module.image(forResource: "testImage")!.tiffRepresentation!
        let bit = NSBitmapImageRep(data: data)!
        let cImage: CIImage = CIImage(bitmapImageRep: bit)!
        return cImage
        #endif
    }()
    
    func testColoredKuwahara() {
        FilterRegister.registerFilters()
        let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": image])
        XCTAssertNotNil(filter, "filter is nil")
        XCTAssertNotNil(filter?.outputImage, "output is nil")
        
    }
    
    func testGeneralizedKuwahara() {
        FilterRegister.registerFilters()
        let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": image, "inputKernelType": KuwaharaTypes.Generalized])
        XCTAssertNotNil(filter, "filter is nil")
        XCTAssertNotNil(filter?.outputImage, "output is nil")
    }
    
    func testPolynomialKuwahara() {
        FilterRegister.registerFilters()
        let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": image, "inputKernelType": KuwaharaTypes.Polynomial])
        XCTAssertNotNil(filter, "filter is nil")
        XCTAssertNotNil(filter?.outputImage, "output is nil")
    }
    
    func testAnisotropicKuwahara() {
        FilterRegister.registerFilters()
        let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": image, "inputKernelType": KuwaharaTypes.Anisotropic])
        XCTAssertNotNil(filter, "filter is nil")
        XCTAssertNotNil(filter?.outputImage, "output is nil")
    }
}
