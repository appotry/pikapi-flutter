package pica

import (
	"errors"
	"github.com/go-flutter-desktop/go-flutter/plugin"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"pgo/pikapi/controller"
	"pgo/pikapi/database/comic_center"
)

func handleLoadProperty(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if name, ok := argumentsMap["name"].(string); ok {
			if defaultValue := argumentsMap["defaultValue"].(string); ok {
				return controller.LoadProperty(name, defaultValue), nil
			}
		}
	}
	return nil, errors.New("params error")
}

func handleSaveProperty(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if name, ok := argumentsMap["name"].(string); ok {
			if value, ok := argumentsMap["value"].(string); ok {
				controller.SaveProperty(name, value)
			}
		}
		return nil, nil
	}
	return nil, errors.New("params error")
}

func handleGetSwitchAddress(arguments interface{}) (interface{}, error) {
	return controller.GetSwitchAddress(), nil
}

func handleSetSwitchAddress(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if nSwitchAddress, ok := argumentsMap["switchAddress"].(string); ok {
			controller.SetSwitchAddress(nSwitchAddress)
		}
		return nil, nil
	}
	return nil, errors.New("params error")
}

func handleSetProxy(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if proxy, ok := argumentsMap["proxy"].(string); ok {
			controller.SetProxy(proxy)
			return nil, nil
		}
	}
	return nil, errors.New("params error")
}

func handleGetProxy(arguments interface{}) (interface{}, error) {
	return controller.GetProxy(), nil
}

func handleSetUsername(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if username, ok := argumentsMap["username"].(string); ok {
			controller.SetUsername(username)
			return nil, nil
		}
	}
	return nil, errors.New("params error")
}

func handleGetUsername(arguments interface{}) (interface{}, error) {
	return controller.GetUsername(), nil
}

func handleGetPassword(arguments interface{}) (interface{}, error) {
	return controller.GetPassword(), nil
}

func handleSetPassword(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if password, ok := argumentsMap["password"].(string); ok {
			controller.SetPassword(password)
			return nil, nil
		}
	}
	return nil, errors.New("params error")
}

func handlePreLogin(arguments interface{}) (interface{}, error) {
	return controller.PreLogin()
}

func handleLogin(arguments interface{}) (interface{}, error) {
	return nil, controller.Login()
}

func handleRemoteImageData(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if fileServer, ok := argumentsMap["fileServer"].(string); ok {
			if path, ok := argumentsMap["path"].(string); ok {
				return controller.RemoteImageData(fileServer, path)
			}
		}
	}
	return nil, errors.New("params error")
}

func handleCategories(arguments interface{}) (interface{}, error) {
	return controller.Categories()
}

func handleComics(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if category, ok := argumentsMap["category"].(string); ok {
			if sort, ok := argumentsMap["sort"].(string); ok {
				if page, ok := argumentsMap["page"].(int32); ok {
					return controller.Comics(category, sort, int(page))
				}
			}
		}
	}
	return nil, errors.New("params error")
}

func handleSearch(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if keyword, ok := argumentsMap["keyword"].(string); ok {
			if sort, ok := argumentsMap["sort"].(string); ok {
				if page, ok := argumentsMap["page"].(int32); ok {
					return controller.SearchComics(nil, keyword, sort, int(page))
				}
			}
		}
	}
	return nil, errors.New("params error")
}

func handleSearchComicsInCategories(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if keyword, ok := argumentsMap["keyword"].(string); ok {
			if sort, ok := argumentsMap["sort"].(string); ok {
				if page, ok := argumentsMap["page"].(int32); ok {
					if categoriesInterface, ok := argumentsMap["categories"].([]interface{}); ok {
						categories := make([]string, 0)
						for _, i := range categoriesInterface {
							if category, ok := i.(string); ok {
								categories = append(categories, category)
							} else {
								goto e
							}
						}
						return controller.SearchComics(categories, keyword, sort, int(page))
					}
				}
			}
		}
	}
e:
	return nil, errors.New("params error")
}

func handleComicInfo(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			return controller.ComicInfo_(comicId)
		}
	}
	return nil, errors.New("params error")
}

func handleComicEpPage(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			if page, ok := argumentsMap["page"].(int32); ok {
				return controller.EpPage(comicId, int(page))
			}
		}
	}
	return nil, errors.New("params error")
}

