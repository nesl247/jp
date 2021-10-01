package projects

import (
	"encoding/json"
	"fmt"
	"os"
	"path"
	"strings"
)

func Update(verbose bool) (Projects, error) {
	projects, err := Load()
	if err != nil {
		return projects, err
	}

	projectDirs := strings.Split(os.Getenv("JP_PROJECT_DIRS"), " ")
	for _, projectDir := range projectDirs {
		dir, err := os.Stat(projectDir)
		if err != nil {
			continue
		}

		if !dir.IsDir() {
			continue
		}

		entries, err := os.ReadDir(projectDir)
		if err != nil {
			return projects, err
		}

		for j := range entries {
			if !entries[j].IsDir() {
				continue
			}

			// Skip hidden files
			if entries[j].Name()[0:1] == "." {
				continue
			}

			// Don't include projectDirs in the list
			if isEntryAProjectDirectory(projectDirs, path.Join(projectDir, entries[j].Name())) {
				continue
			}

			project := Project{
				Name:     entries[j].Name(),
				FullName: fmt.Sprintf("%s/%s", path.Base(projectDir), entries[j].Name()),
				Path:     path.Join(projectDir, entries[j].Name())}

			if isProjectAlreadyKnown(projects, project) {
				continue
			}

			projects = append(projects, project)
		}
	}

	contents, err := json.MarshalIndent(projects, "", "  ")
	if err != nil {
		return projects, err
	}

	err = os.WriteFile(projectFilePath(), contents, 0666)
	if err != nil {
		return projects, err
	}

	if verbose {
		projects.List()
	}

	return projects, nil
}

func isProjectAlreadyKnown(projects Projects, project Project) bool {
	for k := range projects {
		if projects[k].FullName == project.FullName {
			return true
		}
	}

	return false
}

func isEntryAProjectDirectory(projectDirs []string, entryPath string) bool {
	for _, projectDir := range projectDirs {
		if projectDir == entryPath {
			return true
		}
	}

	return false
}
