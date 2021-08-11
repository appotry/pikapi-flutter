package controller

import (
	"encoding/json"
	"pgo/pikapi/database/comic_center"
)

var EventNotify func(function string, value string)

func downloadComicEventSend(comicDownload *comic_center.ComicDownload) {
	event := EventNotify
	if event != nil {
		buff, err := json.Marshal(comicDownload)
		if err == nil {
			event("DOWNLOAD", string(buff))
		} else {
			print("SEND ERR?")
		}
	}
}

func notifyExport(str string) {
	call := EventNotify
	if call != nil {
		call("EXPORT", str)
	}
}

func serialize(point interface{}, err error) (string, error) {
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(point)
	return string(buff), nil
}