func handleComicPicturePageWithQuality(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			if epOrder, ok := argumentsMap["epOrder"].(int32); ok {
				if page, ok := argumentsMap["page"].(int32); ok {
					if quality, ok := argumentsMap["quality"].(string); ok {
						return controller.ComicPicturePageWithQuality(comicId, int(epOrder), int(page), quality)
					}
				}
			}
		}
	}
	return nil, errors.New("params error")
}

func handleCreateDownload(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicStr, ok := argumentsMap["comic"].(string); ok {
			if epListStr, ok := argumentsMap["epList"].(string); ok {
				return nil, controller.CreateDownload(comicStr, epListStr)
			}
		}
	}
	return nil, errors.New("params error")
}

func handleAddDownload(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicStr, ok := argumentsMap["comic"].(string); ok {
			if epListStr, ok := argumentsMap["epList"].(string); ok {
				return nil, controller.AddDownload(comicStr, epListStr)
			}
		}
	}
	return nil, errors.New("params error")
}

func handleDownloadComic(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			return controller.LoadDownloadComic(comicId)
		}
	}
	return nil, errors.New("params error")
}

func handleDeleteDownloadComic(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			return nil, controller.DeleteDownloadComic(comicId)
		}
	}
	return nil, errors.New("params error")
}

func handleDownloadComicThumb(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			return controller.DownloadComicThumb(comicId)
		}
	}
	return nil, errors.New("params error")
}

func handleAllDownloads(arguments interface{}) (interface{}, error) {
	return controller.AllDownloads()
}

func handleDownloadEpList(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			return controller.DownloadEpList(comicId)
		}
	}
	return nil, errors.New("params error")
}

func handleDownloadPicturesByEpId(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if epId, ok := argumentsMap["epId"].(string); ok {
			return controller.DownloadPicturesByEpId(epId)
		}
	}
	return nil, errors.New("params error")
}

func handleViewLogPage(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if page, ok := argumentsMap["page"].(int32); ok {
			if pageSize, ok := argumentsMap["pageSize"].(int32); ok {
				return controller.ViewLogPage(int(page), int(pageSize))
			}
		}
	}
	return nil, errors.New("params error")
}

func handleExportDownload(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			if dir, ok := argumentsMap["dir"].(string); ok {
				return nil, controller.ExportComicDownload(comicId, dir)
			}
		}
	}
	return nil, errors.New("params error")
}

func handleImportDownload(arguments interface{}) (interface{}, error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if zipPath, ok := argumentsMap["zipPath"].(string); ok {
			return nil, controller.ImportZip(zipPath)
		}
	}
	return nil, errors.New("params error")
}

func handleResetAllDownloads(arguments interface{}) (interface{}, error) {
	return nil, comic_center.ResetAll()
}

func handleSwitchLike(arguments interface{}) (reply interface{}, err error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			return controller.SwitchLike(comicId)
		}
	}
	return nil, errors.New("params error")
}

func handleSwitchFavourite(arguments interface{}) (reply interface{}, err error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			return controller.SwitchFavourite(comicId)
		}
	}
	return nil, errors.New("params error")
}

func handleFavouriteComics(arguments interface{}) (reply interface{}, err error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if sort, ok := argumentsMap["sort"].(string); ok {
			if page, ok := argumentsMap["page"].(int32); ok {
				return controller.FavouriteComics(sort, int(page))
			}
		}
	}
	return nil, errors.New("params error")
}

func handleDownloadRunning(arguments interface{}) (reply interface{}, err error) {
	return controller.DownloadRunning(), nil
}

func handleSetDownloadRunning(arguments interface{}) (reply interface{}, err error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if status, ok := argumentsMap["status"].(bool); ok {
			controller.SetDownloadRunning(status)
			return nil, nil
		}
	}
	return nil, errors.New("params error")
}

func handleClean(arguments interface{}) (reply interface{}, err error) {
	return nil, controller.Clean()
}

func handleRecommendation(arguments interface{}) (reply interface{}, err error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			return controller.Recommendation(comicId)
		}
	}
	return nil, errors.New("params error")
}

func handleComments(arguments interface{}) (reply interface{}, err error) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if comicId, ok := argumentsMap["comicId"].(string); ok {
			if page, ok := argumentsMap["page"].(int32); ok {
				return controller.Comments(comicId, int(page))
			}
		}
	}
	return nil, errors.New("params error")
}

type ExportingStreamHandler struct {
}

func (s *ExportingStreamHandler) OnListen(arguments interface{}, sink *plugin.EventSink) {
	controller.ExportNameCallback = func(str string) {
		sink.Success(str)
	}
}

