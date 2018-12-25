package main

import (
	"errors"
	"fmt"
	"net"
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

	address, _ := net.ResolveTCPAddr("tcp", "127.0.0.1:1234")
	listener, err := net.ListenTCP("tcp", address)

	if err != nil {
		fmt.Println("tcp server start fail: ", err)
	}

	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("rpc.Server: Accept error :", err)
			return
		}
		fmt.Println("received a request...")
		go rpc.ServeConn(conn)
	}

	time.Sleep(1000 * time.Second)
}
