package stories

import (
	"encoding/json"
	"testing"
)

func storyJSON() []byte {
	return []byte(`{
    "severity": 4,
    "data": {
      "foo": {
        "bar": "Something",
        "ints": 1234,
        "array": ["1234", 9832],
        "yolo": true
      },
      "object_id": 1234,
      "boolean": true,
      "some": "value"
    }
  }`)
}

func TestUnmarshalWithInvalidJSON(t *testing.T) {
	var story *Story
	err := json.Unmarshal([]byte("Invalid "), &story)

	if story != nil {
		t.Fail()
	}

	if err == nil {
		t.Fail()
	}
}

func TestUnmarshalWithValidJSON(t *testing.T) {
	var story *Story
	err := json.Unmarshal([]byte(`{"foo": "bar"}`), &story)

	if story == nil {
		t.Error(err)
	}

	if err != nil {
		t.Fail()
	}
}

func TestUnmarshalHasDefaultSeverity(t *testing.T) {
	var story *Story
	err := json.Unmarshal([]byte("{\"foo\": \"bar\"}"), &story)

	if err != nil {
		t.Fail()
	}

	if story.Severity != 3 {
		t.Error(story)
	}
}

func TestUnmarshalSetsSeverityIfExists(t *testing.T) {
	var story *Story
	sev := 4
	data := make(map[string]interface{})
	data["severity"] = sev

	payload, err := json.Marshal(data)

	if err != nil {
		t.Error(err)
	}

	err = json.Unmarshal(payload, &story)

	if err != nil {
		t.Fail()
	}

	if story.Severity != 4 {
		t.Error(story)
	}
}

func TestUnmarshalDataIsNeverNil(t *testing.T) {
	var story *Story
	data := make(map[string]interface{})

	payload, err := json.Marshal(data)

	if err != nil {
		t.Error(err)
	}

	err = json.Unmarshal(payload, &story)

	if err != nil {
		t.Fail()
	}

	if story.Data == nil {
		t.Fail()
	}
}

func TestUnmarshalWithCompleteData(t *testing.T) {
	var event *Story
	err := json.Unmarshal(storyJSON(), &event)

	payload, err := json.Marshal(event)

	if err != nil {
		t.Error(err)
	}

	var story *Story
	err = json.Unmarshal(payload, &story)

	if err != nil {
		t.Fail()
	}

	if story.Severity != 4 {
		t.Fail()
	}

	if story.Data["foo"] == nil {
		t.Fail()
	}
}
