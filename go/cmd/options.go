package main

import (
	"github.com/go-flutter-desktop/go-flutter"
	filePicker "github.com/miguelpruivo/flutter_file_picker/go"
	pica2 "pgo/cmd/plugin/pica"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(600, 900),
	flutter.AddPlugin(&pica2.Plugin{}),
	flutter.AddPlugin(&filePicker.FilePickerPlugin{}),
}
