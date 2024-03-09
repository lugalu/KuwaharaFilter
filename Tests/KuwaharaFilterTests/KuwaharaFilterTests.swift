import XCTest
@testable import KuwaharaFilter

final class KuwaharaFilterTests: XCTestCase {
    func testExample() throws {
        let image: UIImage = UIImage(named: "testImage", in: Bundle.module, with: nil)!
        
        XCTAssertNoThrow(try image.applyKuwahara(type: .basicKuwahara, size: 13), "It Threw!")
    }
}
