package projects

type Projects []Project

func (p Projects) String(i int) string {
	return p[i].FullName
}

func (p Projects) Len() int {
	return len(p)
}
