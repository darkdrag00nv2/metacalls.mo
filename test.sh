#!/usr/bin/env bash

dfx stop
dfx start --background --clean

echo "Installing canisters..."

dfx canister create --all
dfx build --all
dfx canister install metacalls_test --mode=reinstall --yes --upgrade-unchanged

echo "Running tests..."

dfx canister call metacalls_test test

sleep 5
dfx canister call metacalls_test testCleanupSuccess

dfx stop
