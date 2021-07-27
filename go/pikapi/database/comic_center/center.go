package comic_center

import (
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"path"
	"pgo/pikapi/const_value"
	"time"
)

var db *gorm.DB

func InitDBConnect(databaseDir string) {
	var err error
	db, err = gorm.Open(sqlite.Open(path.Join(databaseDir, "comic_center.db")), const_value.GormConfig)
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&Category{})
	db.AutoMigrate(&ComicView{})
	db.AutoMigrate(&RemoteImage{})
	db.AutoMigrate(&ComicDownload{})
	db.AutoMigrate(&ComicDownloadEp{})
	db.AutoMigrate(&ComicDownloadPicture{})
}

func Transaction(t func(tx *gorm.DB) error) error {
	return db.Transaction(t)
}

func UpSetCategories(categories *[]Category) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var in []string
		for _, c := range *categories {
			if c.ID == "" {
				continue
			}
			in = append(in, c.ID)
			err := tx.Clauses(clause.OnConflict{
				Columns: []clause.Column{{Name: "id"}},
				DoUpdates: clause.AssignmentColumns([]string{
					"updated_at",
					"title",
					"description",
					"is_web",
					"active",
					"link",
					"thumb_original_name",
					"thumb_file_server",
					"thumb_path",
				}),
			}).Create(&c).Error
			if err != nil {
				return err
			}
		}
		err := tx.Unscoped().Model(&Category{}).Where(" id in ?", in).Update("deleted_at", gorm.DeletedAt{
			Valid: false,
		}).Error
		if err != nil {
			return err
		}
		return tx.Unscoped().Model(&Category{}).Where(" id not in ?", in).Update("deleted_at", gorm.DeletedAt{
			Time:  time.Now(),
			Valid: true,
		}).Error
	})
}

func ViewComicUpdateInfoDB(view *ComicView, db *gorm.DB) error {
	view.LastViewTime = time.Now()
	return db.Clauses(clause.OnConflict{
		Columns: []clause.Column{{Name: "id"}},
		DoUpdates: clause.AssignmentColumns([]string{
			"created_at",
			"updated_at",
			"title",
			"author",
			"pages_count",
			"eps_count",
			"finished",
			"categories",
			"thumb_original_name",
			"thumb_file_server",
			"thumb_path",
			"likes_count",
			"description",
			"chinese_team",
			"tags",
			"allow_download",
			"views_count",
			"is_favourite",
			"is_liked",
			"comments_count",
			"last_view_time",
		}),
	}).Create(view).Error
}

func ViewComicUpdateInfo(view *ComicView) error {
	return ViewComicUpdateInfoDB(view, db)
}

func ViewComic(comicId string) error {
	return db.Model(&ComicView{}).Where(
		"id = ?", comicId,
	).Update(
		"last_view_time",
		time.Now(),
	).Error
}

func ViewComicUpdateFavourite(comicId string, favourite bool) error {
	return db.Model(&ComicView{}).Where(
		"id = ?", comicId,
	).Update(
		"is_favourite",
		favourite,
	).Error
}

func ViewComicUpdateLike(comicId string, like bool) error {
	return db.Model(&ComicView{}).Where(
		"id = ?", comicId,
	).Update(
		"is_like",
		like,
	).Error
}

func ViewEpAndPicture(comicId string, epOrder int, epTitle, pictureRank int) error {
	return db.Model(&ComicView{}).Where("id", comicId).Updates(
		map[string]interface{}{
			"last_view_time":         time.Now(),
			"last_ep_order":          epOrder,
			"last_view_ep_name":      epTitle,
			"last_view_picture_rank": pictureRank,
		},
	).Error
}

func FindRemoteImage(fileServer string, path string) *RemoteImage {
	var remoteImage RemoteImage
	err := db.First(&remoteImage, "file_server = ? AND path = ?", fileServer, path).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil
		} else {
			panic(err)
		}
	}
	return &remoteImage
}

