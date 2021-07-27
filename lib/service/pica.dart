import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pikapi/basic/Entities.dart';
import 'package:pikapi/basic/enum/Quality.dart';

final pica = Pica._();

class Pica {
  Pica._();

  MethodChannel _channel = MethodChannel("pica");

  Future<String> loadTheme() async {
    return await _channel.invokeMethod("loadProperty", {
      "name": "theme",
      "defaultValue": "dark",
    });
  }

  Future<dynamic> saveTheme(String code) async {
    return await _channel.invokeMethod("saveProperty", {
      "name": "theme",
      "value": code,
    });
  }

  Future<String> loadQuality() async {
    return await _channel.invokeMethod("loadProperty", {
      "name": "quality",
      "defaultValue": ImageQualityOriginal,
    });
  }

  Future<dynamic> saveQuality(String code) async {
    return await _channel.invokeMethod("saveProperty", {
      "name": "value",
      "value": code,
    });
  }

  Future<String> getSwitchAddress() async {
    return await _channel.invokeMethod("getSwitchAddress");
  }

  Future<dynamic> setSwitchAddress(String switchAddress) async {
    return await _channel.invokeMethod("setSwitchAddress", {
      "switchAddress": switchAddress,
    });
  }

  Future<String> getProxy() async {
    return await _channel.invokeMethod("getProxy");
  }

  Future<dynamic> setProxy(String proxy) async {
    return await _channel.invokeMethod("setProxy", {
      "proxy": proxy,
    });
  }

  Future<String> getUsername() async {
    return await _channel.invokeMethod("getUsername");
  }

  Future<dynamic> setUsername(String username) async {
    return await _channel.invokeMethod("setUsername", {
      "username": username,
    });
  }

  Future<String> getPassword() async {
    return await _channel.invokeMethod("getPassword");
  }

  Future<dynamic> setPassword(String password) async {
    return await _channel.invokeMethod("setPassword", {
      "password": password,
    });
  }

  Future<bool> preLogin() async {
    return await _channel.invokeMethod("preLogin");
  }

  Future<dynamic> login() async {
    return await _channel.invokeMethod("login");
  }

  Future<RemoteImageData> remoteImageData(
      String fileServer, String path) async {
    var responseMap = await _channel.invokeMethod("remoteImageData", {
      "fileServer": fileServer,
      "path": path,
    });
    var response = json.decode(responseMap);
    return RemoteImageData.fromJson(response);
  }

