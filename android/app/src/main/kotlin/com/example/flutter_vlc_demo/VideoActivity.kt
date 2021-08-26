package com.example.flutter_vlc_demo

import android.content.Context
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import java.util.ArrayList
import org.videolan.libvlc.LibVLC
import org.videolan.libvlc.Media
import org.videolan.libvlc.MediaPlayer
import org.videolan.libvlc.util.VLCVideoLayout

class VideoActivity: AppCompatActivity() {
  companion object {
    val USE_TEXTURE_VIEW = false
    val ENABLE_SUBTITLES = true
  }

  var videoLayout: VLCVideoLayout? = null
  var player: MediaPlayer? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // layout
    val layout = FrameLayout(this)
    layout.setLayoutParams(
      FrameLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
      )
    )
    setContentView(layout)

    // videoLayout
    videoLayout = VLCVideoLayout(this)
    videoLayout?.setLayoutParams(
      FrameLayout.LayoutParams(
        ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
      )
    )
    layout.addView(videoLayout)

    // button
    val button = Button(this)
    button.text = "Back"
    button.setLayoutParams(
      FrameLayout.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT,
        ViewGroup.LayoutParams.WRAP_CONTENT
      ).apply {
        gravity = Gravity.LEFT or Gravity.BOTTOM
      }
    )
    button.setOnClickListener(onBack)
    layout.addView(button)
  }

  override fun onStart() {
    super.onStart()

    val uri = intent.getData()

    val args = ArrayList<String>()
    val libVLC = LibVLC(this, args)
    player = MediaPlayer(libVLC)
    val media = Media(libVLC, uri)
    player?.setMedia(media)

    videoLayout?.let {
      layout -> player?.attachViews(
        layout, null, ENABLE_SUBTITLES, USE_TEXTURE_VIEW
      )
    }

    player?.play()
  }

  override fun onStop() {
    super.onStop()

    player?.stop()
  }

  val onBack = View.OnClickListener { view ->
    runOnUiThread {
      onStop()
      finish()
    }
  }
}
