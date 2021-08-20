import AppKit
import VLCKit

class VideoController: NSViewController {
    private var player: VLCMediaPlayer!

    override func loadView() {
        self.view = NSView()
        let url = NSURL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
        let media = VLCMedia(url: url! as URL)
        let player = VLCMediaPlayer()
        self.player = player
        self.player.media = media
        self.player.drawable = self.view
        self.player.play()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.fixVideoSize()
    }

    func fixVideoSize() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let frame = self.view.frame
            self.view.frame = NSMakeRect(0, 0, frame.width + 1, frame.height + 1)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.view.frame = frame
            }
        }
    }
}
