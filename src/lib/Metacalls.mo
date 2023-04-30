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
import Source "mo:uuid/async/SourceV4";
import Time "mo:base/Time";

module {
    type IcManagement = IcManagement.IcManagement;
    type Time = Time.Time;

    type Result<X> = Types.Result<X>;
    type CreateDerivedIdentityResponse = Types.CreateDerivedIdentityResponse;
    type CreateMessageRequest = Types.CreateMessageRequest;
    type CreateMessageResponse = Types.CreateMessageResponse;

    type State = State.State;
    type Env = State.Env;
    type Message = State.Message;

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

    /// Create a derived identity for the provided principal.
    ///
    /// The identity is saved in the state and can be used later to sign a transaction.
    public func createDerivedIdentity(
        lib : MetacallsLib,
        key_name : Text,
    ) : async Result<CreateDerivedIdentityResponse> {
        try {
            let { public_key } = await lib.icManagement.ecdsa_public_key({
                canister_id = null;
                derivation_path = [Text.encodeUtf8(key_name)];
                key_id = {
                    curve = #secp256k1;
                    name = lib.state.config.key_name;
                };
            });

            State.addDerivedIdentity(lib.state, key_name, public_key);
            #Ok({ key_name = key_name });
        } catch (err) {
            #Err(Error.message(err));
        };
    };

    public func createMessage(
        lib : MetacallsLib,
        req : CreateMessageRequest,
    ) : async Result<CreateMessageResponse> {
        let id = await Source.Source().new();
        let ts = Time.now();

        let message : Message = {
            uuid = id;
            creation_ts = ts;
            last_updated_ts = ts;
            original_message = req.msg;
            status = #Created;
        };
        State.addMessage(lib.state, id, message);

        #Ok({ uuid = id });
    };
};
