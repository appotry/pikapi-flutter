package controller

import (
	"archive/zip"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path"
	"pgo/pikapi/database/comic_center"
	"time"
)

func exportComicDownload(params string) error {
	var paramsStruct struct {
		ComicId string `json:"comicId"`
		Dir     string `json:"dir"`
	}
	json.Unmarshal([]byte(params), &paramsStruct)
	comicId := paramsStruct.ComicId
	dir := paramsStruct.Dir

	println(fmt.Sprintf("导出 %s 到 %s", comicId, dir))
	comic, err := comic_center.FindComicDownloadById(comicId)
	if err != nil {
		return err
	}
	if comic == nil {
		return errors.New("not found")
	}
	if !comic.DownloadFinished {
		return errors.New("not download finish")
	}
	filePath := path.Join(dir, fmt.Sprintf("%s-%s.zip", comic.Title, time.Now().Format("2006_01_02_15_04_05.999")))
	println(fmt.Sprintf("ZIP : %s", filePath))
	fileStream, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer fileStream.Close()
	zipWriter := zip.NewWriter(fileStream)
	defer zipWriter.Close()
	epList, err := comic_center.ListDownloadEpByComicId(comicId)
	if err != nil {
		return err
	}
	jsonComic := JsonComicDownload{}
	jsonComic.ComicDownload = *comic
	jsonComic.EpList = make([]JsonComicDownloadEp, 0)
	for _, ep := range epList {
		jsonEp := JsonComicDownloadEp{}
		jsonEp.ComicDownloadEp = ep
		jsonEp.PictureList = make([]JsonComicDownloadPicture, 0)
		pictures, err := comic_center.ListDownloadPictureByEpId(ep.ID)
		if err != nil {
			return err
		}
		for _, picture := range pictures {
			jsonPicture := JsonComicDownloadPicture{}
			jsonPicture.ComicDownloadPicture = picture
			jsonPicture.SrcPath = fmt.Sprintf("pictures/%04d_%04d", ep.EpOrder, picture.RankInEp)
			notifyExport(fmt.Sprintf("正在导出 EP:%d PIC:%d", ep.EpOrder, picture.RankInEp))
			entryWriter, err := zipWriter.Create(jsonPicture.SrcPath)
			if err != nil {
				return err
			}
			source, err := os.Open(downloadPath(picture.LocalPath))
			if err != nil {
				return err
			}
			_, err = func() (int64, error) {
				defer source.Close()
				return io.Copy(entryWriter, source)
			}()
			if err != nil {
				return err
			}
			jsonEp.PictureList = append(jsonEp.PictureList, jsonPicture)
		}
		jsonComic.EpList = append(jsonComic.EpList, jsonEp)
	}
	if comic.ThumbLocalPath != "" {
		entryWriter, err := zipWriter.Create("logo")
		if err != nil {
			return err
		}
		source, err := os.Open(downloadPath(comic.ThumbLocalPath))
		_, err = func() (int64, error) {
			defer source.Close()
			return io.Copy(entryWriter, source)
		}()
		if err != nil {
			return err
		}
	}
	// JS
	{
		buff, err := json.Marshal(&jsonComic)
		if err != nil {
			return err
		}
		entryWriter, err := zipWriter.Create("data.js")
		if err != nil {
			return err
		}
		entryWriter.Write([]byte("data = "))
		entryWriter.Write(buff)
	}
	// HTML
	{
		entryWriter, err := zipWriter.Create("index.html")
		if err != nil {
			return err
		}
		entryWriter.Write([]byte(indexHtml))
	}
	println("OK")
	return nil
}

const indexHtml = `
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        * {
            margin: 0;
            padding: 0;
        }

        html {
            color: white;
        }

        html, body {
            height: 100%;
        }

        #leftNav {
            position: fixed;
            width: 350px;
            height: 100%;
        }

        #leftNav > * {
            display: inline-block;
            vertical-align: top;
        }

        #leftNav > ul {
            background: #333;
            height: 100%;
            overflow-y: auto;
            overflow-x: hidden;
            width: 300px;
        }

        #leftNav > #slider {
            margin-top: 1em;
            float: right;
            width: 40px;
            border: none;
            background: rgba(0, 0, 0, .4);
            color: white;
        }

        #title > img {
            display: block;
            width: 80px;
            margin: 30px auto;
        }

        #title > p {
            text-align: center;
        }

        #title {
            margin-bottom: 30px;
        }

        #leftNav > ul a {
            margin: auto;
            display: block;
            color: white;
            height: 40px;
            line-height: 40px;
            text-align: center;
            width: 280px;
            border-top: #666 solid 1px;
            text-decoration: none;
        }

        #leftNav > ul a:hover,#leftNav > ul a.active {
            background: rgba(255, 255, 255, .1);
        }

        #content {
            width: 100%;
            height: 100%;
            background: black;
        }

        #content img {
            width: 100%;
        }
    </style>
    <script src="data.js"></script>
    <script>
        function changeLeftNav() {
            var doc = document.getElementById("leftNav")
            if (doc.style.left) {
                doc.style.left = ""
            } else {
                doc.style.left = "-300px"
            }
        }

        function changeEp(epIndex) {
            var ps = data.epList[epIndex].pictureList;
            document.getElementById('content').innerHTML = "";
            var d = document.createElement('div');
            d.id = 'd';
            document.getElementById('content').append(d);
            for (var i = 0; i < ps.length; i++) {
                var img = document.createElement('img');
                img.src = ps[i].srcPath;
                document.getElementById('content').append(img);
            }
            document.getElementById('d').scrollIntoView();
            changeLeftNav();
            var as = document.getElementById('leftNav').getElementsByTagName('a');
            for (var i = 0; i < ps.length; i++) {
                if(epIndex == i){
                    as[i].classList = ["active"];
                }else{                    as[i].className = "";

                }
            }
        }
    </script>
</head>
<body>
<div id="leftNav">
    <ul>
        <li id="title">
            <script>
                document.write('<img src="logo" /> <br/>')
                document.write('<p>' + data.title + '</p>');
            </script>
        </li>
        <script>
            for (var i = 0; i < data.epList.length; i++) {
                document.write('<li><a href="javascript:changeEp(' + i + ')">' + data.epList[i].title + '</a></li>');
            }
        </script>
    </ul>
    <button id="slider" onclick="changeLeftNav();">切换</button>
</div>
<div id="content">
</div>
</body>
</html>
`
