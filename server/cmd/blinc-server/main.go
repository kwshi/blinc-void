package main

import (
	"github.com/alecthomas/kong"
	"log"
)

type CLI struct {
	Start CmdStart `kong:"cmd"`
}

type CmdStart struct {
	Port int `kong:"help='port to listen on',default=8149"`
}

func (c *CmdStart) Run() error {
	log.Printf("starting on :%d", c.Port)
	return nil
}

func main() {
	cli := &CLI{}
	ctx := kong.Parse(cli)
	err := ctx.Run()
	ctx.FatalIfErrorf(err)

}
