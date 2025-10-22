import Foundation

/// Utilities for formatting search results into human-readable strings
public struct Formatters {
    
    /// Formats a single search result into a human-readable string representation
    /// Only shows code snippet count, trust score, and versions when available (not equal to -1 or empty)
    /// - Parameter result: The SearchResult object to format
    /// - Returns: A formatted string with library information
    public static func formatSearchResult(_ result: SearchResult) -> String {
        var formattedResult = [
            "- Title: \(result.title)",
            "- Context7-compatible library ID: \(result.id)",
            "- Description: \(result.description)"
        ]
        
        // Only add code snippets count if it's a valid value
        if result.totalSnippets != -1 {
            formattedResult.append("- Code Snippets: \(result.totalSnippets)")
        }
        
        // Only add trust score if it's a valid value
        if let trustScore = result.trustScore, trustScore != -1 {
            formattedResult.append("- Trust Score: \(trustScore)")
        }
        
        // Only add versions if it's a valid value
        if let versions = result.versions, !versions.isEmpty {
            formattedResult.append("- Versions: \(versions.joined(separator: ", "))")
        }
        
        // Join all parts with newlines
        return formattedResult.joined(separator: "\n")
    }
    
    /// Formats a search response into a human-readable string representation
    /// Each result is formatted using formatSearchResult
    /// - Parameter searchResponse: The SearchResponse object to format
    /// - Returns: A formatted string with search results
    public static func formatSearchResults(_ searchResponse: SearchResponse) -> String {
        if searchResponse.results.isEmpty {
            return "No documentation libraries found matching your query."
        }
        
        let formattedResults = searchResponse.results.map { formatSearchResult($0) }
        return formattedResults.joined(separator: "\n----------\n")
    }
}

