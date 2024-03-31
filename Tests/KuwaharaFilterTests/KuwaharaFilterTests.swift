import XCTest
@testable import KuwaharaFilter

final class KuwaharaFilterTests: XCTestCase {
    func testColoredKuwahara() {
        FilterRegister.registerFilters()
        let image: UIImage = UIImage(named: "testImage", in: Bundle.module, with: nil)!
        XCTAssertNotNil(image, "image is nil")
        XCTAssertNotNil(image.cgImage, "CGImage is nil")
        let CIImage = CIImage(cgImage: image.cgImage!)
        
        let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": CIImage])
        XCTAssertNotNil(filter, "filter is nil")
        XCTAssertNotNil(filter?.outputImage, "output is nil")
        
    }
    
    func testGeneralizedKuwahara() {
        FilterRegister.registerFilters()
        let image: UIImage = UIImage(named: "testImage", in: Bundle.module, with: nil)!
        XCTAssertNotNil(image, "image is nil")
        XCTAssertNotNil(image.cgImage, "CGImage is nil")
        let CIImage = CIImage(cgImage: image.cgImage!)
        
        let filter = CIFilter(name: "Kuwahara", parameters: ["inputImage": CIImage, "inputKernelType": KuwaharaTypes.Generalized])
        XCTAssertNotNil(filter, "filter is nil")
        XCTAssertNotNil(filter?.outputImage, "output is nil")
    }
}
