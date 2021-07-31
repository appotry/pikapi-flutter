package controller

import (
	"crypto/md5"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	path2 "path"
	"pgo/pikapi/const_value"
	"pgo/pikapi/database/comic_center"
	"pgo/pikapi/database/network_cache"
	"pgo/pikapi/database/properties"
	"pgo/pikapi/utils"
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

func SaveProperty(name string, value string) {
	properties.LoadProperty(name, value)
}

func LoadProperty(name string, defaultValue string) string {
	return properties.LoadProperty(name, defaultValue)
}

func SetSwitchAddress(nSwitchAddress string) {
	properties.SaveSwitchAddress(nSwitchAddress)
	switchAddress = nSwitchAddress
}

func GetSwitchAddress() string {
	return switchAddress
}

func SetProxy(value string) {
	properties.SaveProxy(value)
	changeProxyUrl(value)
}

func GetProxy() string {
	return properties.LoadProxy()
}

func SetUsername(value string) {
	properties.SaveUsername(value)
}

func GetUsername() string {
	return properties.LoadUsername()
}

func SetPassword(value string) {
	properties.SavePassword(value)
}

func GetPassword() string {
	return properties.LoadPassword()
}

func PreLogin() (bool, error) {
	token := properties.LoadToken()
	tokenTime := properties.LoadTokenTime()
	if token != "" && tokenTime > 0 {
		if utils.Timestamp()-(1000*60*60*24) < tokenTime {
			client.Token = token
			return true, nil
		}
	}
	err := Login()
	if err == nil {
		return true, nil
	}
	return false, nil
}

func Login() error {
	username := properties.LoadUsername()
	password := properties.LoadPassword()
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

func loadRemoteImage(fileServer string, path string) (*DisplayImageData, error) {
	lock := utils.HashLock(fmt.Sprintf("%s$%s", fileServer, path))
	lock.Lock()
	defer lock.Unlock()
	cache := comic_center.FindRemoteImage(fileServer, path)
	if cache == nil {
		buff, img, format, err := decodeFromUrl(fileServer, path)
		if err != nil {
			return nil, err
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
			return nil, err
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
			return nil, err
		}
		cache = &remote
	}
	real := remotePath(cache.LocalPath)
	buff, err := ioutil.ReadFile(real)
	if err != nil {
		return nil, err
	}
	var display DisplayImageData
	display.RemoteImage = *cache
	display.BuffBase64 = base64.StdEncoding.EncodeToString(buff)
	return &display, nil
}

func RemoteImageData(fileServer string, path string) (string, error) {
	display, err := loadRemoteImage(fileServer, path)
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(display)
	if err != nil {
		return "", err
	}
	return string(buff), nil
}

func CreateDownload(comicStr string, epListStr string) error {
	var comic comic_center.ComicDownload
	var epList []comic_center.ComicDownloadEp
	err := json.Unmarshal([]byte(comicStr), &comic)
	if err != nil {
		return err
	}
	err = json.Unmarshal([]byte(epListStr), &epList)
	if err != nil {
		return err
	}
	if comic.Title == "" || len(epList) == 0 {
		return errors.New("params error")
	}
	err = comic_center.CreateDownload(&comic, &epList)
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

func AddDownload(comicStr string, epListStr string) error {
	var comic comic_center.ComicDownload
	var epList []comic_center.ComicDownloadEp
	err := json.Unmarshal([]byte(comicStr), &comic)
	if err != nil {
		return err
	}
	err = json.Unmarshal([]byte(epListStr), &epList)
	if err != nil {
		return err
	}
	if comic.Title == "" || len(epList) == 0 {
		return errors.New("params error")
	}
	return comic_center.AddDownload(&comic, &epList)
}

func checkLogo(download comic_center.ComicDownload) ComicDownloadWithLogoPath {
	var c ComicDownloadWithLogoPath
	c.ComicDownload = download
	if download.ThumbLocalPath != "" {
		c.LogoPath = downloadPath(download.ThumbLocalPath)
	}
	return c
}

func DeleteDownloadComic(comicId string) error {
	err := comic_center.Deleting(comicId)
	if err != nil {
		return err
	}
	downloadRestart = true
	return nil
}

func LoadDownloadComic(comicId string) (string, error) {
	download, err := comic_center.FindComicDownloadById(comicId)
	if err != nil {
		return "", err
	}
	if download == nil {
		return "", nil
	}
	c := checkLogo(*download)
	buff, err := json.Marshal(&c)
	if err != nil {
		return "", err
	}
	// VIEW
	comic_center.ViewComic(comicId)
	//
	return string(buff), nil
}

func DownloadComicThumb(comicId string) (string, error) {
	comic, _ := comic_center.FindComicDownloadById(comicId)
	if comic != nil {
		if comic.ThumbLocalPath == "" {
			downloadComicLogo(comic)
		}
		if comic.ThumbLocalPath != "" {
			buff, err := ioutil.ReadFile(downloadPath(comic.ThumbLocalPath))
			if err != nil {
				return "", err
			}
			var display DisplayImageData
			display.FileSize = comic.ThumbFileSize
			display.Width = comic.ThumbWidth
			display.Height = comic.ThumbHeight
			display.Format = comic.ThumbFormat
			display.BuffBase64 = base64.StdEncoding.EncodeToString(buff)
			//
			buff, err = json.Marshal(display)
			if err != nil {
				return "", err
			}
			return string(buff), nil
		}
		return "", errors.New("not download thumb")
	}
	return "", errors.New("not download")
}

func AllDownloads() (string, error) {
	downloads, err := comic_center.AllDownloads()
	if err != nil {
		return "", err
	}
	var downloadWithLogoPaths = make([]ComicDownloadWithLogoPath, 0)
	for _, download := range *downloads {
		downloadWithLogoPaths = append(downloadWithLogoPaths, checkLogo(download))
	}
	buff, err := json.Marshal(downloadWithLogoPaths)
	if err != nil {
		return "", err
	}
	return string(buff), err
}

func DownloadEpList(comicId string) (string, error) {
	list, err := comic_center.ListDownloadEpByComicId(comicId)
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(&list)
	if err != nil {
		return "", err
	}
	return string(buff), err
}

func ViewLogPage(page int, pageSize int) (string, error) {
	viewLogPage, err := comic_center.ViewLogPage(int(page), int(pageSize))
	if err != nil {
		return "", err
	}
	buff, _ := json.Marshal(viewLogPage)
	return string(buff), nil
}

func DownloadPicturesByEpId(epId string) (string, error) {
	pictures, err := comic_center.ListDownloadPictureByEpId(epId)
	if err != nil {
		return "", err
	}
	var list = make([]ComicDownloadPictureWithFinalPath, 0)
	for _, picture := range pictures {
		var f ComicDownloadPictureWithFinalPath
		f.ComicDownloadPicture = picture
		if f.LocalPath != "" {
			f.FinalPath = downloadPath(f.LocalPath)
		}
		list = append(list, f)
	}
	buff, err := json.Marshal(list)
	if err != nil {
		return "", err
	}
	return string(buff), err
}

func DownloadRunning() bool {
	return downloadRunning
}

func SetDownloadRunning(status bool) {
	downloadRunning = status
}

func Clean() error {
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
