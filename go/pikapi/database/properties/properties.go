package properties

import (
	"errors"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
	"path"
	"pgo/pikapi/const_value"
	"strconv"
)

var db *gorm.DB

func InitDBConnect(databaseDir string) {
	var err error
	db, err = gorm.Open(sqlite.Open(path.Join(databaseDir, "properties.db")), const_value.GormConfig)
	if err != nil {
		panic("failed to connect database")
	}
	db.AutoMigrate(&Property{})
}

type Property struct {
	gorm.Model
	K string `gorm:"index:uk_k,unique"`
	V string
}

func LoadProperty(name string, defaultValue string) string {
	var property Property
	err := db.First(&property, "k", name).Error
	if err == nil {
		return property.V
	}
	if gorm.ErrRecordNotFound == err {
		return defaultValue
	}
	panic(errors.New("?"))
}

func SaveProperty(name string, value string) {
	db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "k"}},
		DoUpdates: clause.AssignmentColumns([]string{"created_at", "updated_at", "v"}),
	}).Create(&Property{
		K: name,
		V: value,
	})
}

func SaveSwitchAddress(value string) {
	SaveProperty("switch_address", value)
}

func LoadSwitchAddress() string {
	return LoadProperty("switch_address", "")
}

func SaveProxy(value string) {
	SaveProperty("proxy", value)
}

func LoadProxy() string {
	return LoadProperty("proxy", "")
}

func SaveUsername(value string) {
	SaveProperty("username", value)
}

func LoadUsername() string {
	return LoadProperty("username", "")
}

func SavePassword(value string) {
	SaveProperty("password", value)
}

func LoadPassword() string {
	return LoadProperty("password", "")
}

func SaveToken(value string) {
	SaveProperty("token", value)
}

func LoadToken() string {
	return LoadProperty("token", "")
}

func SaveTokenTime(value int64) {
	SaveProperty("token_time", strconv.FormatInt(value,10))
}

func LoadTokenTime() int64 {
	r, _ := strconv.ParseInt(LoadProperty("token_time", "0"),10,64)
	return r
}
