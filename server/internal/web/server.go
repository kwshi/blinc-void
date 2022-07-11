package web

import (
	"fmt"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"net/http"
	"nhooyr.io/websocket"
	"sync"
)

type Server struct {
	*echo.Echo

	clients   map[*client]struct{}
	clientsMu sync.RWMutex
}

func handleRoot(c echo.Context) error {
	return c.Render(http.StatusOK, "hello", nil)
}

func (s *Server) handleBroadcast(c echo.Context) error {

	msg := c.FormValue("message")
	if len(msg) == 0 {
		return c.String(http.StatusBadRequest, "missing or empty `message` parameter")
	}

	s.clientsMu.RLock()
	for c := range s.clients {
		c.send([]byte(msg))
	}
	s.clientsMu.RUnlock()

	return c.String(http.StatusOK, "start")
}

func (s *Server) handleWS(c echo.Context) error {
	conn, err := websocket.Accept(c.Response(), c.Request(), &websocket.AcceptOptions{
		// TODO
		InsecureSkipVerify: true,
	})
	if err != nil {
		return err
	}
	defer conn.Close(websocket.StatusInternalError, "unexpected close")

	s.Logger.Info("got new client")

	clt := newClient(s.Logger, conn)

	s.addClient(clt)
	defer s.removeClient(clt)

	return clt.listen(c.Request().Context())

}

func NewServer() *Server {
	e := echo.New()
	e.Renderer = templateRenderer{Index}
	e.Debug = true
	e.HideBanner = true

	server := &Server{
		Echo:    e,
		clients: make(map[*client]struct{}),
	}

	e.Use(middleware.Logger())
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"http://127.0.0.1:3000"},
		AllowMethods: []string{http.MethodGet},
	}))

	e.GET("/", handleRoot)
	e.POST("/broadcast", server.handleBroadcast)
	e.GET("/ws", server.handleWS)

	return server

}

func (s *Server) Start(port int) error {
	return s.Echo.Start(fmt.Sprintf("localhost:%d", port))
}

func (s *Server) addClient(clt *client) {
	s.clientsMu.Lock()
	s.clients[clt] = struct{}{}
	s.clientsMu.Unlock()
}

func (s *Server) removeClient(clt *client) {
	s.clientsMu.Lock()
	delete(s.clients, clt)
	s.clientsMu.Unlock()
}
