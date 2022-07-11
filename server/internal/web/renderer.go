package web

import (
	"embed"
	"github.com/labstack/echo/v4"
	"html/template"
	"io"
)

//go:embed template
var fs embed.FS

var Index = template.Must(template.ParseFS(fs, "template/index.html"))

type templateRenderer struct {
	*template.Template
}

func (t templateRenderer) Render(wr io.Writer, name string, data interface{}, c echo.Context) error {
	return t.ExecuteTemplate(wr, name, data)
}
