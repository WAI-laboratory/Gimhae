import ProjectDescription

let project = Project(
    name: "Gimhae",
    packages: [
        .package(url: "https://github.com/sobabear/CoreEngine.git", from: "1.0.3"),
        .package(url: "https://github.com/CombineCommunity/CombineCocoa.git", from: "0.4.1"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/sobabear/AddThen.git", from: "1.1.0"),
        .package(url: "https://github.com/gmarm/BetterSegmentedControl.git", from: "2.0.1"),
        .package(path: "Cards-Source"),
        .package(url: "https://github.com/WenchaoD/FSPagerView.git", .branch("master")),
        .package(url: "https://github.com/Juanpe/SkeletonView.git", from: "1.30.0"),
        .package(url: "https://github.com/navermaps/SPM-NMapsMap.git", from: "3.17.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .exact("10.21.0")),
        .package(url: "https://github.com/alickbass/CodableFirebase.git", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "Gimhae",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.WAI.Gimhae",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .file(path: "Gimhae/Info.plist"),
            sources: ["Gimhae/**/*.swift"],
            resources: [
                "Gimhae/Resources/**",
                "Gimhae/Assets.xcassets",
                "Gimhae/Base.lproj/**",
            ],
            scripts: [
                .post(
                    script: """
                    rm -rf "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/GoogleAppMeasurement.framework"
                    rm -rf "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/FirebaseAnalytics.framework"
                    rm -rf "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/FirebaseFirestoreInternal.framework"
                    rm -rf "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/GoogleAppMeasurementIdentitySupport.framework"
                    """,
                    name: "Remove Static Frameworks Info.plist error",
                    basedOnDependencyAnalysis: false
                )
            ],
            dependencies: [
                .package(product: "CoreEngine"),
                .package(product: "CombineCocoa"),
                .package(product: "SnapKit"),
                .package(product: "AddThen"),
                .package(product: "BetterSegmentedControl"),
                .package(product: "Cards"),
                .package(product: "FSPagerView"),
                .package(product: "SkeletonView"),
                .package(product: "NMapsMap"),
                .package(product: "Kingfisher"),
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseAuth"),
                .package(product: "FirebaseFirestore"),
                .package(product: "CodableFirebase"),
            ]
        ),
    ]
)
