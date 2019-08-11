package integrations

import (
	"errors"
	"github.com/convertkit/stories/integrations/scalyr"
	"github.com/convertkit/stories/stories"
	"net/http"
)

type Integration interface {
	Send([]*stories.Story) (*http.Response, error)
	Configure(*bool) error
}

func Use(name string, debug *bool) (Integration, error) {
	switch name {
	case "scalyr":
		instance := &scalyr.Instance{}
		err := instance.Configure(debug)
		return instance, err
	default:
		return nil, errors.New("Invalid integration")
	}
}
