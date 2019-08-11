package stories

import (
	"encoding/json"
	"log"
	"net"
)

type Analytics interface {
	PrintStats() string
}

type Queue struct {
	channel chan *Story
	*Stats
}

type Stats struct {
}

func NewQueueOfSize(size int) *Queue {
	log.Printf("Starting the queue with a buffer of %d stories", size)
	return &Queue{make(chan *Story, size), &Stats{}}
}

func (q *Queue) Add(c net.Conn) error {
	defer c.Close()
	var story *Story

	decoder := json.NewDecoder(c)
	err := decoder.Decode(&story)

	if err != nil {
		return err
	}

	q.channel <- story

	return nil
}

func (q *Queue) Collect() []*Story {
	var stories []*Story
	empty := false

	for empty != true {
		var story *Story
		select {
		case story = <-q.channel:
			stories = append(stories, story)
		default:
			empty = true
		}
	}

	return stories
}

func (q *Queue) Capacity() int {
	return cap(q.channel)
}

func (q *Queue) Size() int {
	return len(q.channel)
}

func (q *Queue) IsEmpty() bool {
	return len(q.channel) == 0
}

func (q *Queue) IsFull() bool {
	return q.Size() >= q.Capacity()
}
