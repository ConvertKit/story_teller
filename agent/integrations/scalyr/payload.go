package scalyr

import (
	"encoding/json"
	"github.com/convertkit/stories/stories"
)

type Payload struct {
	Token       string
	Session     string
	SessionInfo map[string]string
	Stories     []*stories.Story
}

func NewPayload(instance *Instance, stories []*stories.Story) *Payload {
	return &Payload{
		instance.Secret,
		instance.Session.String(),
		instance.SessionInfo,
		stories}
}

func (p *Payload) MarshalJSON() ([]byte, error) {
	var events []Event

	for _, story := range p.Stories {
		events = append(events, Event(*story))
	}

	data := make(map[string]interface{})
	data["token"] = p.Token
	data["session"] = p.Session
	data["sessionInfo"] = p.SessionInfo
	data["events"] = events

	return json.Marshal(data)
}
