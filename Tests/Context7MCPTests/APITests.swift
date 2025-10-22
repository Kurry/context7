import XCTest
@testable import Context7MCP

final class APITests: XCTestCase {
    
    func testContext7APIConstants() {
        XCTAssertEqual(Context7API.minimumTokens, 1000)
        XCTAssertEqual(Context7API.defaultTokens, 5000)
    }
    
    func testContext7APIInitialization() {
        let api = Context7API()
        XCTAssertNotNil(api)
    }
    
    // Note: These tests would require mocking Alamofire or using a test server
    // For now, we'll just test that the methods exist and can be called
    
    func testSearchLibrariesMethodExists() async {
        let api = Context7API()
        
        do {
            // This will fail with a network error, but we're just testing the method exists
            _ = try await api.searchLibraries(query: "test")
            XCTFail("Expected network error")
        } catch {
            // Expected to fail without a real API key/network
            XCTAssertTrue(error is Context7Error || error.localizedDescription.contains("network"))
        }
    }
    
    func testFetchLibraryDocumentationMethodExists() async {
        let api = Context7API()
        
        do {
            // This will fail with a network error, but we're just testing the method exists
            _ = try await api.fetchLibraryDocumentation(libraryId: "/test/library")
            XCTFail("Expected network error")
        } catch {
            // Expected to fail without a real API key/network
            XCTAssertTrue(error is Context7Error || error.localizedDescription.contains("network"))
        }
    }
}

