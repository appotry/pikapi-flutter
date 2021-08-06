package controller

import (
	"crypto/md5"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	path2 "path"
	"pgo/pikapi/const_value"
	"pgo/pikapi/database/comic_center"
	"pgo/pikapi/database/network_cache"
	"pgo/pikapi/database/properties"
	"pgo/pikapi/utils"
	"runtime"
	"strconv"
)

var (
	remoteDir   string
	downloadDir string
)

func InitPlugin(_remoteDir string, _downloadDir string) {
	remoteDir = _remoteDir
	downloadDir = _downloadDir
	comic_center.ResetAll()
	go downloadBackground()
	downloadRunning = true
}

func remotePath(path string) string {
	return path2.Join(remoteDir, path)
}

func downloadPath(path string) string {
	return path2.Join(downloadDir, path)
}

func saveProperty(params string) error {
	var paramsStruct struct {
		Name  string `json:"name"`
		Value string `json:"value"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	return properties.SaveProperty(paramsStruct.Name, paramsStruct.Value)
}

func loadProperty(params string) (string, error) {
	var paramsStruct struct {
		Name         string `json:"name"`
		DefaultValue string `json:"defaultValue"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	return properties.LoadProperty(paramsStruct.Name, paramsStruct.DefaultValue)
}

func setSwitchAddress(nSwitchAddress string) error {
	err := properties.SaveSwitchAddress(nSwitchAddress)
	if err != nil {
		return err
	}
	switchAddress = nSwitchAddress
	return nil
}

func getSwitchAddress() (string, error) {
	return switchAddress, nil
}

func setProxy(value string) error {
	err := properties.SaveProxy(value)
	if err != nil {
		return err
	}
	changeProxyUrl(value)
	return nil
}

func getProxy() (string, error) {
	return properties.LoadProxy()
}

func setUsername(value string) error {
	return properties.SaveUsername(value)
}

func getUsername() (string, error) {
	return properties.LoadUsername()
}

func setPassword(value string) error {
	return properties.SavePassword(value)
}

func getPassword() (string, error) {
	return properties.LoadPassword()
}

func preLogin() (string, error) {
	token, _ := properties.LoadToken()
	tokenTime, _ := properties.LoadTokenTime()
	if token != "" && tokenTime > 0 {
		if utils.Timestamp()-(1000*60*60*24) < tokenTime {
			client.Token = token
			return "true", nil
		}
	}
	err := login()
	if err == nil {
		return "true", nil
	}
	return "false", nil
}

func login() error {
	username, _ := properties.LoadUsername()
	password, _ := properties.LoadPassword()
	if password == "" || username == "" {
		return errors.New(" 需要设定用户名和密码 ")
	}
	err := client.Login(username, password)
	if err != nil {
		return err
	}
	properties.SaveToken(client.Token)
	properties.SaveTokenTime(utils.Timestamp())
	return nil
}

func userProfile() (string, error) {
	return serialize(client.UserProfile())
}

func punchIn() (string, error) {
	return serialize(client.PunchIn())
}

func remoteImageData(params string) (string, error) {
	var paramsStruct struct {
		FileServer string `json:"fileServer"`
		Path       string `json:"path"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	fileServer := paramsStruct.FileServer
	path := paramsStruct.Path
	lock := utils.HashLock(fmt.Sprintf("%s$%s", fileServer, path))
	lock.Lock()
	defer lock.Unlock()
	cache := comic_center.FindRemoteImage(fileServer, path)
	if cache == nil {
		buff, img, format, err := decodeFromUrl(fileServer, path)
		if err != nil {
			println(fmt.Sprintf("decode error : %s/static/%s %s", fileServer, path, err.Error()))
			return "", err
		}
		local :=
			fmt.Sprintf("%x",
				md5.Sum([]byte(fmt.Sprintf("%s$%s", fileServer, path))),
			)
		real := remotePath(local)
		err = os.WriteFile(
			real,
			buff, os.FileMode(0600),
		)
		if err != nil {
			return "", err
		}
		remote := comic_center.RemoteImage{
			FileServer: fileServer,
			Path:       path,
			FileSize:   int64(len(buff)),
			Format:     format,
			Width:      int32(img.Bounds().Dx()),
			Height:     int32(img.Bounds().Dy()),
			LocalPath:  local,
		}
		err = comic_center.SaveRemoteImage(&remote)
		if err != nil {
			return "", err
		}
		cache = &remote
	}
	display := DisplayImageData{
		FileSize:  cache.FileSize,
		Format:    cache.Format,
		Width:     cache.Width,
		Height:    cache.Height,
		FinalPath: remotePath(cache.LocalPath),
	}
	return serialize(&display, nil)
}

func downloadImagePath(path string) (string, error) {
	return downloadPath(path), nil
}

func createDownload(params string) error {
	var paramsStruct struct {
		Comic  comic_center.ComicDownload     `json:"comic"`
		EpList []comic_center.ComicDownloadEp `json:"epList"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	comic := paramsStruct.Comic
	epList := paramsStruct.EpList
	if comic.Title == "" || len(epList) == 0 {
		return errors.New("params error")
	}
	err := comic_center.CreateDownload(&comic, &epList)
	if err != nil {
		return err
	}
	// 创建文件夹
	utils.Mkdir(downloadPath(comic.ID))
	// 复制图标
	downloadComicLogo(&comic)
	return nil
}

func downloadComicLogo(comic *comic_center.ComicDownload) {
	lock := utils.HashLock(fmt.Sprintf("%s$%s", comic.ThumbFileServer, comic.ThumbPath))
	lock.Lock()
	defer lock.Unlock()
	buff, image, format, err := decodeFromCache(comic.ThumbFileServer, comic.ThumbPath)
	if err != nil {
		buff, image, format, err = decodeFromUrl(comic.ThumbFileServer, comic.ThumbPath)
	}
	if err == nil {
		comicLogoPath := path2.Join(comic.ID, "logo")
		ioutil.WriteFile(downloadPath(comicLogoPath), buff, const_value.CreateFileMode)
		comic_center.UpdateDownloadLogo(
			comic.ID,
			int64(len(buff)),
			format,
			int32(image.Bounds().Dx()),
			int32(image.Bounds().Dy()),
			comicLogoPath,
		)
		comic.ThumbFileSize = int64(len(buff))
		comic.ThumbFormat = format
		comic.ThumbWidth = int32(image.Bounds().Dx())
		comic.ThumbHeight = int32(image.Bounds().Dy())
		comic.ThumbLocalPath = comicLogoPath
	}
	if err != nil {
		println(err.Error())
	}
}

func addDownload(params string) error {
	var paramsStruct struct {
		Comic  comic_center.ComicDownload     `json:"comic"`
		EpList []comic_center.ComicDownloadEp `json:"epList"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	comic := paramsStruct.Comic
	epList := paramsStruct.EpList
	if comic.Title == "" || len(epList) == 0 {
		return errors.New("params error")
	}
	return comic_center.AddDownload(&comic, &epList)
}

func deleteDownloadComic(comicId string) error {
	err := comic_center.Deleting(comicId)
	if err != nil {
		return err
	}
	downloadRestart = true
	return nil
}

func loadDownloadComic(comicId string) (string, error) {
	download, err := comic_center.FindComicDownloadById(comicId)
	if err != nil {
		return "", err
	}
	if download == nil {
		return "", nil
	}
	comic_center.ViewComic(comicId) // VIEW
	return serialize(download, err)
}

func allDownloads() (string, error) {
	return serialize(comic_center.AllDownloads())
}

func downloadEpList(comicId string) (string, error) {
	return serialize(comic_center.ListDownloadEpByComicId(comicId))
}

func viewLogPage(params string) (string, error) {
	var paramsStruct struct {
		Page     int `json:"page"`
		PageSize int `json:"pageSize"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	page := paramsStruct.Page
	pageSize := paramsStruct.PageSize
	return serialize(comic_center.ViewLogPage(page, pageSize))
}

func downloadPicturesByEpId(epId string) (string, error) {
	return serialize(comic_center.ListDownloadPictureByEpId(epId))
}

func getDownloadRunning() bool {
	return downloadRunning
}

func setDownloadRunning(status bool) {
	downloadRunning = status
}

func clean() error {
	var err error
	notifyExport("清理网络缓存")
	err = network_cache.RemoveAll()
	if err != nil {
		return err
	}
	notifyExport("清理图片缓存")
	err = comic_center.RemoveAllRemoteImage()
	if err != nil {
		return err
	}
	notifyExport("清理图片文件")
	os.RemoveAll(remoteDir)
	utils.Mkdir(remoteDir)
	notifyExport("清理结束")
	return nil
}

func storeViewEp(params string) error {
	var paramsStruct struct {
		ComicId     string `json:"comicId"`
		EpOrder     int    `json:"epOrder"`
		EpTitle     string `json:"epTitle"`
		PictureRank int    `json:"pictureRank"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	return comic_center.ViewEpAndPicture(
		paramsStruct.ComicId,
		paramsStruct.EpOrder,
		paramsStruct.EpTitle,
		paramsStruct.PictureRank,
	)
}

func loadView(comicId string) (string, error) {
	view, err := comic_center.LoadViewLog(comicId)
	if err != nil {
		return "", nil
	}
	if view != nil {
		b, err := json.Marshal(view)
		if err != nil {
			return "", err
		}
		return string(b), nil
	}
	return "", nil
}

var commands = map[string]string{
	"windows": "cmd /c start",
	"darwin":  "open",
	"linux":   "xdg-open",
}

// Open calls the OS default program for uri
func open(uri string) error {
	run, ok := commands[runtime.GOOS]
	if !ok {
		return fmt.Errorf("don't know how to open things on %s platform", runtime.GOOS)
	}
	cmd := exec.Command(run, uri)
	return cmd.Start()
}

func FlatInvoke(method string, params string) (string, error) {
	switch method {
	case "setSwitchAddress":
		return "", setSwitchAddress(params)
	case "getSwitchAddress":
		return getSwitchAddress()
	case "setProxy":
		return "", setProxy(params)
	case "getProxy":
		return getProxy()
	case "saveProperty":
		return "", saveProperty(params)
	case "loadProperty":
		return loadProperty(params)
	case "setUsername":
		return "", setUsername(params)
	case "setPassword":
		return "", setPassword(params)
	case "getUsername":
		return getUsername()
	case "getPassword":
		return getPassword()
	case "preLogin":
		return preLogin()
	case "login":
		return "", login()
	case "userProfile":
		return userProfile()
	case "punchIn":
		return punchIn()
	case "categories":
		return categories()
	case "comics":
		return comics(params)
	case "searchComics":
		return searchComics(params)
	case "randomComics":
		return randomComics()
	case "leaderboard":
		return leaderboard(params)
	case "comicInfo":
		return comicInfo(params)
	case "comicEpPage":
		return epPage(params)
	case "comicPicturePageWithQuality":
		return comicPicturePageWithQuality(params)
	case "switchLike":
		return switchLike(params)
	case "switchFavourite":
		return switchFavourite(params)
	case "favouriteComics":
		return favouriteComics(params)
	case "recommendation":
		return recommendation(params)
	case "comments":
		return comments(params)
	case "game":
		return game(params)
	case "games":
		return games(params)
	case "viewLogPage":
		return viewLogPage(params)
	case "clean":
		return "", clean()
	case "storeViewEp":
		return "", storeViewEp(params)
	case "loadView":
		return loadView(params)
	case "downloadRunning":
		return strconv.FormatBool(getDownloadRunning()), nil
	case "setDownloadRunning":
		b, e := strconv.ParseBool(params)
		if e != nil {
			setDownloadRunning(b)
		}
		return "", e
	case "createDownload":
		return "", createDownload(params)
	case "addDownload":
		return "", addDownload(params)
	case "loadDownloadComic":
		return loadDownloadComic(params)
	case "allDownloads":
		return allDownloads()
	case "deleteDownloadComic":
		return "", deleteDownloadComic(params)
	case "downloadEpList":
		return downloadEpList(params)
	case "downloadPicturesByEpId":
		return downloadPicturesByEpId(params)
	case "resetAllDownloads":
		return "", comic_center.ResetAll()
	case "exportComicDownload":
		return "", exportComicDownload(params)
	case "importComicDownload":
		return "", importComicDownload(params)
	case "remoteImageData":
		return remoteImageData(params)
	case "downloadImagePath":
		return downloadImagePath(params)
	case "open":
		return "", open(params)
	case "downloadGame":
		return downloadGame(params)
	}
	return "", errors.New("method not found : " + method)
}
