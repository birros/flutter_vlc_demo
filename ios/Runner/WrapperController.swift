import UIKit
import Flutter

class WrapperController: UINavigationController, VideoDelegate {
  init(with flutterViewController: FlutterViewController) {
    super.init(rootViewController: flutterViewController)

    self.setNavigationBarHidden(true, animated: false)

    let channel = FlutterMethodChannel.init(
      name: "com.github.birros.flutter_vlc_demo/video",
      binaryMessenger: flutterViewController.binaryMessenger
    )
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if ("play" == call.method) {
        let args = call.arguments as? Dictionary<String, Any>
        let uri = args?["uri"] as? String

        if (uri != nil) {
          let videoController = VideoController.init(with: uri!)
          videoController.delegate = self
          self.pushViewController(videoController, animated: true)
        }

        result(nil)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func videoDone() {
    DispatchQueue.main.async {
      self.popViewController(animated: true)
    }
  }
}