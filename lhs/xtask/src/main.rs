use std::{path::PathBuf, process::Command};
use xtask_wasm::{anyhow, clap, default_dist_dir};

const APP_NAME: &'static str = "lhs";
const PACKAGE_NAME: &'static str = "lhs-ui";
const STATIC_CONTENT_PATH: &'static str = "lhs-ui/static";

#[derive(clap::Parser)]
enum Opt {
    Dist(xtask_wasm::Dist),
    Watch(xtask_wasm::Watch),
    Start(xtask_wasm::DevServer),
}

// Cannonicalizes a path, relative to workspace manifest
fn cannonicalize_path(relative_path: &str) -> PathBuf {
    let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    path.pop();
    path.push(relative_path);

    path
}

fn main() -> anyhow::Result<()> {
    let opt: Opt = clap::Parser::parse();
    env_logger::init();

    match opt {
        Opt::Dist(dist) => {
            log::info!("Generating package...");
            let static_content_path = cannonicalize_path(STATIC_CONTENT_PATH);

            dist.app_name(APP_NAME)
                .run_in_workspace(true)
                .static_dir_path(static_content_path)
                .run(PACKAGE_NAME)?;

            Ok(())
        }
        Opt::Watch(watch) => {
            log::info!("Starting watch server...");

            let mut command = Command::new("cargo");
            command.arg("check");

            watch.run(command)
        }
        Opt::Start(server) => {
            log::info!("Starting development server...");

            server.arg("dist").start(default_dist_dir(false))
        }
    }
}