func SaveRemoteImage(remote *RemoteImage) error {
	return db.Clauses(clause.OnConflict{
		Columns: []clause.Column{{Name: "file_server"}, {Name: "path"}},
		DoUpdates: clause.AssignmentColumns([]string{
			"updated_at",
			"file_size",
			"format",
			"width",
			"height",
			"local_path",
		}),
	}).Create(remote).Error
}

func CreateDownload(comic *ComicDownload, epList *[]ComicDownloadEp) error {
	comic.SelectedEpCount = int32(len(*epList))
	return db.Transaction(func(tx *gorm.DB) error {
		err := tx.Create(comic).Error
		if err != nil {
			return err
		}
		for _, ep := range *epList {
			err := tx.Create(&ep).Error
			if err != nil {
				return err
			}
		}
		return nil
	})
}

func AddDownload(comic *ComicDownload, epList *[]ComicDownloadEp) error {
	return db.Transaction(func(tx *gorm.DB) error {
		err := tx.Model(comic).Where("id = ?", comic.ID).Updates(map[string]interface{}{
			"created_at":          comic.CreatedAt,
			"updated_at":          comic.UpdatedAt,
			"title":               comic.Title,
			"author":              comic.Author,
			"pages_count":         comic.PagesCount,
			"eps_count":           comic.EpsCount,
			"finished":            comic.Finished,
			"categories":          comic.Categories,
			"thumb_original_name": comic.ThumbOriginalName,
			"thumb_file_server":   comic.ThumbFileServer,
			"thumb_path":          comic.ThumbPath,
			"description":         comic.Description,
			"chinese_team":        comic.ChineseTeam,
			"tags":                comic.Tags,
			"download_finished":   false, // restart
		}).Error
		if err != nil {
			return err
		}
		err = tx.Exec(
			"UPDATE comic_downloads SET eps_count = selected_ep_count + ? WHERE id = ?",
			len(*epList), comic.ID,
		).Error
		if err != nil {
			return err
		}
		for _, ep := range *epList {
			err := tx.Create(&ep).Error
			if err != nil {
				return err
			}
		}
		return nil
	})
}

func UpdateDownloadLogo(comicId string, fileSize int64, format string, width int32, height int32, localPath string) error {
	return db.Model(&ComicDownload{}).Where("id = ?", comicId).Updates(map[string]interface{}{
		"thumb_file_size":  fileSize,
		"thumb_format":     format,
		"thumb_width":      width,
		"thumb_height":     height,
		"thumb_local_path": localPath,
	}).Error
}

func FindComicDownloadById(comicId string) (*ComicDownload, error) {
	var download ComicDownload
	err := db.First(&download, "id = ?", comicId).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &download, nil
}

func ListDownloadEpByComicId(comicId string) ([]ComicDownloadEp, error) {
	var epList []ComicDownloadEp
	err := db.Where("comic_id = ?", comicId).Order("ep_order ASC").Find(&epList).Error
	return epList, err
}

func ListDownloadPictureByEpId(epId string) ([]ComicDownloadPicture, error) {
	var pictureList []ComicDownloadPicture
	err := db.Where("ep_id = ?", epId).Order("rank_in_ep ASC").Find(&pictureList).Error
	return pictureList, err
}

func AllDownloads() (*[]ComicDownload, error) {
	var downloads []ComicDownload
	err := db.Table("comic_downloads").
		Joins("LEFT JOIN comic_views ON comic_views.id = comic_downloads.id").
		Select("comic_downloads.*").
		Order("comic_views.last_view_time DESC").
		Scan(&downloads).Error
	// err := db.Find(&downloads).Error
	return &downloads, err
}

func LoadFirstNeedDownload() (*ComicDownload, error) {
	var download ComicDownload
	err := db.First(&download, "download_failed = 0 AND pause = 0 AND deleting = 0 AND download_finished = 0").Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &download, nil
}

func LoadFirstNeedDownloadEp(comicId string) (*ComicDownloadEp, error) {
	var ep ComicDownloadEp
	err := db.First(
		&ep,
		" comic_id = ? AND download_failed = 0 AND download_finished = 0 AND fetched_pictures = 1",
		comicId,
	).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &ep, nil
}

