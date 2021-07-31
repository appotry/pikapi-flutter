package controller

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"net/url"
	"pgo/pikapi/database/comic_center"
	"pgo/pikapi/database/network_cache"
	"pgo/pikapi/database/properties"
	"pica"
	"regexp"
	"strings"
	"time"
)

func InitClient() {
	client.Timeout = time.Second * 60
	switchAddress = properties.LoadSwitchAddress()
	changeProxyUrl(properties.LoadProxy())
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
func cacheable(key string, expire time.Duration, reload func() (interface{}, error)) (string, error) {
	// CACHE
	cache := network_cache.LoadCache(key, expire)
	if cache != "" {
		return cache, nil
	}
	// obj
	obj, err := reload()
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(obj)
	// push to cache
	if err != nil {
		return "", err
	}
	// return
	cache = string(buff)
	network_cache.SaveCache(key, cache)
	return cache, nil
}

func Categories() (string, error) {
	key := "CATEGORIES"
	expire := time.Hour * 24 * 5
	cache := network_cache.LoadCache(key, expire)
	if cache != "" {
		return cache, nil
	}
	categories, err := client.Categories()
	if err != nil {
		return "", err
	}
	var dbCategories []comic_center.Category
	for _, c := range categories {
		dbCategories = append(dbCategories, comic_center.Category{
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
	err = comic_center.UpSetCategories(&dbCategories)
	if err != nil {
		return "", err
	}
	buff, _ := json.Marshal(&categories)
	cache = string(buff)
	network_cache.SaveCache(key, cache)
	return cache, nil
}

func Comics(category string, sort string, page int) (string, error) {
	return cacheable(
		fmt.Sprintf("COMICS$%s$%s$%d", category, sort, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.Comics(category, sort, page)
		},
	)
}

func SearchComics(categories []string, keyword string, sort string, page int) (string, error) {
	var categoriesInKey string
	if len(categories) == 0 {
		categoriesInKey = ""
	} else {
		b, _ := json.Marshal(categories)
		categoriesInKey = string(b)
	}
	return cacheable(
		fmt.Sprintf("SEARCH$%s$%s$%s$%d", categoriesInKey, keyword, sort, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.SearchComics(categories, keyword, sort, page)
		},
	)
}

func ComicInfo_(comicId string) (string, error) {
	// cache
	key := fmt.Sprintf("COMIC_INFO$%s", comicId)
	expire := time.Hour * 24 * 7
	cache := network_cache.LoadCache(key, expire)
	if cache != "" {
		err := comic_center.ViewComic(comicId)
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
	view := comic_center.ComicView{}
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
	err = comic_center.ViewComicUpdateInfo(&view)
	if err != nil {
		return "", err
	}
	// return
	buff, _ := json.Marshal(comic)
	cache = string(buff)
	network_cache.SaveCache(key, cache)
	return cache, nil
}

func ComicInfoCleanCache(comicId string) {
	key := fmt.Sprintf("COMIC_INFO$%s", comicId)
	network_cache.RemoveCache(key)
}

func EpPage(comicId string, page int) (string, error) {
	return cacheable(
		fmt.Sprintf("COMIC_EP_PAGE$%s$%d", comicId, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.ComicEpPage(comicId, page)
		},
	)
}

func ComicPicturePageWithQuality(comicId string, epOrder int, page int, quality string) (string, error) {
	return cacheable(
		fmt.Sprintf("COMIC_EP_PAGE$%s$%ds$%ds$%s", comicId, epOrder, page, quality),
		time.Hour*2,
		func() (interface{}, error) {
			return client.ComicPicturePageWithQuality(comicId, epOrder, page, quality)
		},
	)
}

func SwitchLike(comicId string) (string, error) {
	point, err := client.SwitchLike(comicId)
	if err != nil {
		return "", err
	}
	// 更新viewLog里面的favour
	comic_center.ViewComicUpdateLike(comicId, strings.HasPrefix(*point, "un"))
	// 删除缓存
	ComicInfoCleanCache(comicId)
	return *point, nil
}

func SwitchFavourite(comicId string) (string, error) {
	point, err := client.SwitchFavourite(comicId)
	if err != nil {
		return "", err
	}
	// 更新viewLog里面的favour
	comic_center.ViewComicUpdateFavourite(comicId, strings.HasPrefix(*point, "un"))
	// 删除缓存
	ComicInfoCleanCache(comicId)
	return *point, nil
}

func FavouriteComics(sort string, page int) (string, error) {
	point, err := client.FavouriteComics(sort, page)
	if err != nil {
		return "", err
	}
	str, err := json.Marshal(point)
	if err != nil {
		return "", err
	}
	return string(str), nil
}

func Recommendation(comicId string) (string, error) {
	return cacheable(
		fmt.Sprintf("RECOMMENDATION$%s", comicId),
		time.Hour*2,
		func() (interface{}, error) {
			return client.ComicRecommendation(comicId)
		},
	)
}

func Comments(comicId string, page int) (string, error) {
	return cacheable(
		fmt.Sprintf("COMMENTS$%s$%d", comicId, page),
		time.Hour*2,
		func() (interface{}, error) {
			return client.ComicCommentsPage(comicId, page)
		},
	)
}
