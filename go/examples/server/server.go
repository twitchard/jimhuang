package main

import (
	"fmt"
	"io"
	"net"
)

func doServerStuff(conn net.Conn) {
	for {
		buf := make([]byte, 512)
		len, err := conn.Read(buf)
		if err != nil {
			if err == io.EOF {
				fmt.Println("End of reading")
				return
			}
			fmt.Println("Error reading", err.Error())
			return
		}
		fmt.Printf("Received data :%v", string(buf[:len]))
	}
}

func main() {
	fmt.Println("Starting the server...")
	listener, err := net.Listen("tcp", "localhost:50000")
	if err != nil {
		fmt.Println("Error listening", err.Error())
		return
	}

	for {
		conn, err := listener.Accept()
		if err != nil {
			fmt.Println("Error accepting", err.Error())
			return
		}
		go doServerStuff(conn)
	}
}
