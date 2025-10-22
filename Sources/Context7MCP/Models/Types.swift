import Foundation

/// Represents the state of a document in the Context7 system
public enum DocumentState: String, Codable, CaseIterable {
    case initial = "initial"
    case finalized = "finalized"
    case error = "error"
    case delete = "delete"
}

/// Represents a single search result from Context7 API
public struct SearchResult: Codable, Equatable {
    public let id: String
    public let title: String
    public let description: String
    public let branch: String
    public let lastUpdateDate: String
    public let state: DocumentState
    public let totalTokens: Int
    public let totalSnippets: Int
    public let totalPages: Int
    public let stars: Int?
    public let trustScore: Int?
    public let versions: [String]?
    
    public init(
        id: String,
        title: String,
        description: String,
        branch: String,
        lastUpdateDate: String,
        state: DocumentState,
        totalTokens: Int,
        totalSnippets: Int,
        totalPages: Int,
        stars: Int? = nil,
        trustScore: Int? = nil,
        versions: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.branch = branch
        self.lastUpdateDate = lastUpdateDate
        self.state = state
        self.totalTokens = totalTokens
        self.totalSnippets = totalSnippets
        self.totalPages = totalPages
        self.stars = stars
        self.trustScore = trustScore
        self.versions = versions
    }
}

/// Represents the response from Context7 search API
public struct SearchResponse: Codable, Equatable {
    public let error: String?
    public let results: [SearchResult]
    
    public init(error: String? = nil, results: [SearchResult]) {
        self.error = error
        self.results = results
    }
}

/// Custom errors for Context7 MCP operations
public enum Context7Error: Error, LocalizedError {
    case invalidAPIKey(String)
    case rateLimited
    case libraryNotFound(String)
    case networkError(String)
    case encryptionError(String)
    case invalidResponse(String)
    case unauthorized(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidAPIKey(let key):
            return "Invalid API key: \(key). API keys should start with 'ctx7sk'"
        case .rateLimited:
            return "Rate limited due to too many requests. Please try again later."
        case .libraryNotFound(let id):
            return "The library '\(id)' does not exist. Please try with a different library ID."
        case .networkError(let message):
            return "Network error: \(message)"
        case .encryptionError(let message):
            return "Encryption error: \(message)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .unauthorized(let message):
            return "Unauthorized: \(message)"
        }
    }
}

