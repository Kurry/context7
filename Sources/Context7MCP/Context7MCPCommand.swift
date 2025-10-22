import Foundation
import ArgumentParser

/// Main command-line interface for Context7 MCP Server
@main
struct Context7MCPCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "context7-mcp",
        abstract: "Context7 MCP Server - Up-to-date Code Docs For Any Prompt",
        version: "1.0.13"
    )
    
    @Option(name: .shortAndLong, help: "API key for authentication (or set CONTEXT7_API_KEY env var)")
    var apiKey: String?
    
    func run() async throws {
        // Get API key from command line argument or environment variable
        let finalApiKey = apiKey ?? ProcessInfo.processInfo.environment["CONTEXT7_API_KEY"]
        
        // Create and start the MCP server
        let server = Context7MCPServer(apiKey: finalApiKey)
        
        do {
            try await server.start()
        } catch {
            let errorMessage = "Error starting Context7 MCP Server: \(error)"
            FileHandle.standardError.write(Data(errorMessage.utf8))
            throw error
        }
    }
}


