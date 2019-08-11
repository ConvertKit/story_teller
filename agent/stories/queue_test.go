package stories

import (
	"net"
	"testing"
)

func TestQueueInitializedWithSize(t *testing.T) {
	size := 100
	queue := NewQueueOfSize(size)

	if queue.Capacity() != size {
		t.Fail()
	}
}

func TestCollectingWillClearTheQueue(t *testing.T) {
	size := 10
	queue := NewQueueOfSize(size)

	for i := 0; i < size; i++ {
		server, client := net.Pipe()
		go func() {
			server.Write(storyJSON())
			server.Close()
		}()

		err := queue.Add(client)

		if err != nil {
			t.Fatal(err)
		}
	}

	if queue.IsEmpty() {
		t.Fatal("Queue should not have been empty")
	}

	if len(queue.Collect()) != size {
		t.Fatalf("Wanted a queue of %d. Got %d", queue.Capacity(), size)
	}

	if queue.IsEmpty() != true {
		t.Fatalf("Queue should have been empty, has a size of %d", queue.Capacity())
	}
}

func TestQueueIsFullAtMaxSize(t *testing.T) {
	size := 10
	queue := NewQueueOfSize(size)

	for i := 0; i < size; i++ {
		server, client := net.Pipe()
		go func() {
			server.Write(storyJSON())
			server.Close()
		}()

		err := queue.Add(client)

		if err != nil {
			t.Fatal(err)
		}
	}

	if queue.IsFull() != true {
		t.Fatal("Queue should have been full")
	}
}

func TestEmptyQueue(t *testing.T) {
	size := 10
	queue := NewQueueOfSize(size)

	if queue.IsEmpty() != true {
		t.Fatal("Queue should have been empty")
	}
}
