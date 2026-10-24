// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "mhabit_desktop_window_chrome",
  platforms: [.macOS("12.0")],
  products: [
    .library(name: "mhabit-desktop-window-chrome", targets: ["mhabit_desktop_window_chrome"])
  ],
  dependencies: [.package(name: "FlutterFramework", path: "../FlutterFramework")],
  targets: [
    .target(
      name: "mhabit_desktop_window_chrome",
      dependencies: [.product(name: "FlutterFramework", package: "FlutterFramework")],
    )
  ],
)
