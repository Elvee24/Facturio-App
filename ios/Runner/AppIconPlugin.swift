import Flutter
import UIKit

final class AppIconPlugin: NSObject, FlutterPlugin {
  private static let channelName = "facturio/app_icon"
  private static let iconMap: [String: String?] = [
    "official": nil,
    "calculator": "AppIconCalculator",
    "money": "AppIconMoney",
    "documents": "AppIconDocuments",
    "chart": "AppIconChart",
    "business": "AppIconBusiness",
  ]

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = AppIconPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "applyIcon":
      guard
        let arguments = call.arguments as? [String: Any],
        let iconKey = arguments["iconKey"] as? String
      else {
        result("invalidIcon")
        return
      }

      applyIcon(iconKey: iconKey, result: result)
    case "getCurrentIcon":
      result(currentIconKey())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func applyIcon(iconKey: String, result: @escaping FlutterResult) {
    guard UIApplication.shared.supportsAlternateIcons else {
      result("unsupportedPlatform")
      return
    }

    guard let alternateIconName = Self.iconMap[iconKey] else {
      result("invalidIcon")
      return
    }

    if UIApplication.shared.alternateIconName == alternateIconName {
      result("alreadySynced")
      return
    }

    UIApplication.shared.setAlternateIconName(alternateIconName) { error in
      if let error {
        result(FlutterError(code: "app_icon_change_failed", message: error.localizedDescription, details: nil))
      } else {
        result("synced")
      }
    }
  }

  private func currentIconKey() -> String {
    let currentAlternateName = UIApplication.shared.alternateIconName
    return Self.iconMap.first(where: { $0.value == currentAlternateName })?.key ?? "official"
  }
}