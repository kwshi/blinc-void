package build

import (
	"context"
	"fmt"
	"github.com/containers/buildah"
	"github.com/containers/storage"
	"log"
	"sync"
)

type Builder struct {
	sync.RWMutex
	busy bool
}

func NewBuilder() *Builder {
	return &Builder{
		busy: false,
	}
}

func (b *Builder) Start() {
	b.Lock()
	defer b.Unlock()

	if b.busy {
		return
	}

	b.busy = true
	go b.run()
}

func (b *Builder) run() {
	b.Lock()
	b.busy = false
	b.Unlock()

}

func Build() error {

	storeOpts, err := storage.DefaultStoreOptionsAutoDetectUID()
	storeOpts.GraphDriverName = "overlay"
	if err != nil {
		return err
	}

	log.Println("trying to get store")

	store, err := storage.GetStore(storeOpts)
	if err != nil {
		return fmt.Errorf("failed to get store: %v", err)
	}

	log.Println("huh")

	builder, err := buildah.NewBuilder(context.Background(), store, buildah.BuilderOptions{
		FromImage: "scratch",
	})
	if err != nil {
		return err
	}

	builder.Logger.Info("ping pong")

	log.Println("ok", builder.Container)

	log.Println("deleting")
	if err := builder.Delete(); err != nil {
		return err
	}

	return nil
}
