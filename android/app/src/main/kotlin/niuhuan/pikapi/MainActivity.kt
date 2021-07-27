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
import mobile.Mobile
import kotlin.coroutines.EmptyCoroutineContext

class MainActivity : FlutterActivity() {

    private val scope = CoroutineScope(EmptyCoroutineContext)
    private val uiThreadHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Mobile.initApplication(context!!.filesDir.absolutePath)

        //
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pica").setMethodCallHandler { call, result ->
            result.withCoroutine {
                when (call.method) {
                    "loadProperty" -> {
                        Mobile.loadProperty(
                                call.argument("name")!!,
                                call.argument("defaultValue")!!
                        )
                    }
                    "saveProperty" -> {
                        Mobile.saveProperty(
                                call.argument("name")!!,
                                call.argument("value")!!
                        )
                    }
                    "getSwitchAddress" -> {
                        Mobile.getSwitchAddress()
                    }
                    "setSwitchAddress" -> {
                        Mobile.setSwitchAddress(
                                call.argument("switchAddress")!!
                        )
                    }
                    "getProxy" -> {
                        Mobile.getProxy()
                    }
                    "setProxy" -> {
                        Mobile.setProxy(
                                call.argument("proxy")!!
                        )
                    }
                    "getUsername" -> {
                        Mobile.getUsername()
                    }
                    "setUsername" -> {
                        Mobile.setUsername(
                                call.argument("username")!!
                        )
                    }
                    "getPassword" -> {
                        Mobile.getPassword()
                    }
                    "setPassword" -> {
                        Mobile.setPassword(
                                call.argument("password")!!
                        )
                    }
                    "preLogin" -> {
                        Mobile.preLogin()
                    }
                    "login" -> {
                        Mobile.login()
                    }
                    "remoteImageData" -> {
                        Mobile.remoteImageData(
                                call.argument("fileServer")!!,
                                call.argument("path")!!
                        )
                    }
                    "categories" -> {
                        Mobile.categories()
                    }
                    "comics" -> {
                        Mobile.comics(
                                call.argument("category")!!,
                                call.argument("sort")!!,
                                call.argument("page")!!
                        )
                    }
                    "searchComics" -> {
                        Mobile.searchComics(
                                call.argument("keyword")!!,
                                call.argument("sort")!!,
                                call.argument("page")!!
                        )
                    }
                    "searchComicsInCategories" -> {
                        val any: Any? = call.argument("categories")
                        Mobile.searchComicsInCategories(
                                call.argument("keyword")!!,
                                call.argument("sort")!!,
                                call.argument("page")!!,
                                Gson().toJson(any)
                        )
                    }
                    "comicInfo" -> {
                        Mobile.comicInfo(
                                call.argument("comicId")!!
                        )
                    }
                    "comicEpPage" -> {
                        Mobile.epPage(
                                call.argument("comicId")!!,
                                call.argument("page")!!
                        )
                    }
                    "comicPicturePageWithQuality" -> {
                        Mobile.comicPicturePageWithQuality(
                                call.argument("comicId")!!,
                                call.argument("epOrder")!!,
                                call.argument("page")!!,
                                call.argument("quality")!!
                        )
                    }
                    "downloadComic" -> {
                        Mobile.loadDownloadComic(
                                call.argument("comicId")!!
                        )
                    }
                    "downloadComicThumb" -> {
                        Mobile.downloadComicThumb(
                                call.argument("comicId")!!
                        )
                    }
                    "downloadEpList" -> {
                        Mobile.downloadEpList(
                                call.argument("comicId")!!
                        )
                    }
                    "createDownload" -> {
                        Mobile.createDownload(
                                call.argument("comic")!!,
                                call.argument("epList")!!
                        )
                    }
                    "addDownload" -> {
                        Mobile.addDownload(
                                call.argument("comic")!!,
                                call.argument("epList")!!
                        )
                    }
                    "allDownloads" -> {
                        Mobile.allDownloads()
                    }
                    "downloadPicturesByEpId" -> {
                        Mobile.downloadPicturesByEpId(
                                call.argument("epId")!!
                        )
                    }
                    "viewLogPage" -> {
                        Mobile.viewLogPage(
                                call.argument("page")!!,
                                call.argument("pageSize")!!
                        )
                    }
                    "resetAllDownloads" -> {
                        Mobile.resetAllDownloads()
                    }
                    "exportComicDownload" -> {
                        Mobile.exportComicDownload(
                                call.argument("comicId")!!,
                                call.argument("dir")!!
                        )
                    }
                    "importComicDownload" -> {
                        Mobile.importComicDownload(
                                call.argument("zipPath")!!
                        )
                    }
                    else -> {
                        null
                    }
                }
            }
        }

        //
        var exportingEventsReg: EventChannel.EventSink? = null
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "exporting")
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        exportingEventsReg = events
                    }

                    override fun onCancel(arguments: Any?) {
                        exportingEventsReg = null
                    }
                })
        Mobile.exportingNotify {
            scope.launch {
                uiThreadHandler.post {
                    exportingEventsReg?.success(it)
                }
            }
        }

        //
        val downloadingComicEventMap = HashMap<String, EventChannel.EventSink?>()
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "downloadingComic")
                .setStreamHandler(object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        when (arguments) {
                            is Map<*, *> -> {
                                when (val screen = arguments["SCREEN"]){
                                    is String ->{
                                        downloadingComicEventMap[screen] = events
                                    }
                                }
                            }
                        }
                    }

                    override fun onCancel(arguments: Any?) {
                        when (arguments) {
                            is Map<*, *> -> {
                                when (val screen = arguments["SCREEN"]){
                                    is String ->{
                                        downloadingComicEventMap.remove(screen)
                                    }
                                }
                            }
                        }
                    }
                })
        Mobile.downloadingComicNotify { a ->
            scope.launch {
                uiThreadHandler.post {
                    downloadingComicEventMap.forEach { (_, u) -> u?.success(a) }
                }
            }
        }

    }

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

}
