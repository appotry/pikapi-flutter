import UIKit
import Flutter
import Pikapi

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        MobileInitApplication(documentsPath)
        
        let controller = self.window.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel.init(name: "pica", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        channel.setMethodCallHandler { (call, result) in
            Thread {
                if call.method == "loadProperty" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let name = args["name"] as? String,
                       let defaultValue = args["defaultValue"] as? String{
                        result(MobileLoadProperty(name, defaultValue))
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "saveProperty" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let name = args["name"] as? String,
                       let value = args["value"] as? String{
                        MobileSaveProperty(name, value)
                        result(nil)
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "setSwitchAddress" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let name = args["switchAddress"] as? String{
                        MobileSetSwitchAddress(name)
                        result(nil)
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "getSwitchAddress" {
                    result(MobileGetSwitchAddress())
                }
                else if call.method == "setProxy" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let name = args["proxy"] as? String{
                        MobileSetProxy(name)
                        result(nil)
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "getProxy" {
                    result(MobileGetProxy())
                }
                else if call.method == "setUsername" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let name = args["username"] as? String{
                        MobileSetUsername(name)
                        result(nil)
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "getUsername" {
                    result(MobileGetUsername())
                }
                else if call.method == "setPassword" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let name = args["password"] as? String{
                        MobileSetPassword(name)
                        result(nil)
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "getPassword" {
                    result(MobileGetPassword())
                }
                else if call.method == "preLogin" {
                    let ok = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
                    var error: NSError?
                    MobilePreLogin(ok, &error)
                    if error != nil {
                        result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                    }else{
                        result(ok[0].boolValue)
                    }
                }
                else if call.method == "login" {
                    var error: NSError?
                    MobileLogin(&error)
                    if error != nil {
                        result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                    }else{
                        result("")
                    }
                }
                else if call.method == "remoteImageData" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let fileServer = args["fileServer"] as? String,
                       let path = args["path"] as? String{
                        var error: NSError?
                        let data = MobileRemoteImageData(fileServer, path, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "categories" {
                    var error: NSError?
                    let data = MobileCategories(&error)
                    if error != nil {
                        result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                    }else{
                        result(data)
                    }
                }
                else if call.method == "comics" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let category = args["category"] as? String,
                       let sort = args["sort"] as? String,
                       let page = args["page"] as? NSNumber{
                        var error: NSError?
                        let data = MobileComics(category, sort, page.intValue, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "searchComics" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let keyword = args["keyword"] as? String,
                       let sort = args["sort"] as? String,
                       let page = args["page"] as? NSNumber{
                        var error: NSError?
                        let data = MobileSearchComics(keyword, sort, page.intValue, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "searchComicsInCategories" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let keyword = args["keyword"] as? String,
                       let sort = args["sort"] as? String,
                       let page = args["page"] as? NSNumber,
                       let categories = args["categories"] as? NSArray{
                        var error: NSError?
                        let data = MobileSearchComicsInCategories(keyword, sort, page.intValue, json(from: categories),&error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "comicInfo" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comicId = args["comicId"] as? String{
                        var error: NSError?
                        let data = MobileComicInfo(comicId, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "comicEpPage" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comicId = args["comicId"] as? String,
                       let page = args["page"] as? NSNumber{
                        var error: NSError?
                        let data = MobileEpPage(comicId, page.intValue, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "comicPicturePageWithQuality" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comicId = args["comicId"] as? String,
                       let epOrder = args["epOrder"] as? NSNumber,
                       let page = args["page"] as? NSNumber,
                       let quality = args["quality"] as? String{
                        var error: NSError?
                        let data = MobileComicPicturePageWithQuality(comicId, epOrder.intValue, page.intValue, quality, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "downloadComic" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comicId = args["comicId"] as? String{
                        var error: NSError?
                        let data = MobileLoadDownloadComic(comicId, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "downloadComicThumb" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comicId = args["comicId"] as? String{
                        var error: NSError?
                        let data = MobileDownloadComicThumb(comicId, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "downloadEpList" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comicId = args["comicId"] as? String{
                        var error: NSError?
                        let data = MobileDownloadEpList(comicId, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "createDownload" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comic = args["comic"] as? String,
                       let epList = args["epList"] as? String{
                        var error: NSError?
                        let data = MobileCreateDownload(comic,epList, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "addDownload" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comic = args["comic"] as? String,
                       let epList = args["epList"] as? String{
                        var error: NSError?
                        let data = MobileAddDownload(comic,epList, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "allDownloads" {
                    var error: NSError?
                    let data = MobileAllDownloads(&error)
                    if error != nil {
                        result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                    }else{
                        result(data)
                    }
                }
                else if call.method == "downloadPicturesByEpId" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let epId = args["epId"] as? String{
                        var error: NSError?
                        let data = MobileDownloadPicturesByEpId(epId, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "viewLogPage" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let page = args["page"] as? NSNumber,
                       let pageSize = args["pageSize"] as? NSNumber{
                        var error: NSError?
                        let data = MobileViewLogPage(page.intValue, pageSize.intValue, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else if call.method == "resetAllDownloads" {
                    var error: NSError?
                    MobileResetAllDownloads(&error)
                    if error != nil {
                        result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                    }else{
                        result(nil)
                    }
                }
                else if call.method == "exportComicDownload" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let comicId = args["comicId"] as? String,
                       let dir = args["dir"] as? String{
                        var error: NSError?
                        let data = MobileExportComicDownload(comicId, dir, &error)
                        if error != nil {
                            result(FlutterError(code: "", message: error?.localizedDescription, details: ""))
                        }else{
                            result(data)
                        }
                    }else{
                        result(FlutterError(code: "", message: "params error", details: ""))
                    }
                }
                else{
                    result(FlutterMethodNotImplemented)
                }
            }.start()
        }
        
        // 导出事件,没有使用
        // NOT USE BECAUSE IOS DO NOT EXPORT
        let exportingEventChannel = FlutterEventChannel.init(name: "exporting", binaryMessenger: controller as! FlutterBinaryMessenger)
        class ExportingChannelHanlder:NSObject, FlutterStreamHandler {
             func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
                exportingSink = events
                return nil
            }
            
             func onCancel(withArguments arguments: Any?) -> FlutterError? {
                exportingSink = nil
                return nil
            }
        }
        exportingEventChannel.setStreamHandler(ExportingChannelHanlder.init())
        class ExportingNotifyHandler:NSObject, MobileStringNotifyProtocol {
            func onNotify(_ s: String?) {
                exportingSink?(s)
            }
        }
        MobileExportingNotify(ExportingNotifyHandler.init())
        
        // 下载事件
        let downloadingComicChannel = FlutterEventChannel.init(name: "downloadingComic", binaryMessenger: controller as! FlutterBinaryMessenger)
        class DownloadingComicChannelHandler:NSObject, FlutterStreamHandler {
            func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
                if let args = arguments as? Dictionary<String, Any>,
                   let SCREEN = args["SCREEN"] as? String{
                    dnMap[SCREEN] = events
                }
               return nil
           }
           
            func onCancel(withArguments arguments: Any?) -> FlutterError? {
                if let args = arguments as? Dictionary<String, Any>,
                   let SCREEN = args["SCREEN"] as? String{
                    dnMap.removeObject(forKey: SCREEN)
                }
               return nil
           }
       }
       downloadingComicChannel.setStreamHandler(DownloadingComicChannelHandler.init())
        class DownloadingComicNotifyHandler:NSObject, MobileStringNotifyProtocol {
            func onNotify(_ s: String?) {
                dnMap.forEach { (key: Any, value: Any) in
                    if let a = value as? FlutterEventSink {
                        a(s)
                    }
                }
            }
        }
        MobileDownloadingComicNotify(DownloadingComicNotifyHandler.init())
        
        //
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

var exportingSink: FlutterEventSink?

let dnMap = NSMutableDictionary()

func json(from object:Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}
