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
import Sha256 "mo:motoko-sha/SHA256";

module {
    type IcManagement = IcManagement.IcManagement;
    type Time = Time.Time;

    type Result<X> = Types.Result<X>;
    type CreateDerivedIdentityResponse = Types.CreateDerivedIdentityResponse;
    type CreateMessageRequest = Types.CreateMessageRequest;
    type CreateMessageResponse = Types.CreateMessageResponse;
    type SignMessageRequest = Types.SignMessageRequest;
    type SignMessageResponse = Types.SignMessageResponse;

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

    /// Create a message which can be signed and sent later.
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
            hashed_message = Sha256.sha256(Blob.toArray(Text.encodeUtf8(req.msg)));
            var signed_message = null;
            var signed_by = null;
            var status = #Created;
        };
        State.setMessage(lib.state, id, message);

        #Ok({ uuid = id });
    };

    public func signMessage(
        lib : MetacallsLib,
        req : SignMessageRequest,
    ) : async Result<SignMessageResponse> {
        let ?msg = State.getMessage(lib.state, req.uuid) else {
            return #Err("The message with the given uuid does not exist");
        };
        let ?identity = State.getDerivedIdentity(lib.state, req.key_name) else {
            return #Err("The key with the given name does not exist");
        };

        Cycles.add(lib.state.config.sign_cycles);
        let { signature } = await lib.icManagement.sign_with_ecdsa({
            message_hash = Blob.fromArray(msg.hashed_message);
            derivation_path = [Text.encodeUtf8(req.key_name)];
            key_id = {
                curve = #secp256k1;
                name = lib.state.config.key_name;
            };
        });

        msg.signed_message := ?signature;
        msg.signed_by := ?req.key_name;
        msg.status := #Signed;
        State.setMessage(lib.state, req.uuid, msg);

        #Ok({});
    };
};
