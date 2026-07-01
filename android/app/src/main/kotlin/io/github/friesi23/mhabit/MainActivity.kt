package io.github.friesi23.mhabit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val ANIMATION_SCALE_CHANNEL = "global.app.animation/scale_stream"
    }

    private var animationScaleHandler: AnimationScaleStreamHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        animationScaleHandler?.dispose()
        val handler = AnimationScaleStreamHandler(contentResolver)
        animationScaleHandler = handler

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            ANIMATION_SCALE_CHANNEL
        ).setStreamHandler(handler)
    }

    override fun onDestroy() {
        animationScaleHandler?.dispose()
        animationScaleHandler = null
        super.onDestroy()
    }
}
