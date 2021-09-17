
import 'package:flutter/services.dart';


EventChannel eventChannel = EventChannel("event");

// 仅支持安卓
// 监听后会拦截安卓手机音量键
// 仅最后一次监听生效
// event可能为DOWN/UP
EventChannel volumeButtonChannel = EventChannel("volume_button");
