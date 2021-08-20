import AppKit

class WrapperController: NSViewController, NSWindowDelegate {
    var flutterViewController: NSViewController?
    var videoController: VideoController?

    init(with flutterViewController: NSViewController) {
        super.init(nibName: nil, bundle: nil)
        self.flutterViewController = flutterViewController
        self.videoController = VideoController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NSView()
        self.view.addSubview(self.flutterViewController!.view)
        self.view.addSubview(self.videoController!.view)
        // self.videoController?.view.removeFromSuperview()
        // self.videoController = nil
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
}
