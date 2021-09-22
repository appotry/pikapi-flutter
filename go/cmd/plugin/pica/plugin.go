package pica

import (
	"errors"
	"github.com/go-flutter-desktop/go-flutter/plugin"
	"pgo/pikapi/controller"
	"sync"
)

var eventMutex = sync.Mutex{}
var eventSink *plugin.EventSink

type EventHandler struct {
}

func (s *EventHandler) OnListen(arguments interface{}, sink *plugin.EventSink) {
	eventMutex.Lock()
	defer eventMutex.Unlock()
	eventSink = sink
}

func (s *EventHandler) OnCancel(arguments interface{}) {
	eventMutex.Lock()
	defer eventMutex.Unlock()
	eventSink = nil
}

const channelName = "pica"

type Plugin struct {
}

func (p *Plugin) InitPlugin(messenger plugin.BinaryMessenger) error {

	channel := plugin.NewMethodChannel(messenger, channelName, plugin.StandardMethodCodec{})

	channel.HandleFunc("flatInvoke", func(arguments interface{}) (interface{}, error) {
		if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
			if method, ok := argumentsMap["method"].(string); ok {
				if params, ok := argumentsMap["params"].(string); ok {
					return controller.FlatInvoke(method, params)
				}
			}
		}
		return nil, errors.New("params error")
	})

	exporting := plugin.NewEventChannel(messenger, "flatEvent", plugin.StandardMethodCodec{})
	exporting.Handle(&EventHandler{})

	controller.EventNotify = func(message string) {
		eventMutex.Lock()
		defer eventMutex.Unlock()
		sink := eventSink
		if sink != nil {
			sink.Success(message)
		}
	}

	return nil // no error
}
