import Cocoa

class WrapperController: NSViewController, NSWindowDelegate {
    var flutterViewController: NSViewController?

    init(with flutterViewController: NSViewController) {
        self.flutterViewController = flutterViewController
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.flutterViewController = nil
    }

    override func loadView() {
        self.view = NSView()
        self.view.addSubview(self.flutterViewController!.view)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.delegate = self
        updateSize()
    }

    func windowDidResize(_ notification: Notification) {
        updateSize()
    }

    func updateSize() {
        let width = self.view.window?.contentView?.bounds.width ?? 0
        let height = self.view.window?.contentView?.bounds.height ?? 0

        self.view.setFrameSize(NSSize(width: width, height: height))
        self.flutterViewController!.view.frame = self.view.bounds
    }
}
