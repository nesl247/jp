package projects

import (
	"encoding/json"
	"errors"
	"io/fs"
	"io/ioutil"
	"os"
	"path"
)

func projectFilePath() string {
	homeDir, _ := os.UserHomeDir()

	return path.Join(homeDir, ".config/jp/projects.json")
}

func Load() (Projects, error) {
	projects := make(Projects, 0)

	var projectFile, err = os.Open(projectFilePath())
	if err != nil {
		if errors.Is(err, fs.ErrNotExist) {
			projectFile, err = os.Create(projectFilePath())
			if err != nil {
				return projects, err
			}
		} else {
			return projects, err
		}
	}

	defer projectFile.Close()

	contents, err := ioutil.ReadAll(projectFile)
	if err != nil {
		return projects, err
	}

	if len(contents) == 0 {
		return projects, nil
	}

	err = json.Unmarshal(contents, &projects)
	if err != nil {
		return projects, err
	}

	return projects, nil
}
