PIKAPI - 哔咔客户端
========
[![license](https://img.shields.io/github/license/niuhuan/pikapi-flutter)](https://raw.githubusercontent.com/niuhuan/pikapi-flutter/master/LICENSE)
[![releases](https://img.shields.io/github/v/release/niuhuan/pikapi-flutter)](https://github.com/niuhuan/pikapi-flutter/releases)
[![downloads](https://img.shields.io/github/downloads/niuhuan/pikapi-flutter/total)](https://github.com/niuhuan/pikapi-flutter/releases)

- 美观易用且无广告的哔咔漫画客户端, 能运行在Windows/MacOS/Linux/Android/IOS中。
- 您的star和issue是对开发者的莫大鼓励, 可以源仓库下载最新的源码/安装包, 表示支持/提出建议。
- 源仓库地址 [https://github.com/niuhuan/pikapi-flutter](https://github.com/niuhuan/pikapi-flutter)


- 本仓库仅作为学习交流使用, 请您遵守当地法律法规以及开源协议。
- 本软件为浏览器, 不包含任何漫画内容, 如有疑问请与我联系。

## 界面 / 功能

![阅读器](images/reader.png)

### 登录/注册/分流

您需要注册或登录一个哔卡账户, 才能使用本软件。注册只需要提供账号和密码。

VPN->代理->分流, 这三个功能如果同时设置, 您会在您手机的VPN上访问代理, 使用代理请求分流服务器, 所以最好只设置一个, 分流2/3在北京地区网速非常良好。

### 漫画分类/搜索

![分类](images/categories_screen.png) ![列表](images/comic_list.png)


### 漫画阅读/下载/导入/导出

您可以在除IOS外导出任意已经完成的下载到zip, 从另外一台设备导入。
导出的zip解压后可以直接使用其中的HTML进行阅读

![导出下载](images/exporting.png)

![HTML预览](images/exporting2.png)

### 游戏

![games](images/games.png)
![game](images/game.png)

## 特性

- [x] 用户
  - [x] 登录 / 注册 / 获取个人信息 / 自动打哔卡
- [x] 漫画
  - [x] 分类 / 搜索 / 随机本子 / 看此本子的也在看 / 排行榜
  - [x] 在分类中搜索 / 按 "分类 / 标签 / 创建人 / 汉化组" 检索
  - [x] 漫画详情 / 章节 / 看图 / 将图片保存到相册
  - [x] 收藏 / 喜欢
  - [x] 获取评论 / 评论 / 评论回复 (哔咔社区评论后无法删除, 请谨慎使用)
- [x] 游戏
  - [x] 列表 / 详情 / 无广告下载
- [x] 下载
  - [x] 导入导出 / 无线共享 / 移动设备与PC设备传输
- [ ] 聊天室
- [x] 缓存 / 清理

## 其他说明

- 在ios/android环境 数据文件将会保存在程序自身数据目录中, 删除就会清理
- 在 windows 数据文件将会保存在程序同一目录
- 在 macos 数据文件将会"~/Library/Application Support/pikapi"
- 在 linux 数据文件将会"~/.pikapi"

## 运行 / 构建

如果构建本程序需要将子模块一起克隆, 或下载解压到指定的位置

这个应用程序使用golang和dart(flutter)作为主要语言, 可以兼容Windows, linux, MacOS, Android, IOS

使用了不同的框架桥接到桌面和移动平台上
- go-flutter => Windows / MacOS / Linux
- gomobile => Android / IOS

![平台](images/platforms.png)

### 开发环境准备

- [golang](https://golang.org/) (1.16以上版本)
- [flutter](https://flutter.dev/)

### 环境配置

- 将~/go/bin (GoPath/bin) 设置到PATH环境变量内
- golang开启模块化
- 设置GoProxy (可选,在中国大陆网络建议设置)
- 参考地址 [https://goproxy.cn/](https://goproxy.cn/)


### 桌面平台 (go-flutter)

- [安装hover(go-flutter编译脚手架)](https://github.com/go-flutter-desktop/hover)
- 执行编译命令
  ```shell
  hover run
  hover build $system
  ```

### Linux的附加说明

- linux编译可能会遇到的问题
  ```shell
  # No package 'gl' found
  sudo apt install libgl1-mesa-dev
  # X11/Xlib.h: No such file or directory
  # 或者更多x11的头找不到等
  sudo apt install xorg-dev
  ```
- 字体不显示的问题
  ```shell
    cp /usr/share/fonts/truetype/droid/DroidSansFallbackFull.ttf fonts/
  ```
  ```yaml
    fonts:
    - family: Roboto
      fonts:
        - asset: fonts/DroidSansFallbackFull.ttf
  ```

### 移动端 (gomobile)

- [安装gomobile](https://github.com/golang/mobile)
- 执行编译命令 (bind-android.sh / bind-ios.sh 根据平台选择) 
  ```shell
  cd go/mobile
  sh bind-ios.sh
  sh bind-android.sh
  cd ../../
  flutter build $system
  ```

## 请您遵守使用规则
本软件或本软件的拓展, 个人或企业不可用于商业用途, 不可上架任何商店

拓展包括但是不限于以下内容
- 使用本软件进行继续开发形成的软件。
- 引入本软件部分内容为依赖/参考本软件/使用本软件内代码的同时, 包含本软件内一致内容或功能的软件。
- 直接对本软件进行打包发布
