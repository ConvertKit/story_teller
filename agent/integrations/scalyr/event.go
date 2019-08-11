package scalyr

import (
	"encoding/json"
	"github.com/convertkit/stories/stories"
)

type Event stories.Story

func (e *Event) MarshalJSON() ([]byte, error) {
	data := make(map[string]interface{})
	data["ts"] = e.Timestamp
	data["sev"] = e.Severity

	attributes := e.Data

	message, err := json.Marshal(e.Message)

	if err != nil {
		return nil, err
	}

	attributes["message"] = message

	data["attrs"] = attributes

	return json.Marshal(data)
}
