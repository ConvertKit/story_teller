package scalyr

import (
	"encoding/json"
	"github.com/convertkit/stories/stories"
	"testing"
)

func story(t *testing.T) *stories.Story {
	var story *stories.Story
	err := json.Unmarshal([]byte(`{
    "severity": 4,
    "timestamp": "1541354132811",
    "message": "Hello world!",
    "data": {
      "foo": {
        "bar": "Something",
        "yolo": true
      },
      "object_id": 1234,
      "boolean": true,
      "content": "Stuff"
    }
  }`), &story)

	if err != nil {
		t.Fail()
	}

	return story
}

func payloadForEventTest(story *stories.Story, t *testing.T) map[string]interface{} {
	event := Event(*story)
	content, err := json.Marshal(&event)

	if err != nil {
		t.Fail()
	}

	var payload map[string]interface{}

	err = json.Unmarshal(content, &payload)

	if err != nil {
		t.Error(err)
		t.Fail()
	}

	return payload
}

func TestTimestampInJSON(t *testing.T) {
	story := story(t)
	payload := payloadForEventTest(story, t)

	if payload["ts"] != string("1541354132811") {
		t.Fail()
	}
}

func TestSevInJSON(t *testing.T) {
	story := story(t)
	payload := payloadForEventTest(story, t)

	if payload["sev"].(float64) != float64(4) {
		t.Fail()
	}
}

func TestMessageInAttributesJSON(t *testing.T) {
	story := story(t)
	payload := payloadForEventTest(story, t)

	attributes := payload["attrs"].(map[string]interface{})

	if attributes["message"] != string("Hello world!") {
		t.Fail()
	}
}
