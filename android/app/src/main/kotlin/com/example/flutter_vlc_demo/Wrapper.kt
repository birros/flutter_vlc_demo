package com.example.flutter_vlc_demo

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri
import android.content.ComponentName

class Wrapper(flutterEngine: FlutterEngine, context: Context) {
  init {
    val channel = MethodChannel(
      flutterEngine.dartExecutor, "com.github.birros.flutter_vlc_demo/video"
    )
    channel.setMethodCallHandler { call, result ->
      when (call.method) {
        "play" -> {
          val uri = call.argument<String>("uri")

          uri?.let {
            val intent = Intent(Intent.ACTION_VIEW)
            intent.setDataAndTypeAndNormalize(Uri.parse(uri), "video/*")
            intent.setComponent(
              ComponentName(context, VideoActivity::class.java)
            )
            context.startActivity(intent)
          }

          result.success(null)
        }
        else -> result.notImplemented()
      }
    }
  }
}
