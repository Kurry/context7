import XCTest
@testable import Context7MCP

final class EncryptionTests: XCTestCase {
    
    func testEncryptClientIp() {
        let clientIp = "192.168.1.1"
        let encrypted = EncryptionUtilities.encryptClientIp(clientIp)
        
        // Should return a hex string (not the original IP)
        XCTAssertNotEqual(encrypted, clientIp)
        XCTAssertTrue(encrypted.allSatisfy { $0.isHexDigit })
        XCTAssertGreaterThan(encrypted.count, 10) // Should be reasonably long
    }
    
    func testEncryptClientIpWithInvalidKey() {
        // Set an invalid encryption key
        setenv("CLIENT_IP_ENCRYPTION_KEY", "invalid", 1)
        
        let clientIp = "192.168.1.1"
        let encrypted = EncryptionUtilities.encryptClientIp(clientIp)
        
        // Should fallback to original IP when encryption fails
        XCTAssertEqual(encrypted, clientIp)
        
        // Clean up
        unsetenv("CLIENT_IP_ENCRYPTION_KEY")
    }
    
    func testGenerateHeaders() {
        let headers = EncryptionUtilities.generateHeaders(
            clientIp: "192.168.1.1",
            apiKey: "test-api-key",
            extraHeaders: ["Custom-Header": "custom-value"]
        )
        
        XCTAssertEqual(headers["Authorization"], "Bearer test-api-key")
        XCTAssertEqual(headers["Custom-Header"], "custom-value")
        XCTAssertNotNil(headers["mcp-client-ip"])
        XCTAssertNotEqual(headers["mcp-client-ip"], "192.168.1.1") // Should be encrypted
    }
    
    func testGenerateHeadersWithoutOptionalValues() {
        let headers = EncryptionUtilities.generateHeaders()
        
        XCTAssertEqual(headers.count, 0)
    }
    
    func testGenerateHeadersWithOnlyApiKey() {
        let headers = EncryptionUtilities.generateHeaders(apiKey: "test-api-key")
        
        XCTAssertEqual(headers["Authorization"], "Bearer test-api-key")
        XCTAssertNil(headers["mcp-client-ip"])
    }
    
    func testGenerateHeadersWithOnlyClientIp() {
        let headers = EncryptionUtilities.generateHeaders(clientIp: "192.168.1.1")
        
        XCTAssertNil(headers["Authorization"])
        XCTAssertNotNil(headers["mcp-client-ip"])
    }
}

