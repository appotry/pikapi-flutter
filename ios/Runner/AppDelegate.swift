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
                if call.method == "flatInvoke" {
                    if let args = call.arguments as? Dictionary<String, Any>,
                       let method = args["method"] as? String,
                       let params = args["params"] as? String{
                        var error: NSError?
                        let data = MobileFlatInvoke(method, params, &error)
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
        
        //
        let eventChannel = FlutterEventChannel.init(name: "event", binaryMessenger: controller as! FlutterBinaryMessenger)
        
        class EventChannelHandler:NSObject, FlutterStreamHandler {
             func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
                
                if let args = arguments as? Dictionary<String, Any>,
                   let function = args["function"] as? String,
                   let id = args["id"] as? String
                {
                    objc_sync_enter(mutex)
                        if dnMap[function] == nil{
                            dnMap[function]=[:]
                        }
                        dnMap [function]?[id]=events
                    objc_sync_exit(mutex)
                }
                return nil
            }
            
             func onCancel(withArguments arguments: Any?) -> FlutterError? {
                if let args = arguments as? Dictionary<String, Any>,
                   let function = args["function"] as? String,
                   let id = args["id"] as? String
                {
                    objc_sync_enter(mutex)
                        if dnMap[function] == nil{
                            dnMap[function]=[:]
                        }
                        dnMap[function]?[id]=nil
                    objc_sync_exit(mutex)
                }
                return nil
            }
        }
        class EventNotifyHandler:NSObject, MobileEventNotifyHandlerProtocol {
            func onNotify(_ function: String?, value: String?) {
                if function != nil, value != nil,dnMap[function!] != nil{
                    objc_sync_enter(mutex)
                    for (_,v) in dnMap[function!]!{
                        v(value)
                    }
                    objc_sync_exit(mutex)
                }
            }
        }
        
        eventChannel.setStreamHandler(EventChannelHandler.init())
        MobileEventNotify(EventNotifyHandler.init())
        
        
        //
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


var dnMap : [String: [String : FlutterEventSink ]] = [:]
let mutex = NSObject.init()
    .self
