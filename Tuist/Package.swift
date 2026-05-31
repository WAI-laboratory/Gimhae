// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "CombineCocoa": .framework,
            "BetterSegmentedControl": .framework,
            "FSPagerView": .framework,
            "SkeletonView": .framework,
            "NMapsMap": .framework,
            "Kingfisher": .framework,
            "FirebaseAnalytics": .framework,
            "FirebaseAuth": .framework,
            "FirebaseFirestore": .framework,
            "CodableFirebase": .framework
        ]
    )
#endif

let package = Package(
    name: "GimhaeDependencies",
    dependencies: [
        .package(url: "https://github.com/sobabear/CoreEngine.git", .upToNextMajor(from: "1.0.3")),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", .upToNextMajor(from: "0.4.1")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/sobabear/AddThen.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/gmarm/BetterSegmentedControl.git", .upToNextMajor(from: "2.0.1")),
        .package(path: "../Cards-Source"),
        .package(url: "https://github.com/WenchaoD/FSPagerView.git", branch: "master"),
        .package(url: "https://github.com/Juanpe/SkeletonView.git", .upToNextMajor(from: "1.30.0")),
        .package(url: "https://github.com/navermaps/SPM-NMapsMap.git", .upToNextMajor(from: "3.17.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .exact("10.21.0")),
        .package(url: "https://github.com/alickbass/CodableFirebase.git", .upToNextMajor(from: "0.2.0"))
    ]
)
