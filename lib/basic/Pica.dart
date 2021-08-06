import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/enum/Quality.dart';

final pica = Pica._();

class Pica {
  Pica._();

  MethodChannel _channel = MethodChannel("pica");

  Future<dynamic> _flatInvoke(String method, dynamic params) {
    return _channel.invokeMethod("flatInvoke", {
      "method": method,
      "params": params is String ? params : jsonEncode(params),
    });
  }

  Future<String> loadTheme() async {
    return await _flatInvoke("loadProperty", {
      "name": "theme",
      "defaultValue": "dark",
    });
  }

  Future<dynamic> saveTheme(String code) async {
    return await _flatInvoke("saveProperty", {
      "name": "theme",
      "value": code,
    });
  }

  Future<String> loadQuality() async {
    return await _flatInvoke("loadProperty", {
      "name": "quality",
      "defaultValue": ImageQualityOriginal,
    });
  }

  Future<dynamic> saveQuality(String code) async {
    return await _flatInvoke("saveProperty", {
      "name": "quality",
      "defaultValue": {
        "name": "quality",
        "value": code,
      },
    });
  }

  Future<String> getSwitchAddress() async {
    return await _flatInvoke("getSwitchAddress", "");
  }

  Future<dynamic> setSwitchAddress(String switchAddress) async {
    return await _flatInvoke("setSwitchAddress", switchAddress);
  }

  Future<String> getProxy() async {
    return await _flatInvoke("getProxy", "");
  }

  Future<dynamic> setProxy(String proxy) async {
    return await _flatInvoke("setProxy", proxy);
  }

  Future<String> getUsername() async {
    return await _flatInvoke("getUsername", "");
  }

  Future<dynamic> setUsername(String username) async {
    return await _flatInvoke("setUsername", username);
  }

  Future<String> getPassword() async {
    return await _flatInvoke("getPassword", "");
  }

  Future<dynamic> setPassword(String password) async {
    return await _flatInvoke("setPassword", password);
  }

  Future<bool> preLogin() async {
    String rsp = await _flatInvoke("preLogin", "");
    return rsp == "true";
  }

  Future<dynamic> login() async {
    return _flatInvoke("login", "");
  }

  Future<UserProfile> userProfile() async {
    String rsp = await _flatInvoke("userProfile", "");
    return UserProfile.fromJson(json.decode(rsp));
  }

  Future<dynamic> punchIn() {
    return _flatInvoke("punchIn", "");
  }

  Future<RemoteImageData> remoteImageData(
      String fileServer, String path) async {
    var data = await _flatInvoke("remoteImageData", {
      "fileServer": fileServer,
      "path": path,
    });
    return RemoteImageData.fromJson(json.decode(data));
  }

  Future<String> downloadImagePath(String path) async {
    return await _flatInvoke("downloadImagePath", path);
  }

