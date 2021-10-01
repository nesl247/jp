package projects

import "fmt"

func (p Projects) List() {
	for i := range p {
		fmt.Println(p[i].FullName)
	}
}
