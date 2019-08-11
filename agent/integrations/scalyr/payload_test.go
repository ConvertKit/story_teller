package scalyr

import (
	"encoding/json"
	"github.com/convertkit/stories/stories"
	"os"
	"testing"
)

func instanceForInstanceTest(t *testing.T) *Instance {
	os.Setenv("SCALYR_WRITE_TOKEN", "test")
	debug := false

	instance := &Instance{}
	err := instance.Configure(&debug)

	if err != nil {
		t.Error(err)
		t.Fail()
	}

	return instance
}

func payloadForInstanceTest(t *testing.T) *Payload {
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

	stories := []*stories.Story{story}
	return NewPayload(instanceForInstanceTest(t), stories)
}

func TestTokenPresentInJSON(t *testing.T) {
	payload := payloadForInstanceTest(t)
	body, err := json.Marshal(&payload)

	if err != nil {
		t.Error(err)
	}

	var data map[string]interface{}

	err = json.Unmarshal(body, &data)

	if err != nil {
		t.Error(err)
	}

	if data["token"] == nil {
		t.Fail()
	}

	if data["token"] != payload.Token {
		t.Fail()
	}
}