  Future<List<Category>> categories() async {
    String rsp = await _flatInvoke("categories", "");
    List list = json.decode(rsp);
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<ComicsPage> comics(
    String sort,
    int page, {
    String category = "",
    String tag = "",
    String creatorId = "",
    String chineseTeam = "",
  }) async {
    String rsp = await _flatInvoke("comics", {
      "category": category,
      "tag": tag,
      "creatorId": creatorId,
      "chineseTeam": chineseTeam,
      "sort": sort,
      "page": page,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<ComicsPage> searchComics(String keyword, String sort, int page) {
    return searchComicsInCategories(keyword, sort, page, []);
  }

  Future<ComicsPage> searchComicsInCategories(
      String keyword, String sort, int page, List<String> categories) async {
    String rsp = await _flatInvoke("searchComics", {
      "keyword": keyword,
      "sort": sort,
      "page": page,
      "categories": categories,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<List<ComicSimple>> randomComics() async {
    String data = await _flatInvoke("randomComics", "");
    return List.of(jsonDecode(data))
        .map((e) => Map<String, dynamic>.of(e))
        .map((e) => ComicSimple.fromJson(e))
        .toList();
  }

  Future<List<ComicSimple>> leaderboard(String type) async {
    String data = await _flatInvoke("leaderboard", type);
    return List.of(jsonDecode(data))
        .map((e) => Map<String, dynamic>.of(e))
        .map((e) => ComicSimple.fromJson(e))
        .toList();
  }

  Future<ComicInfo> comicInfo(String comicId) async {
    String rsp = await _flatInvoke("comicInfo", comicId);
    return ComicInfo.fromJson(json.decode(rsp));
  }

  Future<EpPage> comicEpPage(String comicId, int page) async {
    String rsp = await _flatInvoke("comicEpPage", {
      "comicId": comicId,
      "page": page,
    });
    return EpPage.fromJson(json.decode(rsp));
  }

  Future<PicturePage> comicPicturePageWithQuality(
      String comicId, int epOrder, int page, String quality) async {
    String data = await _flatInvoke("comicPicturePageWithQuality", {
      "comicId": comicId,
      "epOrder": epOrder,
      "page": page,
      "quality": quality,
    });
    return PicturePage.fromJson(json.decode(data));
  }

  Future<String> switchLike(String comicId) async {
    return await _flatInvoke("switchLike", comicId);
  }

  Future<String> switchFavourite(String comicId) async {
    return await _flatInvoke("switchFavourite", comicId);
  }

  Future<ComicsPage> favouriteComics(String sort, int page) async {
    var rsp = await _flatInvoke("favouriteComics", {
      "sort": sort,
      "page": page,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<List<ComicSimple>> recommendation(String comicId) async {
    String rsp = await _flatInvoke("recommendation", comicId);
    List list = json.decode(rsp);
    return list.map((e) => ComicSimple.fromJson(e)).toList();
  }

  Future<CommentPage> comments(String comicId, int page) async {
    var rsp = await _flatInvoke("comments", {
      "comicId": comicId,
      "page": page,
    });
    return CommentPage.fromJson(json.decode(rsp));
  }

  Future<List<ViewLog>> viewLogPage(int page, int pageSize) async {
    var data = await _flatInvoke("viewLogPage", {
      "page": page,
      "pageSize": pageSize,
    });
    List list = json.decode(data);
    return list.map((e) => ViewLog.fromJson(e)).toList();
  }

  Future<GamePage> games(int page) async {
    var data = await _flatInvoke("games", "$page");
    return GamePage.fromJson(json.decode(data));
  }

  Future<GameInfo> game(String gameId) async {
    var data = await _flatInvoke("game", gameId);
    return GameInfo.fromJson(json.decode(data));
  }

  Future clean() {
    return _flatInvoke("clean", "");
  }

  Future storeViewEp(
      String comicId, int epOrder, String epTitle, int pictureRank) {
    return _flatInvoke("storeViewEp", {
      "comicId": comicId,
      "epOrder": epOrder,
      "epTitle": epTitle,
      "pictureRank": pictureRank,
    });
  }

  Future<ViewLog?> loadView(String comicId) async {
    String data = await _flatInvoke("loadView", comicId);
    if (data == "") {
      return null;
    }
    return ViewLog.fromJson(jsonDecode(data));
  }

  Future<bool> downloadRunning() async {
    String rsp = await _flatInvoke("downloadRunning", "");
    return rsp == "true";
  }

  Future<dynamic> setDownloadRunning(bool status) async {
    return _flatInvoke("setDownloadRunning", "$status");
  }

  Future<dynamic> createDownload(
      Map<String, dynamic> comic, List<Map<String, dynamic>> epList) async {
    return _flatInvoke("createDownload", {
      "comic": comic,
      "epList": epList,
    });
  }

  Future<dynamic> addDownload(
      Map<String, dynamic> comic, List<Map<String, dynamic>> epList) async {
    await _flatInvoke("addDownload", {
      "comic": comic,
      "epList": epList,
    });
  }

  Future<DownloadComic?> loadDownloadComic(String comicId) async {
    var data = await _flatInvoke("loadDownloadComic", comicId);
    // 未找到 且 未异常
    if (data == "") {
      return null;
    }
    return DownloadComic.fromJson(json.decode(data));
  }

  Future<List<DownloadComic>> allDownloads() async {
    var data = await _flatInvoke("allDownloads", "");
    data = jsonDecode(data);
    if (data == null) {
      return [];
    }
    List list = data;
    return list.map((e) => DownloadComic.fromJson(e)).toList();
  }

  Future<dynamic> deleteDownloadComic(String comicId) async {
    return _flatInvoke("deleteDownloadComic", comicId);
  }

  Future<List<DownloadEp>> downloadEpList(String comicId) async {
    var data = await _flatInvoke("downloadEpList", comicId);
    List list = json.decode(data);
    return list.map((e) => DownloadEp.fromJson(e)).toList();
  }

  Future<List<DownloadPicture>> downloadPicturesByEpId(String epId) async {
    var data = await _flatInvoke("downloadPicturesByEpId", epId);
    List list = json.decode(data);
    return list.map((e) => DownloadPicture.fromJson(e)).toList();
  }

  Future<dynamic> resetFailed() async {
    return _flatInvoke("resetAllDownloads", "");
  }

  Future<dynamic> exportComicDownload(String comicId, String dir) {
    return _flatInvoke("exportComicDownload", {
      "comicId": comicId,
      "dir": dir,
    });
  }

  Future<dynamic> importComicDownload(String zipPath) {
    return _flatInvoke("importComicDownload", zipPath);
  }

  Future<dynamic> open(String url) {
    return _flatInvoke("open", url);
  }

  Future<List<String>> downloadGame(String url) async {
    if (url.startsWith("https://game.eroge.xyz/hhh.php")) {
      var data = await _flatInvoke("downloadGame", url);
      return List.of(jsonDecode(data)).map((e) => e.toString()).toList();
    }
    return [url];
  }

}
