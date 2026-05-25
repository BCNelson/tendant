package main

import "fmt"

var (
	version   = "dev"
	commit    = "unknown"
	buildDate = "unknown"
)

func main() {
	fmt.Printf("tendant %s (%s, built %s)\n", version, commit, buildDate)
	fmt.Println("Hello, tendant!")
}