  Future<List<Category>> categories() async {
    String data = await _channel.invokeMethod("categories");
    List list = json.decode(data);
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<ComicsPage> comics(String category, String sort, int page) async {
    var rsp = await _channel.invokeMethod("comics", {
      "category": category,
      "sort": sort,
      "page": page,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<ComicsPage> searchComics(String keyword, String sort, int page) async {
    var rsp = await _channel.invokeMethod("searchComics", {
      "keyword": keyword,
      "sort": sort,
      "page": page,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<ComicsPage> searchComicsInCategories(
      String keyword, String sort, int page, List<String> categories) async {
    var rsp = await _channel.invokeMethod("searchComicsInCategories", {
      "keyword": keyword,
      "sort": sort,
      "page": page,
      "categories": categories,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<ComicInfo> comicInfo(String comicId) async {
    var rsp = await _channel.invokeMethod("comicInfo", {
      "comicId": comicId,
    });
    return ComicInfo.fromJson(json.decode(rsp));
  }

  Future<EpPage> comicEpPage(String comicId, int page) async {
    var rsp = await _channel.invokeMethod("comicEpPage", {
      "comicId": comicId,
      "page": page,
    });
    return EpPage.fromJson(json.decode(rsp));
  }

  Future<PicturePage> comicPicturePageWithQuality(
      String comicId, int epOrder, int page, String quality) async {
    var data = (await _channel.invokeMethod(
      "comicPicturePageWithQuality",
      {
        "comicId": comicId,
        "epOrder": epOrder,
        "page": page,
        "quality": quality,
      },
    ));
    return PicturePage.fromJson(json.decode(data));
  }

  Future<DownloadComicWithLogoPath?> loadDownloadComic(String comicId) async {
    var data = await _channel.invokeMethod("downloadComic", {
      "comicId": comicId,
    });
    // 未找到 且 未异常
    if (data == "") {
      return null;
    }
    return DownloadComicWithLogoPath.fromJson(json.decode(data));
  }

  Future<RemoteImageData> downloadComicThumb(String comicId) async {
    var responseMap = await _channel.invokeMethod("downloadComicThumb", {
      "comicId": comicId,
    });
    var response = json.decode(responseMap);
    return RemoteImageData.fromJson(response);
  }

  Future<List<DownloadEp>> downloadEpList(String comicId) async {
    var data = await _channel.invokeMethod("downloadEpList", {
      "comicId": comicId,
    });
    List list = json.decode(data);
    return list.map((e) => DownloadEp.fromJson(e)).toList();
  }

  Future createDownload(DownloadComic comic, List<DownloadEp> epList) async {
    await _channel.invokeMethod("createDownload", {
      "comic": json.encode(comic.toJson()),
      "epList": json.encode(epList.map((e) => e.toJson()).toList()),
    });
  }

  Future addDownload(DownloadComic comic, List<DownloadEp> epList) async {
    await _channel.invokeMethod("addDownload", {
      "comic": jsonEncode(comic.toJson()),
      "epList": jsonEncode(epList.map((e) => e.toJson()).toList()),
    });
  }

  Future<List<DownloadComicWithLogoPath>> allDownloads() async {
    var data = await _channel.invokeMethod("allDownloads");
    List list = json.decode(data);
    return list.map((e) => DownloadComicWithLogoPath.fromJson(e)).toList();
  }

  Future<List<DownloadPicture>> downloadPicturesByEpId(String epId) async {
    var data = await _channel.invokeMethod("downloadPicturesByEpId", {
      "epId": epId,
    });
    List list = json.decode(data);
    return list.map((e) => DownloadPicture.fromJson(e)).toList();
  }

  Future resetFailed() async {
    await _channel.invokeMethod("resetAllDownloads");
  }

  Future<List<ViewLog>> viewLogPage(int page, int pageSize) async {
    var data = await _channel.invokeMethod("viewLogPage", {
      "page": page,
      "pageSize": pageSize,
    });
    List list = json.decode(data);
    return list.map((e) => ViewLog.fromJson(e)).toList();
  }

  Future exportComicDownload(String comicId, String dir) async {
    await _channel.invokeMethod("exportComicDownload", {
      "comicId": comicId,
      "dir": dir,
    });
  }

  Future importComicDownload(String zipPath) async {
    await _channel.invokeMethod("importComicDownload", {
      "zipPath": zipPath,
    });
  }

  Future<String> switchLike(String comicId) async {
    var rsp = await _channel.invokeMethod("switchLike", {
      "comicId": comicId,
    });
    return rsp;
  }

  Future<ComicsPage> favouriteComics(String sort, int page) async {
    var rsp = await _channel.invokeMethod("favouriteComics", {
      "sort": sort,
      "page": page,
    });
    return ComicsPage.fromJson(json.decode(rsp));
  }

  Future<String> switchFavourite(String comicId) async {
    var rsp = await _channel.invokeMethod("switchFavourite", {
      "comicId": comicId,
    });
    return rsp;
  }
}

class DownloadPicture {
  late int rankInEp;
  late String fileServer;
  late String path;
  late String localPath;
  late String finalPath;

  DownloadPicture.fromJson(Map<String, dynamic> json) {
    this.rankInEp = json["rankInEp"];
    this.fileServer = json["fileServer"];
    this.path = json["path"];
    this.localPath = json["localPath"];
    this.finalPath = json["finalPath"];
  }
}

class ViewLog {
  late String id;
  late String title;
  late String author;
  late int pagesCount;
  late int epsCount;
  late bool finished;
  late String categories;
  late String thumbOriginalName;
  late String thumbFileServer;
  late String thumbPath;
  late String description;
  late String chineseTeam;
  late String tags;
  late String lastViewTime;
  late int lastViewEpOrder;
  late String lastViewEpTitle;
  late int lastViewPictureRank;

  ViewLog.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.title = json["title"];
    this.author = json["author"];
    this.pagesCount = json["pagesCount"];
    this.epsCount = json["epsCount"];
    this.finished = json["finished"];
    this.categories = json["categories"];
    this.thumbOriginalName = json["thumbOriginalName"];
    this.thumbFileServer = json["thumbFileServer"];
    this.thumbPath = json["thumbPath"];
    this.description = json["description"];
    this.chineseTeam = json["chineseTeam"];
    this.tags = json["tags"];
    this.lastViewTime = json["lastViewTime"];
    this.lastViewEpOrder = json["lastViewEpOrder"];
    this.lastViewEpTitle = json["lastViewEpTitle"];
    this.lastViewPictureRank = json["lastViewPictureRank"];
  }
}

class DownloadComic {
  late String id;
  late String createdAt;
  late String updatedAt;
  late String title;
  late String author;
  late int pagesCount;
  late int epsCount;
  late bool finished;

  late String categories;
  late String thumbOriginalName;
  late String thumbFileServer;
  late String thumbPath;

  late String description;
  late String chineseTeam;
  late String tags;
  late int selectedEpCount;
  late int selectedPictureCount;
  late int downloadEpCount;
  late int downloadPictureCount;
  late bool downloadFinished;
  late String downloadFinishedTime;
  late bool downloadFailed;

  late bool deleting;

  DownloadComic(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.author,
    this.pagesCount,
    this.epsCount,
    this.finished,
    this.categories,
    this.thumbOriginalName,
    this.thumbFileServer,
    this.thumbPath,
    this.description,
    this.chineseTeam,
    this.tags,
  );

  void copy(DownloadComic other) {
    this.id = other.id;
    this.createdAt = other.createdAt;
    this.updatedAt = other.updatedAt;
    this.title = other.title;
    this.author = other.author;
    this.pagesCount = other.pagesCount;
    this.epsCount = other.epsCount;
    this.finished = other.finished;
    this.categories = other.categories;
    this.thumbOriginalName = other.thumbOriginalName;
    this.thumbFileServer = other.thumbFileServer;
    this.thumbPath = other.thumbPath;
    this.description = other.description;
    this.chineseTeam = other.chineseTeam;
    this.tags = other.tags;
    this.selectedEpCount = other.selectedEpCount;
    this.selectedPictureCount = other.selectedPictureCount;
    this.downloadEpCount = other.downloadEpCount;
    this.downloadPictureCount = other.downloadPictureCount;
    this.downloadFinished = other.downloadFinished;
    this.downloadFinishedTime = other.downloadFinishedTime;
    this.downloadFailed = other.downloadFailed;
    this.deleting = other.deleting;
  }

  Map<String, dynamic> toJson() => {
        "id": this.id,
        "createdAt": this.createdAt,
        "updatedAt": this.updatedAt,
        "title": this.title,
        "author": this.author,
        "pagesCount": this.pagesCount,
        "epsCount": this.epsCount,
        "finished": this.finished,
        "categories": this.categories,
        "thumbOriginalName": this.thumbOriginalName,
        "thumbFileServer": this.thumbFileServer,
        "thumbPath": this.thumbPath,
        "description": this.description,
        "`chineseTeam": this.chineseTeam,
        "tags": this.tags,
      };

  DownloadComic.fromJson(Map<String, dynamic> json) {
    this.id = json["id"];
    this.createdAt = (json["createdAt"]);
    this.updatedAt = (json["updatedAt"]);
    this.title = json["title"];
    this.author = json["author"];
    this.pagesCount = json["pagesCount"];
    this.epsCount = json["epsCount"];
    this.finished = json["finished"];
    this.categories = json["categories"];
    this.thumbOriginalName = json["thumbOriginalName"];
    this.thumbFileServer = json["thumbFileServer"];
    this.thumbPath = json["thumbPath"];
    this.description = json["description"];
    this.chineseTeam = json["chineseTeam"];
    this.tags = json["tags"];
    this.selectedEpCount = json["selectedEpCount"];
    this.selectedPictureCount = json["selectedPictureCount"];
    this.downloadEpCount = json["downloadEpCount"];
    this.downloadPictureCount = json["downloadPictureCount"];
    this.downloadFinished = json["downloadFinished"];
    this.downloadFinishedTime = json["downloadFinishedTime"];
    this.downloadFailed = json["downloadFailed"];
    this.deleting = json["deleting"];
  }
}

class DownloadEp {
  late String comicId;
  late String id;
  late String updatedAt;

  late int epOrder;
  late String title;

  late bool fetchedPictures;
  late int selectedPictureCount;
  late int downloadPictureCount;
  late bool downloadFinish;
  late String downloadFinishTime;
  late bool downloadFailed;

  DownloadEp(
    this.comicId,
    this.id,
    this.updatedAt,
    this.epOrder,
    this.title,
  );

  Map<String, dynamic> toJson() => {
        "comicId": comicId,
        "id": id,
        "updatedAt": updatedAt,
        "epOrder": epOrder,
        "title": title,
      };

  DownloadEp.fromJson(Map<String, dynamic> json) {
    this.comicId = json["comicId"];
    this.id = json["id"];
    this.epOrder = json["epOrder"];
    this.title = json["title"];

    this.fetchedPictures = json["fetchedPictures"];
    this.selectedPictureCount = json["selectedPictureCount"];
    this.downloadPictureCount = json["downloadPictureCount"];
    this.downloadFinish = json["downloadFinish"];
    this.downloadFinishTime = json["downloadFinishTime"];
    this.downloadFailed = json["downloadFailed"];
  }
}

class DownloadComicWithLogoPath extends DownloadComic {
  late String logoPath;

  DownloadComicWithLogoPath.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    this.logoPath = json["logoPath"];
  }
}
