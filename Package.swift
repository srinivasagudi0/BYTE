import PackageDescription

let package = Package(
    name: "BYTE",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "BYTE")
    ]
)