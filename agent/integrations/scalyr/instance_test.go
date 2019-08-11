package scalyr

import (
	"os"
	"strings"
	"testing"
)

func TestConfigureInstanceGenerateASessionUUID(t *testing.T) {
	os.Setenv("SCALYR_WRITE_TOKEN", "test")
	debug := false

	instance := &Instance{}
	err := instance.Configure(&debug)

	if err != nil {
		t.Error(err)
	}

	if strings.Compare(instance.Session.String(), "") == 0 {
		t.FailNow()
	}
}

func TestConfigureMultipleTimeWontChangeSession(t *testing.T) {
	debug := false
	instance := &Instance{}
	instance.Configure(&debug)

	session := instance.Session.String()

	instance.Configure(&debug)

	if strings.Compare(session, instance.Session.String()) != 0 {
		t.FailNow()
	}
}
