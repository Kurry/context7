import Foundation
import Alamofire

/// API client for Context7 services using Alamofire for robust HTTP networking
public class Context7API: @unchecked Sendable {
    
    /// Base URL for Context7 API
    private static let baseURL = "https://context7.com/api"
    
    /// Default content type for requests
    private static let defaultType = "txt"
    
    /// Minimum allowed tokens for documentation retrieval
    public static let minimumTokens = 1000
    
    /// Default tokens when none specified
    public static let defaultTokens = 5000
    
    /// Alamofire session with proxy support
    private let session: Session
    
    public init() {
        // Configure session with proxy support
        let configuration = URLSessionConfiguration.default
        
        // Configure proxy if environment variables are set
        if let proxyURL = Self.getProxyURL() {
            configuration.connectionProxyDictionary = [
                kCFNetworkProxiesHTTPEnable: true,
                kCFNetworkProxiesHTTPProxy: proxyURL.host ?? "",
                kCFNetworkProxiesHTTPPort: proxyURL.port ?? 8080
            ]
        }
        
        self.session = Session(configuration: configuration)
    }
    
    /// Gets proxy URL from environment variables
    private static func getProxyURL() -> URL? {
        let proxyEnvVars = ["HTTPS_PROXY", "https_proxy", "HTTP_PROXY", "http_proxy"]
        
        for envVar in proxyEnvVars {
            if let proxyString = ProcessInfo.processInfo.environment[envVar],
               !proxyString.hasPrefix("$"),
               proxyString.hasPrefix("http") {
                return URL(string: proxyString)
            }
        }
        
        return nil
    }
    
    /// Searches for libraries matching the given query
    /// - Parameters:
    ///   - query: The search query
    ///   - clientIp: Optional client IP address to include in headers
    ///   - apiKey: Optional API key for authentication
    /// - Returns: Search results or error
    public func searchLibraries(
        query: String,
        clientIp: String? = nil,
        apiKey: String? = nil
    ) async throws -> SearchResponse {
        let url = "\(Self.baseURL)/v1/search"
        let parameters: [String: String] = ["query": query]
        
        let headers = EncryptionUtilities.generateHeaders(
            clientIp: clientIp,
            apiKey: apiKey
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: .get,
                parameters: parameters,
                headers: HTTPHeaders(headers)
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
                        continuation.resume(returning: searchResponse)
                    } catch {
                        continuation.resume(throwing: Context7Error.invalidResponse("Failed to decode search response: \(error)"))
                    }
                case .failure(let error):
                    let context7Error = Self.mapAFErrorToContext7Error(error, apiKey: apiKey)
                    continuation.resume(throwing: context7Error)
                }
            }
        }
    }
    
    /// Fetches documentation context for a specific library
    /// - Parameters:
    ///   - libraryId: The library ID to fetch documentation for
    ///   - tokens: Maximum number of tokens to retrieve
    ///   - topic: Optional topic to focus documentation on
    ///   - clientIp: Optional client IP address to include in headers
    ///   - apiKey: Optional API key for authentication
    /// - Returns: The documentation text or error
    public func fetchLibraryDocumentation(
        libraryId: String,
        tokens: Int? = nil,
        topic: String? = nil,
        clientIp: String? = nil,
        apiKey: String? = nil
    ) async throws -> String {
        // Remove leading slash if present
        let cleanLibraryId = libraryId.hasPrefix("/") ? String(libraryId.dropFirst()) : libraryId
        
        let url = "\(Self.baseURL)/v1/\(cleanLibraryId)"
        
        var parameters: [String: String] = [
            "tokens": String(tokens ?? Self.defaultTokens),
            "type": Self.defaultType
        ]
        
        if let topic = topic {
            parameters["topic"] = topic
        }
        
        var headers = EncryptionUtilities.generateHeaders(
            clientIp: clientIp,
            apiKey: apiKey
        )
        headers["X-Context7-Source"] = "mcp-server"
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: .get,
                parameters: parameters,
                headers: HTTPHeaders(headers)
            )
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let text):
                    // Check for empty or placeholder responses
                    if text.isEmpty || text == "No content available" || text == "No context data available" {
                        continuation.resume(throwing: Context7Error.libraryNotFound(libraryId))
                    } else {
                        continuation.resume(returning: text)
                    }
                case .failure(let error):
                    let context7Error = Self.mapAFErrorToContext7Error(error, apiKey: apiKey, libraryId: libraryId)
                    continuation.resume(throwing: context7Error)
                }
            }
        }
    }
    
    /// Maps Alamofire errors to Context7Error
    private static func mapAFErrorToContext7Error(
        _ error: AFError,
        apiKey: String? = nil,
        libraryId: String? = nil
    ) -> Context7Error {
        if let responseCode = error.responseCode {
            switch responseCode {
            case 401:
                return .unauthorized("Please check your API key. The API key you provided (possibly incorrect) is: \(apiKey ?? "nil"). API keys should start with 'ctx7sk'")
            case 404:
                if let libraryId = libraryId {
                    return .libraryNotFound(libraryId)
                } else {
                    return .invalidResponse("Resource not found")
                }
            case 429:
                return .rateLimited
            default:
                return .networkError("HTTP \(responseCode): \(error.localizedDescription)")
            }
        } else {
            return .networkError(error.localizedDescription)
        }
    }
}
