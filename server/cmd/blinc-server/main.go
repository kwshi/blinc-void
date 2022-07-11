package main

import (
	"github.com/alecthomas/kong"
	"github.com/containers/buildah"
	"github.com/containers/storage/pkg/unshare"
	"github.com/kwshi/blinc/server/internal/web"
)

type CLI struct {
	Start CmdStart `cmd:""`
}

type CmdStart struct {
	Port int `kong:"help='port to listen on',default=8149"`
}

func (c *CmdStart) Run() error {

	return web.NewServer().Start(c.Port)

}

func main() {
	cli := &CLI{}
	ctx := kong.Parse(cli)

	if buildah.InitReexec() {
		return
	}
	unshare.MaybeReexecUsingUserNamespace(false)

	err := ctx.Run()
	ctx.FatalIfErrorf(err)

}
