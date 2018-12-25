package main

import (
	"errors"
	"fmt"
	"log"
	"net/rpc"
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
	return nil
}

func (t *Arith) Divide(args *Args, quo *Quotient) error {
	if args.B == 0 {
		return errors.New("divide by zero")
	}

	quo.Quo = args.A / args.B
	quo.Rem = args.A % args.B

	return nil
}

func main() {
	client, err := rpc.DialHTTP("tcp", "127.0.0.1:1234")
	if err != nil {
		log.Fatal("dialing:", err)
	}

	args := &Args{7, 8}
	var reply int
	err = client.Call("Arith.Multiply", args, &reply)

	var reply1 int
	args1 := &Args{9, 22}
	err = client.Call("Arith.Multiply", args1, &reply1)

	if err != nil {
		log.Fatal("airth error:", err)
	}

	fmt.Println("Arith: ", args.A, "*", args.B, "=", reply)
	fmt.Println("Arith: ", args1.A, "*", args1.B, "=", reply1)
}
