default: execute

build:
    cargo build --manifest-path rust-silentpayments/Cargo.toml

gen:
    dart run ffigen

execute: build gen

run: execute
    dart run
