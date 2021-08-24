/// 全局配置文件, 项目启动时加载

import 'package:event/event.dart';
import 'package:pikapi/basic/enum/ReaderDirection.dart';
import 'package:pikapi/basic/enum/ReaderType.dart';

import 'enum/FullScreenAction.dart';
import 'enum/PagerAction.dart';

// 哔咔配置
late String storedAddress;
late String storedProxy;
late String storedQuality;

// 数据缓存
var storedCategories = <String>[];

// 程序配置
late bool storedAutoFullScreen;
late FullScreenAction storedFullScreenAction;
late ReaderType storedReaderType;
late ReaderDirection storedReaderDirection;
late PagerAction storedPagerAction;
late List<String> storedShadowCategories;

class StoredShadowCategoriesEventArgs extends EventArgs {}

var storedShadowCategoriesEvent = Event<EventArgs>();
