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
    type CreateDerivedIdentityResponse = Types.CreateDerivedIdentityResponse;

    type Env = State.Env;

    let ic_management : IcManagement = actor ("aaaaa-aa");
    let env : Env = #Local;
    stable let lib = Metacalls.init(ic_management, env);

    /// Create an identity with the provided name.
    ///
    /// The identity is saved in the state and can be used later to sign a transaction.
    public shared (msg) func createDerivedIdentity(key_name : Text) : async Result<CreateDerivedIdentityResponse> {
        return await Metacalls.createDerivedIdentity(lib, key_name);
    };

    public query func healthcheck() : async Bool { true };
};
