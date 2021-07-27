
import 'dart:convert';
import 'dart:typed_data';

class PicaImage {
  late String originalName;
  late String path;
  late String fileServer;

  PicaImage.fromJson(Map<String, dynamic> json) {
    this.originalName = json["originalName"];
    this.path = json["path"];
    this.fileServer = json["fileServer"];
  }
}

class Page {
  late int total;
  late int limit;
  late int page;
  late int pages;

  Page.fromJson(Map<String, dynamic> json) {
    this.total = json["total"];
    this.limit = json["limit"];
    this.page = json["page"];
    this.pages = json["pages"];
  }
}

class Category {
  late String id;
  late String title;
  late String description;
  late PicaImage thumb;
  late bool isWeb;
  late bool active;
  late String link;

  Category.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.title = json["title"];
    this.description = json["description"];
    this.thumb = PicaImage.fromJson(json["thumb"]);
    this.isWeb = json["isWeb"];
    this.active = json["active"];
    this.link = json["link"];
  }
}

class ComicsPage extends Page {
  late List<ComicSimple> docs;

  ComicsPage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs = List.from(json["docs"])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => ComicSimple.fromJson(e))
        .toList();
  }
}

class ComicSimple {
  late String id;
  late String title;
  late String author;
  late int pagesCount;
  late int epsCount;
  late bool finished;
  late List<String> categories;
  late PicaImage thumb;
  late int likesCount;

  ComicSimple.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.title = json["title"];
    this.author = json["author"];
    this.pagesCount = json["pagesCount"];
    this.epsCount = json["epsCount"];
    this.finished = json["finished"];
    this.categories = List<String>.from(json["categories"]);
    this.thumb = PicaImage.fromJson(json["thumb"]);
    this.likesCount = json["likesCount"];
  }
}

class ComicInfo extends ComicSimple {
  late String description;
  late String chineseTeam;
  late List<String> tags;
  late String updatedAt;
  late String createdAt;
  late bool allowDownload;
  late int viewsCount;
  late bool isFavourite;
  late bool isLiked;
  late int commentsCount;

  ComicInfo.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.description = json["description"];
    this.chineseTeam = json["chineseTeam"];
    this.tags = List<String>.from(json["tags"]);
    this.updatedAt = (json["updated_at"]);
    this.createdAt = (json["created_at"]);
    this.allowDownload = json["allowDownload"];
    this.viewsCount = json["viewsCount"];
    this.isFavourite = json["isFavourite"];
    this.isLiked = json["isLiked"];
    this.commentsCount = json["commentsCount"];
  }
}

class Ep {
  late String id;
  late String title;
  late int order;
  late String updatedAt;

  Ep.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.title = json["title"];
    this.order = json["order"];
    this.updatedAt = (json["updated_at"]);
  }
}

class EpPage extends Page {
  late List<Ep> docs;

  EpPage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs = List.from(json["docs"])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => Ep.fromJson(e))
        .toList();
  }
}

class PicturePage extends Page {
  late List<Picture> docs;
  PicturePage.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    this.docs = List.from(json["docs"])
        .map((e) => Map<String, dynamic>.from(e))
        .map((e) => Picture.fromJson(e))
        .toList();
  }
}

class Picture {
  late String id;
  late PicaImage media;

  Picture.fromJson(Map<String, dynamic> json) {
    this.id = json["_id"];
    this.media = PicaImage.fromJson(json["media"]);
  }
}

class RemoteImageData {
  late String fileServer;
  late String path;
  late int fileSize;
  late String format;
  late int width;
  late int height;
  late Uint8List buff;

  RemoteImageData.fromJson(Map<String, dynamic> json) {
    this.fileServer = json["fileServer"];
    this.path = json["path"];
    this.fileSize = json["fileSize"];
    this.format = json["format"];
    this.width = json["width"];
    this.height = json["height"];
    this.buff = base64Decode(json["buffBase64"]);
  }
}