func LoadFirstNeedDownloadPicture(epId string) (*ComicDownloadPicture, error) {
	var picture ComicDownloadPicture
	err := db.First(
		&picture,
		"ep_id = ? AND download_failed = 0 AND download_finished = 0",
		epId,
	).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, err
	}
	return &picture, nil
}

func FetchPictures(comicId string, epId string, list *[]ComicDownloadPicture) error {
	return db.Transaction(func(tx *gorm.DB) error {
		var rankInEp int32
		for _, picture := range *list {
			rankInEp = rankInEp + 1
			picture.RankInEp = rankInEp
			err := tx.Create(&picture).Error
			if err != nil {
				return err
			}
		}
		err := tx.Model(&ComicDownloadEp{}).Where("id = ?", epId).Updates(map[string]interface{}{
			"fetched_pictures":       true,
			"selected_picture_count": len(*list),
		}).Error
		if err != nil {
			return err
		}
		return tx.Exec(
			"UPDATE comic_downloads SET selected_picture_count = selected_picture_count + ? WHERE id = ?",
			len(*list), comicId,
		).Error
	})
}

func DownloadFailed(comicId string) error {
	return db.Model(&ComicDownload{}).Where("id = ?", comicId).Update("download_failed", true).Error
}

func DownloadSuccess(comicId string) error {
	return db.Model(&ComicDownload{}).Where("id = ?", comicId).Updates(map[string]interface{}{
		"download_finished":      true,
		"download_finished_time": time.Now(),
	}).Error
}

func EpFailed(epId string) error {
	return db.Model(&ComicDownloadEp{}).Where("id = ?", epId).Update("download_failed", true).Error
}

func EpSuccess(comicId string, epId string) error {
	return db.Transaction(func(tx *gorm.DB) error {
		err := tx.Model(&ComicDownloadEp{}).Where("id = ?", epId).Updates(map[string]interface{}{
			"download_finished":      true,
			"download_finished_time": time.Now(),
		}).Error
		if err != nil {
			return err
		}
		return tx.Exec(
			"UPDATE comic_downloads SET download_ep_count = download_ep_count + 1 WHERE id = ?",
			comicId,
		).Error
	})
}

func PictureFailed(pictureId string) error {
	return db.Model(&ComicDownloadPicture{}).Where("id = ?", pictureId).Update("download_failed", true).Error
}

func PictureSuccess(
	comicId string, epId string, pictureId string,
	fileSize int64, format string, width int32, height int32, localPath string,
) error {
	return db.Transaction(func(tx *gorm.DB) error {
		err := tx.Model(&ComicDownloadPicture{}).Where("id = ?", pictureId).Updates(map[string]interface{}{
			"file_size":              fileSize,
			"format":                 format,
			"width":                  width,
			"height":                 height,
			"local_path":             localPath,
			"download_finished":      true,
			"download_finished_time": time.Now(),
		}).Error
		if err != nil {
			return err
		}
		err = tx.Exec(
			"UPDATE comic_download_eps SET download_picture_count = download_picture_count + 1 WHERE id = ?",
			epId,
		).Error
		if err != nil {
			return err
		}
		return tx.Exec(
			"UPDATE comic_downloads SET download_picture_count = download_picture_count + 1 WHERE id = ?",
			comicId,
		).Error
	})
}

func ResetAll() error {
	return db.Transaction(func(tx *gorm.DB) error {
		err := tx.Model(&ComicDownload{}).Where("1 = 1").
			Update("download_failed", false).Error
		if err != nil {
			return err
		}
		err = tx.Model(&ComicDownloadEp{}).Where("1 = 1").
			Update("download_failed", false).Error
		if err != nil {
			return err
		}
		err = tx.Model(&ComicDownloadPicture{}).Where("1 = 1").
			Update("download_failed", false).Error
		return err
	})
}

func ViewLogPage(page int, pageSize int) (*[]ComicView, error) {
	var list []ComicView
	err := db.Offset((page - 1) * pageSize).Limit(pageSize).Order("last_view_time DESC").Find(&list).Error
	return &list, err
}
