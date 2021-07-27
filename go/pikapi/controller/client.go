package controller

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"net/url"
	comic_center2 "pgo/pikapi/database/comic_center"
	network_cache2 "pgo/pikapi/database/network_cache"
	properties2 "pgo/pikapi/database/properties"
	"pica"
	"regexp"
	"time"
)

func InitClient() {
	client.Timeout = time.Second * 60
	switchAddress = properties2.LoadSwitchAddress()
	changeProxyUrl(properties2.LoadProxy())
}

var client = pica.Client{}
var dialer = &net.Dialer{
	Timeout:   30 * time.Second,
	KeepAlive: 30 * time.Second,
}

// SwitchAddress
// addr = "172.67.7.24:443"
// addr = "104.20.180.50:443"
// addr = "172.67.208.169:443"
var switchAddress = ""
var switchAddressPattern, _ = regexp.Compile("^.+picacomic\\.com:\\d+$")

func switchAddressContext(ctx context.Context, network, addr string) (net.Conn, error) {
	if switchAddressPattern.MatchString(addr) && switchAddress != "" {
		addr = switchAddress
	}
	return dialer.DialContext(ctx, network, addr)
}

func changeProxyUrl(urlStr string) bool {
	if urlStr == "" {
		client.Transport = &http.Transport{
			TLSHandshakeTimeout:   time.Second * 10,
			ExpectContinueTimeout: time.Second * 10,
			ResponseHeaderTimeout: time.Second * 10,
			IdleConnTimeout:       time.Second * 10,
			DialContext:           switchAddressContext,
		}
		return false
	}
	client.Transport = &http.Transport{
		Proxy: func(_ *http.Request) (*url.URL, error) {
			return url.Parse(urlStr)
		},
		TLSHandshakeTimeout:   time.Second * 10,
		ExpectContinueTimeout: time.Second * 10,
		ResponseHeaderTimeout: time.Second * 10,
		IdleConnTimeout:       time.Second * 10,
		DialContext:           switchAddressContext,
	}
	return true
}

func Categories() (string, error) {
	key := "CATEGORIES"
	expire := time.Hour * 24 * 5
	cache := network_cache2.LoadCache(key, expire)
	if cache != "" {
		return cache, nil
	}
	categories, err := client.Categories()
	if err != nil {
		return "", err
	}
	var dbCategories []comic_center2.Category
	for _, c := range categories {
		dbCategories = append(dbCategories, comic_center2.Category{
			ID:                c.Id,
			Title:             c.Title,
			Description:       c.Description,
			IsWeb:             c.IsWeb,
			Active:            c.Active,
			Link:              c.Link,
			ThumbOriginalName: c.Thumb.OriginalName,
			ThumbFileServer:   c.Thumb.FileServer,
			ThumbPath:         c.Thumb.Path,
		})
	}
	err = comic_center2.UpSetCategories(&dbCategories)
	if err != nil {
		return "", err
	}
	buff, _ := json.Marshal(&categories)
	cache = string(buff)
	network_cache2.SaveCache(key, cache)
	return cache, nil
}

func Comics(category string, sort string, page int) (string, error) {
	key := fmt.Sprintf("%s$%s$%d", category, sort, page)
	expire := time.Hour * 2
	cache := network_cache2.LoadCache(key, expire)
	if cache != "" {
		return cache, nil
	}
	comicPage, err := client.CategoryComics(category, sort, page)
	if err != nil {
		return "", err
	}
	buff, _ := json.Marshal(&comicPage)
	cache = string(buff)
	network_cache2.SaveCache(key, cache)
	return cache, nil
}

func SearchComics(keyword string, sort string, page int) (string, error) {
	comicPage, err := client.SearchComics(keyword, sort, int(page))
	if err != nil {
		return "", err
	}
	buff, _ := json.Marshal(&comicPage)
	return string(buff), nil
}

func SearchComicsInCategories(keyword string, sort string, page int, categories []string) (string, error) {
	comicPage, err := client.SearchComicsInCategories(keyword, sort, page, categories)
	if err != nil {
		return "", err
	}
	buff, _ := json.Marshal(&comicPage)
	return string(buff), nil
}

func ComicInfo_(comicId string) (string, error) {
	// cache
	key := fmt.Sprintf("COMIC_INFO$%s", comicId)
	expire := time.Hour * 24 * 7
	cache := network_cache2.LoadCache(key, expire)
	if cache != "" {
		err := comic_center2.ViewComic(comicId)
		if err != nil {
			return "", err
		}
		return cache, nil
	}
	// get
	comic, err := client.ComicInfo(comicId)
	if err != nil {
		return "", err
	}
	// 标记历史记录
	view := comic_center2.ComicView{}
	view.ID = comicId
	view.CreatedAt = comic.CreatedAt
	view.UpdatedAt = comic.UpdatedAt
	view.Title = comic.Title
	view.Author = comic.Author
	view.PagesCount = int32(comic.PagesCount)
	view.EpsCount = int32(comic.EpsCount)
	view.Finished = comic.Finished
	c, _ := json.Marshal(comic.Categories)
	view.Categories = string(c)
	view.ThumbOriginalName = comic.Thumb.OriginalName
	view.ThumbFileServer = comic.Thumb.FileServer
	view.ThumbPath = comic.Thumb.Path
	view.LikesCount = int32(comic.LikesCount)
	view.Description = comic.Description
	view.ChineseTeam = comic.ChineseTeam
	t, _ := json.Marshal(comic.Tags)
	view.Tags = string(t)
	view.AllowDownload = comic.AllowDownload
	view.ViewsCount = int32(comic.ViewsCount)
	view.IsFavourite = comic.IsFavourite
	view.IsLiked = comic.IsLiked
	view.CommentsCount = int32(comic.CommentsCount)
	err = comic_center2.ViewComicUpdateInfo(&view)
	if err != nil {
		return "", err
	}
	// return
	buff, _ := json.Marshal(&comic)
	cache = string(buff)
	network_cache2.SaveCache(key, cache)
	return cache, nil
}

func EpPage(comicId string, page int) (string, error) {
	// cache
	key := fmt.Sprintf("COMIC_EP_PAGE$%s$%d", comicId, page)
	expire := time.Hour * 2
	cache := network_cache2.LoadCache(key, expire)
	if cache != "" {
		err := comic_center2.ViewComic(comicId)
		if err != nil {
			return "", err
		}
		return cache, nil
	}
	// page
	epPage, err := client.ComicEpPage(comicId, page)
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(&epPage)
	if err != nil {
		return "", err
	}
	// return
	cache = string(buff)
	network_cache2.SaveCache(key, cache)
	return cache, nil
}

func ComicPicturePageWithQuality(comicId string, epOrder int, page int, quality string) (string, error) {
	// cache
	key := fmt.Sprintf("COMIC_EP_PAGE$%s$%ds$%ds$%s", comicId, epOrder, page, quality)
	expire := time.Hour * 24 * 10
	cache := network_cache2.LoadCache(key, expire)
	if cache != "" {
		err := comic_center2.ViewComic(comicId)
		if err != nil {
			return "", err
		}
		return cache, nil
	}
	// page
	ePage, err := client.ComicPicturePageWithQuality(comicId, epOrder, page, quality)
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(&ePage)
	if err != nil {
		return "", err
	}
	// return
	cache = string(buff)
	network_cache2.SaveCache(key, cache)
	return cache, nil
}
