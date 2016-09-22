
import PackageDescription

let package = Package(
    name: "LakestoneCore",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Thread.git", majorVersion: 2)
    ]
)
