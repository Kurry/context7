import XCTest
@testable import Context7MCP

final class FormatterTests: XCTestCase {
    
    func testFormatSearchResult() {
        let result = SearchResult(
            id: "/test/library",
            title: "Test Library",
            description: "A test library for testing",
            branch: "main",
            lastUpdateDate: "2024-01-01",
            state: .finalized,
            totalTokens: 1000,
            totalSnippets: 50,
            totalPages: 10,
            stars: 100,
            trustScore: 8,
            versions: ["1.0.0", "1.1.0"]
        )
        
        let formatted = Formatters.formatSearchResult(result)
        
        XCTAssertTrue(formatted.contains("Title: Test Library"))
        XCTAssertTrue(formatted.contains("Context7-compatible library ID: /test/library"))
        XCTAssertTrue(formatted.contains("Description: A test library for testing"))
        XCTAssertTrue(formatted.contains("Code Snippets: 50"))
        XCTAssertTrue(formatted.contains("Trust Score: 8"))
        XCTAssertTrue(formatted.contains("Versions: 1.0.0, 1.1.0"))
    }
    
    func testFormatSearchResultWithMissingValues() {
        let result = SearchResult(
            id: "/test/library",
            title: "Test Library",
            description: "A test library for testing",
            branch: "main",
            lastUpdateDate: "2024-01-01",
            state: .finalized,
            totalTokens: 1000,
            totalSnippets: -1,
            totalPages: 10,
            trustScore: -1
        )
        
        let formatted = Formatters.formatSearchResult(result)
        
        XCTAssertTrue(formatted.contains("Title: Test Library"))
        XCTAssertTrue(formatted.contains("Context7-compatible library ID: /test/library"))
        XCTAssertTrue(formatted.contains("Description: A test library for testing"))
        XCTAssertFalse(formatted.contains("Code Snippets"))
        XCTAssertFalse(formatted.contains("Trust Score"))
    }
    
    func testFormatSearchResults() {
        let results = [
            SearchResult(
                id: "/test/library1",
                title: "Test Library 1",
                description: "First test library",
                branch: "main",
                lastUpdateDate: "2024-01-01",
                state: .finalized,
                totalTokens: 1000,
                totalSnippets: 50,
                totalPages: 10
            ),
            SearchResult(
                id: "/test/library2",
                title: "Test Library 2",
                description: "Second test library",
                branch: "main",
                lastUpdateDate: "2024-01-02",
                state: .finalized,
                totalTokens: 2000,
                totalSnippets: 100,
                totalPages: 20
            )
        ]
        
        let searchResponse = SearchResponse(results: results)
        let formatted = Formatters.formatSearchResults(searchResponse)
        
        XCTAssertTrue(formatted.contains("Test Library 1"))
        XCTAssertTrue(formatted.contains("Test Library 2"))
        XCTAssertTrue(formatted.contains("----------"))
    }
    
    func testFormatEmptySearchResults() {
        let searchResponse = SearchResponse(results: [])
        let formatted = Formatters.formatSearchResults(searchResponse)
        
        XCTAssertEqual(formatted, "No documentation libraries found matching your query.")
    }
}

