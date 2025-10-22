import Foundation
import MCP

/// MCP Server implementation for Context7 documentation service
public class Context7MCPServer: @unchecked Sendable {
    
    private let server: Server
    private let apiClient: Context7API
    private let clientIp: String?
    private let apiKey: String?
    
    public init(clientIp: String? = nil, apiKey: String? = nil) {
        self.clientIp = clientIp
        self.apiKey = apiKey
        self.apiClient = Context7API()
        
        // Initialize MCP server
        self.server = Server(
            name: "Context7",
            version: "1.0.13",
            capabilities: Server.Capabilities(
                prompts: nil,
                resources: nil,
                tools: Server.Capabilities.Tools(listChanged: true)
            )
        )
        
        setupTools()
    }
    
    /// Sets up the MCP tools for library resolution and documentation fetching
    private func setupTools() {
        // Register resolve-library-id tool
        Task {
            await server.withMethodHandler(ListTools.self) { _ in
                return ListTools.Result(tools: [
                    Tool(
                        name: "resolve-library-id",
                        description: """
                        Resolves a package/product name to a Context7-compatible library ID and returns a list of matching libraries.

                        You MUST call this function before 'get-library-docs' to obtain a valid Context7-compatible library ID UNLESS the user explicitly provides a library ID in the format '/org/project' or '/org/project/version' in their query.

                        Selection Process:
                        1. Analyze the query to understand what library/package the user is looking for
                        2. Return the most relevant match based on:
                        - Name similarity to the query (exact matches prioritized)
                        - Description relevance to the query's intent
                        - Documentation coverage (prioritize libraries with higher Code Snippet counts)
                        - Trust score (consider libraries with scores of 7-10 more authoritative)

                        Response Format:
                        - Return the selected library ID in a clearly marked section
                        - Provide a brief explanation for why this library was chosen
                        - If multiple good matches exist, acknowledge this but proceed with the most relevant one
                        - If no good matches exist, clearly state this and suggest query refinements

                        For ambiguous queries, request clarification before proceeding with a best-guess match.
                        """,
                        inputSchema: Value.object([
                            "type": .string("object"),
                            "properties": .object([
                                "libraryName": .object([
                                    "type": .string("string"),
                                    "description": .string("Library name to search for and retrieve a Context7-compatible library ID.")
                                ])
                            ]),
                            "required": .array([.string("libraryName")])
                        ])
                    ),
                    Tool(
                        name: "get-library-docs",
                        description: """
                        Fetches up-to-date documentation for a library. You must call 'resolve-library-id' first to obtain the exact Context7-compatible library ID required to use this tool, UNLESS the user explicitly provides a library ID in the format '/org/project' or '/org/project/version' in their query.
                        """,
                        inputSchema: Value.object([
                            "type": .string("object"),
                            "properties": .object([
                                "context7CompatibleLibraryID": .object([
                                    "type": .string("string"),
                                    "description": .string("Exact Context7-compatible library ID (e.g., '/mongodb/docs', '/vercel/next.js', '/supabase/supabase', '/vercel/next.js/v14.3.0-canary.87') retrieved from 'resolve-library-id' or directly from user query in the format '/org/project' or '/org/project/version'.")
                                ]),
                                "topic": .object([
                                    "type": .string("string"),
                                    "description": .string("Topic to focus documentation on (e.g., 'hooks', 'routing').")
                                ]),
                                "tokens": .object([
                                    "type": .string("number"),
                                    "description": .string("Maximum number of tokens of documentation to retrieve (default: 5000). Higher values provide more context but consume more tokens.")
                                ])
                            ]),
                            "required": .array([.string("context7CompatibleLibraryID")])
                        ])
                    )
                ])
            }
        }
        
        // Register CallTool handler
        Task {
            await server.withMethodHandler(CallTool.self) { params in
                return await self.handleToolCall(params)
            }
        }
    }
    
