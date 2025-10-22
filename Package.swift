// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Context7MCP",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "context7-mcp",
            targets: ["Context7MCP"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.10.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "Context7MCP",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk"),
                "Alamofire",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/Context7MCP"
        ),
        .testTarget(
            name: "Context7MCPTests",
            dependencies: ["Context7MCP"],
            path: "Tests/Context7MCPTests"
        )
    ]
)

