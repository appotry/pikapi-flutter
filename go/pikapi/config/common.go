package config

import (
	"path"
	"pgo/pikapi/controller"
	"pgo/pikapi/database/comic_center"
	"pgo/pikapi/database/network_cache"
	"pgo/pikapi/database/properties"
	"pgo/pikapi/utils"
)

func InitApplication(applicationDir string) {
	println("初始化 : " + applicationDir)
	var databasesDir, remoteDir, downloadDir string
	databasesDir = path.Join(applicationDir, "databases")
	remoteDir = path.Join(applicationDir, "pictures", "remote")
	downloadDir = path.Join(applicationDir, "download")
	utils.Mkdir(databasesDir)
	utils.Mkdir(remoteDir)
	utils.Mkdir(downloadDir)
	properties.InitDBConnect(databasesDir)
	network_cache.InitDBConnect(databasesDir)
	comic_center.InitDBConnect(databasesDir)
	controller.InitClient()
	controller.InitPlugin(remoteDir, downloadDir)
}