    /// Handles tool calls for both resolve-library-id and get-library-docs
    private func handleToolCall(_ params: CallTool.Parameters) async -> CallTool.Result {
        switch params.name {
        case "resolve-library-id":
            return await handleResolveLibraryId(params)
        case "get-library-docs":
            return await handleGetLibraryDocs(params)
        default:
            return CallTool.Result(
                content: [Tool.Content.text("Unknown tool: \(params.name)")],
                isError: true
            )
        }
    }
    
    /// Handles the resolve-library-id tool call
    private func handleResolveLibraryId(_ params: CallTool.Parameters) async -> CallTool.Result {
        guard let libraryNameValue = params.arguments?["libraryName"],
              case .string(let libraryName) = libraryNameValue else {
            return CallTool.Result(
                content: [Tool.Content.text("Missing required parameter: libraryName")],
                isError: true
            )
        }
        
        do {
            let searchResponse = try await apiClient.searchLibraries(
                query: libraryName,
                clientIp: clientIp,
                apiKey: apiKey
            )
            
            if searchResponse.results.isEmpty {
                let errorMessage = searchResponse.error ?? "Failed to retrieve library documentation data from Context7"
                return CallTool.Result(
                    content: [Tool.Content.text(errorMessage)],
                    isError: true
                )
            }
            
            let resultsText = Formatters.formatSearchResults(searchResponse)
            let responseText = """
            Available Libraries (top matches):

            Each result includes:
            - Library ID: Context7-compatible identifier (format: /org/project)
            - Name: Library or package name
            - Description: Short summary
            - Code Snippets: Number of available code examples
            - Trust Score: Authority indicator
            - Versions: List of versions if available. Use one of those versions if the user provides a version in their query. The format of the version is /org/project/version.

            For best results, select libraries based on name match, trust score, snippet coverage, and relevance to your use case.

            ----------

            \(resultsText)
            """
            
            return CallTool.Result(
                content: [Tool.Content.text(responseText)],
                isError: false
            )
            
        } catch {
            return CallTool.Result(
                content: [Tool.Content.text("Error searching libraries: \(error.localizedDescription)")],
                isError: true
            )
        }
    }
    
    /// Handles the get-library-docs tool call
    private func handleGetLibraryDocs(_ params: CallTool.Parameters) async -> CallTool.Result {
        guard let libraryIdValue = params.arguments?["context7CompatibleLibraryID"],
              case .string(let libraryId) = libraryIdValue else {
            return CallTool.Result(
                content: [Tool.Content.text("Missing required parameter: context7CompatibleLibraryID")],
                isError: true
            )
        }
        
        let topic: String?
        if let topicValue = params.arguments?["topic"],
           case .string(let topicString) = topicValue {
            topic = topicString.isEmpty ? nil : topicString
        } else {
            topic = nil
        }
        
        let tokens: Int
        if let tokensValue = params.arguments?["tokens"],
           case .int(let tokensNumber) = tokensValue {
            tokens = tokensNumber
        } else if let tokensValue = params.arguments?["tokens"],
                  case .double(let tokensNumber) = tokensValue {
            tokens = Int(tokensNumber)
        } else {
            tokens = Context7API.defaultTokens
        }
        
        do {
            let documentation = try await apiClient.fetchLibraryDocumentation(
                libraryId: libraryId,
                tokens: tokens,
                topic: topic,
                clientIp: clientIp,
                apiKey: apiKey
            )
            
            return CallTool.Result(
                content: [Tool.Content.text(documentation)],
                isError: false
            )
            
        } catch {
            let errorMessage: String
            if case Context7Error.libraryNotFound = error {
                errorMessage = "Documentation not found or not finalized for this library. This might have happened because you used an invalid Context7-compatible library ID. To get a valid Context7-compatible library ID, use the 'resolve-library-id' with the package name you wish to retrieve documentation for."
            } else {
                errorMessage = "Error fetching library documentation: \(error.localizedDescription)"
            }
            
            return CallTool.Result(
                content: [Tool.Content.text(errorMessage)],
                isError: true
            )
        }
    }
    
    /// Starts the MCP server with stdio transport
    public func start() async throws {
        let transport = StdioTransport()
        try await server.start(transport: transport)
    }
    
    /// Stops the MCP server
    public func stop() async {
        await server.stop()
    }
}