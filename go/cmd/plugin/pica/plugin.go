package pica

import (
	"errors"
	"github.com/go-flutter-desktop/go-flutter/plugin"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"pgo/pikapi/controller"
	"sync"
)

var eventMutex = sync.Mutex{}
var eventMap = map[string]map[string]*plugin.EventSink{}

type EventHandler struct {
}

func (s *EventHandler) OnListen(arguments interface{}, sink *plugin.EventSink) {
	if sink != nil {
		if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
			if function, ok := argumentsMap["function"].(string); ok {
				if id, ok := argumentsMap["id"].(string); ok {
					eventMutex.Lock()
					defer eventMutex.Unlock()
					if _, ok := eventMap[function]; !ok {
						eventMap[function] = map[string]*plugin.EventSink{}
					}
					eventMap[function][id] = sink
				}
			}
		}
	}
}

func (s *EventHandler) OnCancel(arguments interface{}) {
	if argumentsMap, ok := arguments.(map[interface{}]interface{}); ok {
		if function, ok := argumentsMap["function"].(string); ok {
			if id, ok := argumentsMap["id"].(string); ok {
				eventMutex.Lock()
				defer eventMutex.Unlock()
				if _, ok := eventMap[function]; !ok {
					eventMap[function] = map[string]*plugin.EventSink{}
				}
				delete(eventMap[function], id)
			}
		}
	}
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

	exporting := plugin.NewEventChannel(messenger, "event", plugin.StandardMethodCodec{})
	exporting.Handle(&EventHandler{})

	controller.EventNotify = func(function string, value string) {
		eventMutex.Lock()
		defer eventMutex.Unlock()
		if m, ok := eventMap[function]; ok {
			for _, sink := range m {
				if sink != nil {
					sink.Success(value)
				}
			}
		}
	}

	return nil // no error
}
