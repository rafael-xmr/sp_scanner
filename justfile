build:
    cargo build --manifest-path rust-silentpayments/Cargo.toml

gen:
    dart run ffigen

execute: build-rust generate
