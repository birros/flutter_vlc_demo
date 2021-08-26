import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let flutterViewController = window?.rootViewController as! FlutterViewController
    window?.rootViewController = WrapperController.init(with: flutterViewController)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
