package main

import (
	"fmt"
	"log"
	"net"
	"os/exec"
	"sync"
	"time"
)

// Knock sequence
var knockSequence = []int{1234, 5678, 3456}
var knockIndex = 0
var mu sync.Mutex


const knockTimeout = 10 * time.Second

func main() {
	ports := []int{1234, 5678, 3456}

	for _, port := range ports {
		go startListener(port)
	}

	select {} 
}

func startListener(port int) {
	address := fmt.Sprintf(":%d", port)
	listener, err := net.Listen("tcp", address)
	if err != nil {
		log.Fatalf("Failed to listen on port %d: %v", port, err)
	}
	defer listener.Close()

	log.Printf("Listening on port %d for knocks", port)

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Error accepting connection on port %d: %v", port, err)
			continue
		}
		go handleConnection(conn, port)
	}
}

func handleConnection(conn net.Conn, port int) {
	defer conn.Close()

	mu.Lock()
	defer mu.Unlock()

	if port == knockSequence[knockIndex] {
		knockIndex++
		log.Printf("Correct knock on port %d", port)
		if knockIndex == len(knockSequence) {
			log.Println("Knock sequence completed! Opening SSH port...")
			openPort(22)
			knockIndex = 0
			time.AfterFunc(knockTimeout, func() {
				closePort(22)
			})
		}
	} else {
		knockIndex = 0
		log.Println("Incorrect knock, resetting sequence")
	}
}

func openPort(port int) {
	cmd := exec.Command("iptables", "-I", "INPUT", "-p", "tcp", "--dport", fmt.Sprintf("%d", port), "-j", "ACCEPT")
	if err := cmd.Run(); err != nil {
		log.Printf("Failed to open port %d: %v", port, err)
	} else {
		log.Printf("Port %d opened successfully", port)
	}
}

func closePort(port int) {
	cmd := exec.Command("iptables", "-D", "INPUT", "-p", "tcp", "--dport", fmt.Sprintf("%d", port), "-j", "ACCEPT")
	if err := cmd.Run(); err != nil {
		log.Printf("Failed to close port %d: %v", port, err)
	} else {
		log.Printf("Port %d closed successfully", port)
	}
}
