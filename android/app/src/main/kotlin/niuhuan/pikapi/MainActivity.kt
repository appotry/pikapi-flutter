package niuhuan.pikapi

import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import mobile.Mobile
import kotlin.coroutines.EmptyCoroutineContext

class MainActivity : FlutterActivity() {

    private val scope = CoroutineScope(EmptyCoroutineContext)
    private val uiThreadHandler = Handler(Looper.getMainLooper())

    private fun MethodChannel.Result.withCoroutine(exec: () -> Any?) {
        scope.launch {
            try {
                val data = exec()
                uiThreadHandler.post {
                    when (data) {
                        null -> {
                            notImplemented()
                        }
                        is Unit -> {
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
                    else -> {
                        null
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

}
