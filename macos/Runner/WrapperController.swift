import AppKit
import FlutterMacOS

class WrapperController: NSViewController, NSWindowDelegate, VideoDelegate {
  var flutterViewController: FlutterViewController?
  var videoController: VideoController?

  init(with flutterViewController: FlutterViewController) {
    super.init(nibName: nil, bundle: nil)

    self.flutterViewController = flutterViewController

    let channel = FlutterMethodChannel.init(
      name: "com.github.birros.flutter_vlc_demo/video",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if ("play" == call.method) {
        let args = call.arguments as? Dictionary<String, Any>
        let uri = args?["uri"] as? String

        if (uri != nil && self.videoController == nil) {
          self.videoController = VideoController.init(with: uri!)
          self.videoController?.delegate = self
          self.videoController?.view.frame = self.view.bounds
          self.view.addSubview(self.videoController!.view)
          self.flutterViewController?.view.isHidden = true;
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

  override func loadView() {
    self.view = NSView()
    self.view.addSubview(self.flutterViewController!.view)
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    self.view.window?.delegate = self
    self.updateSize()
  }

  func windowDidResize(_ notification: Notification) {
    self.updateSize()
  }

  func updateSize() {
    let width = self.view.window?.contentView?.bounds.width ?? 0
    let height = self.view.window?.contentView?.bounds.height ?? 0

    self.view.setFrameSize(NSSize(width: width, height: height))
    self.flutterViewController?.view.frame = self.view.bounds
    self.videoController?.view.frame = self.view.bounds
  }

  func videoDone() {
    self.flutterViewController?.view.isHidden = false;
    self.videoController?.view.removeFromSuperview()
    self.videoController = nil
  }
}
