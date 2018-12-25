package main

import (
	"errors"
	"fmt"
	"log"
	"net/http"
	"net/rpc"
	"time"
)

type Args struct {
	A, B int
}

type Quotient struct {
	Quo, Rem int
}

type Arith int

func (t *Arith) Multiply(args *Args, reply *int) error {
	*reply = args.A * args.B
	fmt.Println(*reply, "=", args.A, "*", args.B)
	return nil
}

func (t *Arith) Divide(args *Args, quo *Quotient) error {
	if args.B == 0 {
		return errors.New("divide by zeror")
	}
	quo.Quo = args.A / args.B
	quo.Rem = args.A % args.B
	return nil
}

func main() {
	rpc.Register(new(Arith))
	rpc.HandleHTTP()
	e := http.ListenAndServe(":1234", nil)

	if e != nil {
		log.Fatal("listen error:", e)
	} else {
		time.Sleep(100 * time.Millisecond)
	}
}
