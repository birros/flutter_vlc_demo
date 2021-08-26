import AppKit
import VLCKit

protocol VideoDelegate {
  func videoDone()
}

class VideoController: NSViewController {
  var delegate: VideoDelegate?
  private var player: VLCMediaPlayer!
  private var videoView: NSView!

  init(with uri: String) {
    super.init(nibName: nil, bundle: nil)

    let url = NSURL(string: uri)
    let media = VLCMedia(url: url! as URL)

    self.player = VLCMediaPlayer()
    self.player.media = media
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    self.view = NSView()

    self.videoView = NSView()
    self.videoView.wantsLayer = true
    self.videoView.layer?.backgroundColor = NSColor.black.cgColor
    self.player.drawable = self.videoView
    self.view.addSubview(self.videoView)

    let button = NSButton(frame: NSMakeRect(0, 0, 100, 50))
    button.title = "Back"
    button.bezelStyle = .texturedSquare
    button.isBordered = false
    button.wantsLayer = true
    button.layer?.backgroundColor = NSColor(
      red: 0.26,
      green: 0.26,
      blue: 0.26,
      alpha: 1.0
    ).cgColor
    button.target = self
    button.action = #selector(VideoController.onBack)
    self.view.addSubview(button)
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    self.videoView.frame = self.view.frame
    self.fixVideoSize()

    self.player.play()
  }

  override func viewDidLayout() {
    super.viewDidLayout()

    self.videoView.frame = self.view.frame
  }

  override func viewDidDisappear() {
    super.viewDidDisappear()

    self.player.stop()
  }

  func fixVideoSize() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      let frame = self.view.frame
      self.videoView.frame = NSMakeRect(0, 0, frame.width + 1, frame.height + 1)

      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.videoView.frame = frame
      }
    }
  }

  @objc
  func onBack() {
    self.delegate?.videoDone()
  }
}