func (s *ExportingStreamHandler) OnCancel(arguments interface{}) {
	controller.ExportNameCallback = nil
}

var downloadComicEventSinkMap = map[interface{}]*plugin.EventSink{}

type DownloadingComicStreamHandler struct {
}

func (d *DownloadingComicStreamHandler) OnListen(arguments interface{}, sink *plugin.EventSink) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if SCREEN, ok := argumentsMap["SCREEN"].(string); ok {
			println("OnListen SCREEN : " + SCREEN)
			downloadComicEventSinkMap[SCREEN] = sink
		}
	}
}

func (d *DownloadingComicStreamHandler) OnCancel(arguments interface{}) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if SCREEN, ok := argumentsMap["SCREEN"].(string); ok {
			println("OnCancel SCREEN : " + SCREEN)
			delete(downloadComicEventSinkMap, SCREEN)
		}
	}
}

const channelName = "pica"

type Plugin struct {
}

func (p *Plugin) InitPlugin(messenger plugin.BinaryMessenger) error {

	channel := plugin.NewMethodChannel(messenger, channelName, plugin.StandardMethodCodec{})

	channel.HandleFunc("loadProperty", handleLoadProperty)
	channel.HandleFunc("saveProperty", handleSaveProperty)

	channel.HandleFunc("setSwitchAddress", handleSetSwitchAddress)
	channel.HandleFunc("getSwitchAddress", handleGetSwitchAddress)
	channel.HandleFunc("setProxy", handleSetProxy)
	channel.HandleFunc("getProxy", handleGetProxy)

	channel.HandleFunc("setUsername", handleSetUsername)
	channel.HandleFunc("getUsername", handleGetUsername)
	channel.HandleFunc("setPassword", handleSetPassword)
	channel.HandleFunc("getPassword", handleGetPassword)

	channel.HandleFunc("preLogin", handlePreLogin)
	channel.HandleFunc("login", handleLogin)

	channel.HandleFunc("remoteImageData", handleRemoteImageData)
	channel.HandleFunc("downloadComicThumb", handleDownloadComicThumb)

	channel.HandleFunc("categories", handleCategories)
	channel.HandleFunc("comics", handleComics)
	channel.HandleFunc("searchComics", handleSearch)
	channel.HandleFunc("searchComicsInCategories", handleSearchComicsInCategories)
	channel.HandleFunc("comicInfo", handleComicInfo)
	channel.HandleFunc("comicEpPage", handleComicEpPage)
	channel.HandleFunc("comicPicturePageWithQuality", handleComicPicturePageWithQuality)

	channel.HandleFunc("downloadRunning", handleDownloadRunning)
	channel.HandleFunc("setDownloadRunning", handleSetDownloadRunning)

	channel.HandleFunc("createDownload", handleCreateDownload)
	channel.HandleFunc("addDownload", handleAddDownload)
	channel.HandleFunc("downloadComic", handleDownloadComic)
	channel.HandleFunc("deleteDownloadComic", handleDeleteDownloadComic)
	channel.HandleFunc("allDownloads", handleAllDownloads)

	channel.HandleFunc("downloadEpList", handleDownloadEpList)
	channel.HandleFunc("downloadPicturesByEpId", handleDownloadPicturesByEpId)
	channel.HandleFunc("resetAllDownloads", handleResetAllDownloads)

	channel.HandleFunc("viewLogPage", handleViewLogPage)
	channel.HandleFunc("exportComicDownload", handleExportDownload)
	channel.HandleFunc("importComicDownload", handleImportDownload)

	channel.HandleFunc("switchLike", handleSwitchLike)
	channel.HandleFunc("switchFavourite", handleSwitchFavourite)
	channel.HandleFunc("favouriteComics", handleFavouriteComics)

	channel.HandleFunc("clean", handleClean)
	channel.HandleFunc("recommendation", handleRecommendation)
	channel.HandleFunc("comments", handleComments)

	exporting := plugin.NewEventChannel(messenger, "exporting", plugin.StandardMethodCodec{})
	exporting.Handle(&ExportingStreamHandler{})

	downloadComic := plugin.NewEventChannel(messenger, "downloadingComic", plugin.StandardMethodCodec{})
	downloadComic.Handle(&DownloadingComicStreamHandler{})
	controller.ComicDownloadEvent = func(str string) {
		for _, sink := range downloadComicEventSinkMap {
			if sink != nil {
				sink.Success(str)
			}
		}
	}

	return nil // no error

}
