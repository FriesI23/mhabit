package io.github.friesi23.mhabit

import android.content.ContentResolver
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.plugin.common.EventChannel

/**
 * Listens to [Settings.Global.ANIMATOR_DURATION_SCALE] and streams
 * changes through an [EventChannel] to the Flutter side.
 *
 * Call [dispose] when the hosting Activity is destroyed to ensure
 * the ContentObserver is unregistered even if the Flutter engine
 * cancels the stream late.
 */
class AnimationScaleStreamHandler(
    private val resolver: ContentResolver
) : EventChannel.StreamHandler {

    private var observer: ContentObserver? = null
    private var sink: EventChannel.EventSink? = null
    private var closed = false

    // -- StreamHandler -------------------------------------------------

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        cleanup()  // tear down any previous observer before re-registering
        sink = events
        closed = false

        val uri = Settings.Global.getUriFor(Settings.Global.ANIMATOR_DURATION_SCALE)
        events?.success(readScale())

        val o = object : ContentObserver(Handler(Looper.getMainLooper())) {
            override fun onChange(selfChange: Boolean, changeUri: Uri?) {
                if (changeUri != null && changeUri != uri) return
                if (!closed) sink?.success(readScale())
            }
        }
        observer = o
        resolver.registerContentObserver(uri, false, o)
    }

    override fun onCancel(arguments: Any?) {
        cleanup()
    }

    // -- Lifecycle -----------------------------------------------------

    /** Safe to call multiple times — idempotent. */
    fun dispose() = cleanup()

    // -- Internal ------------------------------------------------------

    private fun cleanup() {
        closed = true
        observer?.let { resolver.unregisterContentObserver(it) }
        observer = null
        sink = null
    }

    private fun readScale(): Double {
        return try {
            Settings.Global.getFloat(
                resolver, Settings.Global.ANIMATOR_DURATION_SCALE
            ).toDouble()
        } catch (_: Exception) {
            1.0
        }
    }
}
