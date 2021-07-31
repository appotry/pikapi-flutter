package mobile

import (
	"encoding/json"
	"pgo/pikapi/config"
	"pgo/pikapi/controller"
	"pgo/pikapi/database/comic_center"
)

func InitApplication(application string) {
	config.InitApplication(application)
}

func SaveProperty(name string, value string) {
	controller.SaveProperty(name, value)
}

func LoadProperty(name string, defaultValue string) string {
	return controller.LoadProperty(name, defaultValue)
}

func SetSwitchAddress(value string) {
	controller.SetSwitchAddress(value)
}

func GetSwitchAddress() string {
	return controller.GetSwitchAddress()
}

func SetProxy(value string) {
	controller.SetProxy(value)
}

func GetProxy() string {
	return controller.GetProxy()
}

func SetUsername(value string) {
	controller.SetUsername(value)
}

func GetUsername() string {
	return controller.GetUsername()
}

func SetPassword(value string) {
	controller.SetPassword(value)
}

func GetPassword() string {
	return controller.GetPassword()
}

func PreLogin() (bool, error) {
	return controller.PreLogin()
}

func Login() error {
	return controller.Login()
}

func RemoteImageData(fileServer string, path string) (string, error) {
	return controller.RemoteImageData(fileServer, path)
}

func Categories() (string, error) {
	return controller.Categories()
}

func Comics(category string, sort string, page int) (string, error) {
	return controller.Comics(category, sort, page)
}

func SearchComics(keyword string, sort string, page int) (string, error) {
	return controller.SearchComics(nil, keyword, sort, page)
}

func SearchComicsInCategories(keyword string, sort string, page int, categories string) (string, error) {
	var categoriesArray []string
	json.Unmarshal([]byte(categories), &categoriesArray)
	return controller.SearchComics(categoriesArray, keyword, sort, page)
}

func ComicInfo(comicId string) (string, error) {
	return controller.ComicInfo_(comicId)
}

func EpPage(comicId string, page int) (string, error) {
	return controller.EpPage(comicId, page)
}

func ComicPicturePageWithQuality(comicId string, epOrder int, page int, quality string) (string, error) {
	return controller.ComicPicturePageWithQuality(comicId, epOrder, page, quality)
}

func DeleteDownloadComic(comicId string) error {
	return controller.DeleteDownloadComic(comicId)
}

func LoadDownloadComic(comicId string) (string, error) {
	return controller.LoadDownloadComic(comicId)
}

func DownloadComicThumb(comicId string) (string, error) {
	return controller.DownloadComicThumb(comicId)
}

func CreateDownload(comic string, epList string) error {
	return controller.CreateDownload(comic, epList)
}

func AddDownload(comic string, epList string) error {
	return controller.AddDownload(comic, epList)
}

func AllDownloads() (string, error) {
	return controller.AllDownloads()
}

func DownloadEpList(comicId string) (string, error) {
	return controller.DownloadEpList(comicId)
}

func DownloadPicturesByEpId(epId string) (string, error) {
	return controller.DownloadPicturesByEpId(epId)
}

func ResetAllDownloads() error {
	return comic_center.ResetAll()
}

func DownloadRunning() bool {
	return controller.DownloadRunning()
}

func SetDownloadRunning(status bool) {
	controller.SetDownloadRunning(status)
}

func ViewLogPage(page int, pageSize int) (string, error) {
	return controller.ViewLogPage(page, pageSize)
}

func ExportComicDownload(comicId string, dir string) error {
	return controller.ExportComicDownload(comicId, dir)
}

func ImportComicDownload(zipPath string) error {
	return controller.ImportZip(zipPath)
}

func SwitchLike(comicId string) (string, error) {
	return controller.SwitchLike(comicId)
}

func SwitchFavourite(comicId string) (string, error) {
	return controller.SwitchFavourite(comicId)
}

func FavouriteComics(sort string, page int) (string, error) {
	return controller.FavouriteComics(sort, page)
}

func Clean() error {
	return controller.Clean()
}

func Recommendation(comicId string) (string, error) {
	return controller.Recommendation(comicId)
}

func Comments(comicId string, page int) (string, error) {
	return controller.Comments(comicId, page)
}

func ExportingNotify(notify StringNotify) {
	controller.ExportNameCallback = func(str string) {
		notify.OnNotify(str)
	}
}

func DownloadingComicNotify(notify StringNotify) {
	controller.ComicDownloadEvent = func(str string) {
		notify.OnNotify(str)
	}
}

type StringNotify interface {
	OnNotify(string)
}
