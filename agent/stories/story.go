package stories

import (
	"encoding/json"
)

type Story struct {
	Severity  int
	Message   string
	Timestamp string
	Data      map[string]json.RawMessage
}

func (s *Story) UnmarshalJSON(bytes []byte) error {
	type alias Story
	err := json.Unmarshal(bytes, (*alias)(s))

	if err != nil {
		return err
	}

	if s.Data == nil {
		s.Data = make(map[string]json.RawMessage)
	}

	if s.Severity == 0 {
		s.Severity = 3
	}

	return nil
}
