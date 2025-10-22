import Foundation
import CryptoKit

/// Utilities for encrypting client IP addresses and generating headers
public struct EncryptionUtilities {
    
    /// Default encryption key (can be overridden with CLIENT_IP_ENCRYPTION_KEY env var)
    private static let defaultEncryptionKey = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"
    
    /// Gets the encryption key from environment or uses default
    private static var encryptionKey: String {
        return ProcessInfo.processInfo.environment["CLIENT_IP_ENCRYPTION_KEY"] ?? defaultEncryptionKey
    }
    
    /// Validates that the encryption key is exactly 64 hex characters (32 bytes)
    private static func validateEncryptionKey(_ key: String) -> Bool {
        return key.count == 64 && key.allSatisfy { $0.isHexDigit }
    }
    
    /// Encrypts a client IP address using AES-GCM encryption
    /// - Parameter clientIp: The client IP address to encrypt
    /// - Returns: The encrypted IP in format "iv:encryptedData" or original IP if encryption fails
    public static func encryptClientIp(_ clientIp: String) -> String {
        guard validateEncryptionKey(encryptionKey) else {
            print("Invalid encryption key format. Must be 64 hex characters.")
            return clientIp
        }
        
        do {
            // Convert hex string to Data
            guard let keyData = Data(hexString: encryptionKey) else {
                print("Error: Invalid hex string for encryption key")
                return clientIp
            }
            
            // Create symmetric key from data
            let symmetricKey = SymmetricKey(data: keyData)
            
            // Encrypt the client IP
            let clientIpData = clientIp.data(using: .utf8) ?? Data()
            let sealedBox = try AES.GCM.seal(clientIpData, using: symmetricKey)
            
            // Combine nonce and ciphertext
            let combined = sealedBox.nonce + sealedBox.ciphertext
            let encryptedHex = combined.map { String(format: "%02hhx", $0) }.joined()
            
            return encryptedHex
        } catch {
            print("Error encrypting client IP: \(error)")
            return clientIp
        }
    }
    
    /// Generates headers for Context7 API requests
    /// - Parameters:
    ///   - clientIp: Optional client IP address to include
    ///   - apiKey: Optional API key for authentication
    ///   - extraHeaders: Additional headers to include
    /// - Returns: Dictionary of headers
    public static func generateHeaders(
        clientIp: String? = nil,
        apiKey: String? = nil,
        extraHeaders: [String: String] = [:]
    ) -> [String: String] {
        var headers = extraHeaders
        
        if let clientIp = clientIp {
            headers["mcp-client-ip"] = encryptClientIp(clientIp)
        }
        
        if let apiKey = apiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }
        
        return headers
    }
}

/// Extension to convert hex string to Data
private extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }
}

