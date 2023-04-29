/// Stable class adding support for metacalls in Motoko.
///
/// TODO
import Types "Types";
import Principal "mo:base/Principal";
import IcManagement "IcManagement";
import Error "mo:base/Error";
import Blob "mo:base/Blob";
import State "State";
import Nat64 "mo:base/Nat64";
import Buffer "mo:base/Buffer";
import Nat8 "mo:base/Nat8";
import Cycles "mo:base/ExperimentalCycles";
import Array "mo:base/Array";
import { now } = "mo:base/Time";
import Map "mo:stable_hash_map/Map/Map";
import StableBuffer "mo:stable_buffer/StableBuffer";
import Binary "mo:encoding/Binary";
import Text "mo:base/Text";
import Iter "mo:base/Iter";

module {
    type IcManagement = IcManagement.IcManagement;

    type Result<X> = Types.Result<X>;

    type State = State.State;
    type Env = State.Env;

    type Buffer<X> = Buffer.Buffer<X>;
    type Map<K, V> = Map.Map<K, V>;
    let { n64hash } = Map;

    public type MetacallsLib = {
        icManagement : IcManagement;
        state : State;
    };

    /// Initialize the library by providing it with the required actors and environment.
    public func init(
        initIcManagement : IcManagement,
        env : Env,
    ) : MetacallsLib = {
        icManagement = initIcManagement;
        state = State.initState(env);
    };
};
