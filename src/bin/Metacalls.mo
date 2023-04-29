/// An actor exposing the Metacalls library functionalities.
///
/// This also serves as a reference implementation of the usage of the library.

import Principal "mo:base/Principal";
import Nat64 "mo:base/Nat64";
import Nat "mo:base/Nat";

import IcManagement "../lib/IcManagement";
import MetacallsLib "../lib/Metacalls";
import Types "../lib/Types";
import State "../lib/State";
import Metacalls "../lib/Metacalls";

actor NoKeyWallet {
    type IcManagement = IcManagement.IcManagement;

    type Result<X> = Types.Result<X>;

    type Env = State.Env;

    let ic_management : IcManagement = actor ("aaaaa-aa");
    let env : Env = #Local;
    stable let lib = Metacalls.init(ic_management, env);

    public query func healthcheck() : async Bool { true };
};
