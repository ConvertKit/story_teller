package main

import (
	"flag"
	"github.com/convertkit/stories/integrations"
	"github.com/convertkit/stories/stories"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"
)

var queue *stories.Queue

func main() {
	bufferSize := flag.Int("buffer", 1000, "size of the buffer before sending stories")
	seconds := flag.Int("interval", 1, "seconds before sending stories")
	integrationName := flag.String("integration", "scalyr", "integration to use with StoryTeller")
	socketPath := flag.String("socket", "/tmp/stories.sock", "path of the socket created by this agent")
	debug := flag.Bool("debug", false, "show debug logs")

	flag.Parse()

	queue = stories.NewQueueOfSize(*bufferSize)
	integration, err := integrations.Use(*integrationName, debug)

	if err != nil {
		log.Fatal("Couldn't configure integration: ", err)
	}

	listener, err := net.Listen("unix", *socketPath)

	if err != nil {
		log.Fatal("Couldn't launch agent: ", err)
	}

	go theEnd(integration, listener)
	go tick(integration, *seconds)

	for {
		if queue.IsFull() {
			go push(integration)
		}

		conn, err := listener.Accept()

		if err != nil {
			// Connection errors happen infrequently and can be ignored
			// Network hiccups do happen and we want to run this agent like an
			// UDP protocol. If we have a valid connection, let's handle the data,
			// otherwise, no big deal!
			continue
		}

		err = queue.Add(conn)

		if err != nil {
			log.Print("Error occurred trying to read from socket: ", err)
		}
	}
}

func tick(integration integrations.Integration, seconds int) {
	log.Printf("Starting the runloop with an interval of %d seconds", seconds)

	clock := time.Tick(time.Duration(seconds) * time.Second)
	for range clock {
		if queue.IsEmpty() != true {
			go push(integration)
		}
	}
}

func push(integration integrations.Integration) {
	stories := queue.Collect()
	_, err := integration.Send(stories)
	if err != nil {
		log.Print("Error occurred while trying to send stories: ", err)
	}
}

func theEnd(integration integrations.Integration, l net.Listener) {
	channel := make(chan os.Signal, 1)
	signal.Notify(channel, os.Interrupt, syscall.SIGTERM)

	<-channel
	err := l.Close()

	log.Print("Gracefully exiting...")

	if err != nil {
		log.Print("Error while trying to close the listener", err)
	}

	if queue.IsEmpty() != true {
		log.Printf("Sending remaining stories before shutdown")
		push(integration)
	}

	log.Print("See ya!")
	os.Exit(0)
}
