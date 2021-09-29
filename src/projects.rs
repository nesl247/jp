use std::fs::{File, OpenOptions};
use std::io::{Read, Write};
use std::path::{Path, PathBuf};

use anyhow::{Context, Error};
use log::debug;
use ngrammatic::{CorpusBuilder, Pad};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub struct Project {
    pub full_name: String,
    pub name: String,
    pub path: PathBuf,
}

pub struct Projects(Vec<Project>);

impl Projects {
    pub fn find(&mut self, project_name: &str) -> Option<&Project> {
        let mut corpus = CorpusBuilder::new()
            .arity(3)
            .pad_full(Pad::Auto)
            .case_insensitive()
            .finish();

        for project in &self.0 {
            corpus.add_text(&project.full_name);
        }

        let matched_project = corpus.search(project_name, 0.0);
        let matched_project = matched_project.first();

        match matched_project {
            Some(matched_project) => {
                let index = self.0
                    .iter()
                    .position(|project| &project.full_name == &matched_project.text).unwrap();

                let project = self.0.remove(index);

                self.0.insert(0, project);

                // TODO: make this safe by removing unwraps
                let mut projects_file = Projects::open_file().unwrap();
                projects_file.write(serde_json::to_vec_pretty(&self.0).unwrap().as_slice()).unwrap();

                Some(&self.0.first().unwrap())
            }
            None => None
        }
    }

    pub fn list() -> Vec<Project> {
        Projects::load().unwrap_or(Projects(vec![])).0
    }

    fn file_path() -> PathBuf {
        dirs::home_dir().unwrap().join(".config/op/projects.json")
    }

    fn open_file() -> Result<File, Error> {
        OpenOptions::new()
            .create(true)
            .write(true)
            .read(true)
            .open(Projects::file_path())
            .with_context(|| {
                format!(
                    "Failed to open or create {}",
                    Projects::file_path().display()
                )
            })
    }

    pub fn load() -> Result<Self, anyhow::Error> {
        let mut projects_file = Projects::open_file()?;

        let mut contents = String::new();
        projects_file
            .read_to_string(&mut contents)
            .with_context(|| format!("Failed to read projects file"))?;

        let mut projects: Projects = Projects(vec![]);

        if !contents.is_empty() {
            projects.0.append(
                &mut serde_json::from_str(&contents)
                    .with_context(|| "Failed to parse projects file")?,
            );
        }

        Ok(projects)
    }

    pub fn update(project_dirs: Vec<&str>) -> Result<(), anyhow::Error> {
        let mut projects = Projects::load()?;

        println!("Updating projects");

        let project_dirs: Vec<&Path> = project_dirs
            .iter()
            .map(|project_dir| Path::new(project_dir))
            .collect();

        for project_dir in &project_dirs {
            debug!("Searching {}", &project_dir.display());

            if !&project_dir.is_dir() {
                debug!(
                    "Skipping {} as it is not a directory",
                    &project_dir.display()
                );

                continue;
            }

            for entry in std::fs::read_dir(&project_dir)? {
                let entry = entry?;

                if !&entry.path().is_dir() {
                    debug!(
                        "Skipping {} as it is not a directory",
                        &entry.path().display()
                    );
                    continue;
                }

                let path = entry.path();

                if project_dirs.contains(&path.as_path()) {
                    debug!(
                        "Skipping {} as it is a project directory",
                        &entry.path().display()
                    );
                    continue;
                }

                let name = entry.file_name().to_str().unwrap().to_string();
                let full_name = format!(
                    "{}/{}",
                    project_dir
                        .file_name()
                        .unwrap()
                        .to_str()
                        .unwrap()
                        .to_string(),
                    name
                );

                for project in &projects.0 {
                    if &project.full_name == entry.file_name().to_str().unwrap() {
                        continue;
                    }
                }

                let project = Project {
                    full_name,
                    name,
                    path,
                };

                if projects.0.contains(&project) {
                    continue;
                }

                projects.0.push(project);
            }
        }

        let mut projects_file = Projects::open_file()?;
        projects_file.write(serde_json::to_vec_pretty(&projects.0)?.as_slice())?;

        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use crate::projects::{Project, Projects};

    #[test]
    fn find_project_returns_result_for_exact_match() {
        let project1 = Project {
            full_name: String::from("test/example1"),
            name: String::from("example1"),
            path: Default::default(),
        };
        let project2 = Project {
            full_name: String::from("test/example2"),
            name: String::from("example2"),
            path: Default::default(),
        };
        let projects = Projects(vec![project1, project2]);

        assert_eq!(projects.find("test/example1"), project1)
    }
}
