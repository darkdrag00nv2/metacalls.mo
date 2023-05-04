#!/usr/bin/env bash

dfx stop
dfx start --background --clean

echo "Installing canisters..."

dfx canister create --all
dfx build --all
dfx canister install metacalls_test --mode=reinstall

echo "Running tests..."

dfx canister call metacalls_test test
