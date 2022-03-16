use anyhow::Result;
use std::env;

use clap::{App, AppSettings, Arg};
use log::LevelFilter;
use simplelog::{ColorChoice, TermLogger};

use jp::projects::Projects;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let project_directories: Vec<&str> = env!("JP_PROJECT_DIRS").split(" ").collect();

    let configured_project_directories = format!(
        "Configured project directories: \n\n{}",
        project_directories.join("\n")
    );

    let mut app = App::new("Jump to Project (jp)")
        .version("1.0")
        .author("Alexander Kim <alexander@kim.family>")
        .about("Open projects in your terminal, and optionally other related tools.")
        .after_help(configured_project_directories.as_str())
        .after_long_help(configured_project_directories.as_str())
        .setting(AppSettings::InferSubcommands)
        .subcommand(App::new("update").about("update project list"))
        .subcommand(App::new("list").about("list projects"))
        .arg(
            Arg::new("project")
                .about("project name")
                .takes_value(true)
                .index(1)
        )
        .arg(
            Arg::new("debug")
                .about("debug mode")
                .short('d')
                .long("debug")
        );

    let matches = &app.get_matches_mut();

    let debug = matches.is_present("debug");

    TermLogger::init(
        match debug {
            true => LevelFilter::Debug,
            false => LevelFilter::Info,
        },
        Default::default(),
        Default::default(),
        ColorChoice::Always,
    )?;

    match matches.subcommand() {
        Some(("update", _)) => Projects::update(project_directories)?,
        Some(("list", _)) => {
            for project in Projects::list() {
                println!("{}", project.full_name)
            }
        }
        _ => {
            match matches.value_of("project") {
                Some(project) => {
                    let mut projects = Projects::load().unwrap();
                    if let Some(project) = projects.find(project) {
                        println!("{}", project.path.display())
                    }
                }
                None => {
                    app.print_long_help().unwrap();
                }
            }
        }
    }

    Ok(())
}
