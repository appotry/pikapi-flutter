package controller

import "pgo/pikapi/database/comic_center"

type DisplayImageData struct {
	comic_center.RemoteImage
	BuffBase64 string `json:"buffBase64"`
}

type ComicDownloadWithLogoPath struct {
	comic_center.ComicDownload
	LogoPath string `json:"logoPath"`
}

type ComicDownloadPictureWithFinalPath struct {
	comic_center.ComicDownloadPicture
	FinalPath string `json:"finalPath"`
}


type JsonComicDownload struct {
	comic_center.ComicDownload
	EpList []JsonComicDownloadEp `json:"epList"`
}

type JsonComicDownloadEp struct {
	comic_center.ComicDownloadEp
	PictureList []JsonComicDownloadPicture `json:"pictureList"`
}

type JsonComicDownloadPicture struct {
	comic_center.ComicDownloadPicture
	SrcPath string `json:"srcPath"`
}


var ExportNameCallback func(string)

func notifyExport(str string) {
	call := ExportNameCallback
	if call != nil {
		call(str)
	}
}
