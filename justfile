default: run

build:
    cargo build --manifest-path rust/Cargo.toml

gen:
    dart run ffigen --config ffigen.yaml

execute: build gen

run: execute
    dart run
