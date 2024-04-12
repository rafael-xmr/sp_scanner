default: run

build:
    cargo build --manifest-path rust/Cargo.toml

gen:
    dart run ffigen

execute: build gen

run: execute
    dart run
