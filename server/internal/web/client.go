package web

import (
	"context"
	"github.com/labstack/echo/v4"
	"nhooyr.io/websocket"
	"sync"
	"time"
)

const maxBufferSize = 3

type client struct {
	logger echo.Logger

	connection *websocket.Conn

	buffer     [][]byte
	bufferCond sync.Cond
}

func newClient(logger echo.Logger, connection *websocket.Conn) *client {
	return &client{
		logger:     logger,
		connection: connection,
		buffer:     [][]byte{[]byte("hello"), []byte("world")},
		bufferCond: sync.Cond{L: &sync.Mutex{}},
	}
}

func (clt *client) writeMessages(ctx context.Context, msgs [][]byte) error {
	writeCtx, cancel := context.WithTimeout(ctx, time.Second)
	defer cancel()

	for _, msg := range msgs {
		if err := clt.connection.Write(writeCtx, websocket.MessageText, msg); err != nil {
			return err
		}
	}

	return nil
}

func (clt *client) listen(ctx context.Context) error {
	for {
		// empty buffer quickly
		clt.bufferCond.L.Lock()
		msgs := clt.buffer
		clt.buffer = clt.buffer[len(clt.buffer):]
		clt.bufferCond.L.Unlock()

		// send messages slowly
		if err := clt.writeMessages(ctx, msgs); err != nil {
			return err
		}

		// wait until more data is added to buffer
		clt.bufferCond.L.Lock()
		clt.bufferCond.Wait()
		clt.bufferCond.L.Unlock()

	}
}

func (c *client) send(msg []byte) {
	c.logger.Infof("sending a message")

	c.bufferCond.L.Lock()
	if len(c.buffer) >= maxBufferSize {
		c.logger.Infof("closing connection")
		go c.connection.Close(websocket.StatusPolicyViolation, "too slow")
	}
	c.buffer = append(c.buffer, msg)
	c.bufferCond.L.Unlock()

	// signal that new data has been added to the buffer
	c.bufferCond.Signal()
}
