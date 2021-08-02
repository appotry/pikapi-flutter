package controller

import (
	"bytes"
	"errors"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"io/ioutil"
	"net/http"
	"pgo/pikapi/database/comic_center"
	"sync"
)

func decodeInfoFromBuff(buff []byte) (image.Image, string, error) {
	buffer := bytes.NewBuffer(buff)
	return image.Decode(buffer)
}

func decodeInfoFromFile(path string) (image.Image, string, error) {
	buff, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, "", err
	}
	return decodeInfoFromBuff(buff)
}

var mutexCounter = -1
var busMutex *sync.Mutex
var subMutexes []*sync.Mutex

func init() {
	busMutex = &sync.Mutex{}
	for i := 0; i < 5; i++ {
		subMutexes = append(subMutexes, &sync.Mutex{})
	}
}

func takeMutex() *sync.Mutex {
	busMutex.Lock()
	defer busMutex.Unlock()
	mutexCounter = (mutexCounter + 1) % len(subMutexes)
	return subMutexes[mutexCounter]
}

func decodeFromUrl(fileServer string, path string) ([]byte, image.Image, string, error) {
	m := takeMutex()
	m.Lock()
	defer m.Unlock()
	request, err := http.NewRequest("GET", fileServer+"/static/"+path, nil)
	if err != nil {
		return nil, nil, "", err
	}
	response, err := client.Do(request)
	if err != nil {
		return nil, nil, "", err
	}
	defer response.Body.Close()
	if response.StatusCode != 200 {
		return nil, nil, "", errors.New("code is not 200")
	}
	buff, err := ioutil.ReadAll(response.Body)
	if err != nil {
		return nil, nil, "", err
	}
	img, format, err := decodeInfoFromBuff(buff)
	if err != nil {
		return nil, nil, "", err
	}
	return buff, img, format, err
}

// decodeFromCache 仅下载使用
func decodeFromCache(fileServer string, path string) ([]byte, image.Image, string, error) {
	cache := comic_center.FindRemoteImage(fileServer, path)
	if cache != nil {
		buff, err := ioutil.ReadFile(remotePath(cache.LocalPath))
		if err != nil {
			return nil, nil, "", err
		}
		img, format, err := decodeInfoFromBuff(buff)
		if err != nil {
			return nil, nil, "", err
		}
		return buff, img, format, err
	}
	return nil, nil, "", errors.New("not found")
}

