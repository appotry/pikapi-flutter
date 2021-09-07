module pgo

go 1.16

require pica v0.0.0

replace pica v0.0.0 => ./pica

require (
	github.com/PuerkitoBio/goquery v1.7.1
	github.com/go-flutter-desktop/go-flutter v0.43.0
	github.com/go-flutter-desktop/plugins/url_launcher v0.1.2
	github.com/miguelpruivo/flutter_file_picker/go v0.0.0-20210622152105-9f0a811028a0
	github.com/pkg/errors v0.9.1
	golang.org/x/image v0.0.0-20190802002840-cff245a6509b
	golang.org/x/mobile v0.0.0-20210902104108-5d9a33257ab5 // indirect
	gorm.io/driver/sqlite v1.1.4
	gorm.io/gorm v1.21.12
)
