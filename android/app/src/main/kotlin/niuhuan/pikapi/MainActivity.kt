package niuhuan.pikapi

import android.content.ContentValues
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.newSingleThreadContext
import kotlinx.coroutines.sync.Mutex
import mobile.Mobile
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {

    // 为什么换成换成线程池而不继续使用携程 : 下载图片速度慢会占满携程造成拥堵, 接口无法请求
    private val pool = Executors.newCachedThreadPool { runnable ->
        Thread(runnable).also { it.isDaemon = true }
    }
    private val uiThreadHandler = Handler(Looper.getMainLooper())
    private val scope = CoroutineScope(newSingleThreadContext("worker-scope"))

    private val notImplementedToken = Any()
    private fun MethodChannel.Result.withCoroutine(exec: () -> Any?) {
        pool.submit {
            try {
                val data = exec()
                uiThreadHandler.post {
                    when (data) {
                        notImplementedToken -> {
                            notImplemented()
                        }
                        is Unit, null -> {
                            success(null)
                        }
                        else -> {
                            success(data)
                        }
                    }
                }
            } catch (e: Exception) {
                uiThreadHandler.post {
                    error("", e.message, "")
                }
            }

        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Mobile.initApplication(context!!.filesDir.absolutePath)
        // Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pica").setMethodCallHandler { call, result ->
            result.withCoroutine {
                when (call.method) {
                    "flatInvoke" -> {
                        Mobile.flatInvoke(
                                call.argument("method")!!,
                                call.argument("params")!!
                        )
                    }
                    "androidSaveFileToImage" -> {
                        saveImage(call.argument("path")!!)
                    }
                    else -> {
                        notImplementedToken
                    }
                }
            }
        }
        //
        var mutex = Mutex()
        val eventSinkMap = HashMap<String, HashMap<String, EventChannel.EventSink>>()
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "event")
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        events?.also { events ->
                            when (arguments) {
                                is Map<*, *> -> {
                                    val function = arguments["function"]
                                    val id = arguments["id"]
                                    when {
                                        function is String && id is String -> {
                                            scope.launch {
                                                mutex.lock()
                                                try {
                                                    var map = eventSinkMap[function]
                                                    if (map == null) {
                                                        map = HashMap()
                                                        eventSinkMap[function] = map
                                                    }
                                                    map[id] = events
                                                } finally {
                                                    mutex.unlock()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    override fun onCancel(arguments: Any?) {
                        when (arguments) {
                            is Map<*, *> -> {
                                val function = arguments["function"]
                                val id = arguments["id"]
                                when {
                                    function is String && id is String -> {
                                        scope.launch {
                                            mutex.lock()
                                            try {
                                                eventSinkMap[function]?.also {
                                                    it.remove(id)
                                                }
                                            } finally {
                                                mutex.unlock()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
        Mobile.eventNotify { function, value ->
            scope.launch {
                mutex.lock()
                try {
                    eventSinkMap[function]?.also {
                        it.values.forEach {
                            uiThreadHandler.post {
                                it.success(value)
                            }
                        }
                    }
                } finally {
                    mutex.unlock()
                }
            }
        }

    }

    private fun saveImage(path: String) {
        BitmapFactory.decodeFile(path)?.let { bitmap ->
            val contentValues = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, System.currentTimeMillis().toString())
                put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) { //this one
                    put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_PICTURES)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }
            }
            contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)?.let { uri ->
                contentResolver.openOutputStream(uri)?.use { fos ->
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) { //this one
                    contentValues.clear()
                    contentValues.put(MediaStore.Video.Media.IS_PENDING, 0)
                    contentResolver.update(uri, contentValues, null, null)
                }
            }
        }
    }

}
