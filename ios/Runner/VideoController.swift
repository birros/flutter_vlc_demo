import UIKit
import MobileVLCKit

protocol VideoDelegate {
  func videoDone()
}

class VideoController: UIViewController, UIGestureRecognizerDelegate {
  var delegate: VideoDelegate?
  private var player: VLCMediaPlayer!
  private var videoView: UIView!
  private var button: UIButton!
  private var previousDelegate: UIGestureRecognizerDelegate?

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

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.black

    self.videoView = UIView()
    self.videoView.backgroundColor = UIColor.black
    self.videoView.frame = self.view.frame
    self.player.drawable = self.videoView
    self.view.addSubview(self.videoView)

    self.button = UIButton()
    self.button.setTitle("Back", for: .normal)
    self.button.backgroundColor = UIColor(
      red: 0.26,
      green: 0.26,
      blue: 0.26,
      alpha: 1.0
    )
    self.button.frame = CGRect(
      x: 0,
      y: self.view.frame.height - 50,
      width: 100,
      height: 50
    )
    self.button.addTarget(
      self,
      action: #selector(VideoController.onBack),
      for: .touchUpInside
    )
    self.view.addSubview(self.button)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(VideoController.rotated),
      name: UIDevice.orientationDidChangeNotification,
      object: nil
    )
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // replace back gesture handler
    if self.previousDelegate == nil {
      self.previousDelegate = self.navigationController?.interactivePopGestureRecognizer?.delegate
      self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    self.player.play()
  }

  override func viewWillDisappear(_ animated: Bool) {
    // restore back gesture handler
    if previousDelegate != nil {
      self.navigationController?.interactivePopGestureRecognizer?.delegate = previousDelegate
      self.previousDelegate = nil
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    self.player.stop()
    self.delegate?.videoDone()
  }

  @objc func rotated() {
    self.videoView.frame = self.view.frame
    self.button.frame = CGRect(
      x: 0,
      y: self.view.frame.height - 50,
      width: 100,
      height: 50
    )
  }

  @objc func onBack() {
    self.delegate?.videoDone()
  }
}
