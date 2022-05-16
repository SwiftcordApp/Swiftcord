// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DiscordAPI",
	platforms: [
		.macOS(.v12)
	],
	products: [
		.library(name: "DiscordAPI", targets: ["DiscordAPI"]),
		.library(name: "DiscordKitCommon", targets: ["DiscordKitCommon"])
	],
	dependencies: [
		.package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.1.0"),
	],
	targets: [
		.target(
			name: "DiscordAPI",
			dependencies: [
				.product(name: "Reachability", package: "Reachability.swift"),
			],
			exclude: [
				"REST/README.md",
				"Gateway/README.md",
				"Objects/README.md"
			]
		),
		.target(name: "DiscordKitCommon")
	]
)
