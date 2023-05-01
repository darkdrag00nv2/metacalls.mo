/// Stable class adding support for metacalls in Motoko.
///
/// TODO
import Types "Types";
import Common "Common";
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
import Set "mo:stable_hash_map/Set/Set";
import Nat "mo:base/Nat";

module {
    type IcManagement = IcManagement.IcManagement;
    type Time = Time.Time;

    type Result<X> = Types.Result<X>;
    type CreateDerivedIdentityResponse = Types.CreateDerivedIdentityResponse;
    type ListDerivedIdentitiesResponse = Types.ListDerivedIdentitiesResponse;
    type CreateMessageRequest = Types.CreateMessageRequest;
    type CreateMessageResponse = Types.CreateMessageResponse;
    type SignMessageRequest = Types.SignMessageRequest;
    type SignMessageResponse = Types.SignMessageResponse;
    type SendOutgoingMessageRequest = Types.SendOutgoingMessageRequest;
    type SendOutgoingMessageResponse = Types.SendOutgoingMessageResponse;
    type ListMessagesResponse = Types.ListMessagesResponse;
    type CleanupExpiredMessagesResponse = Types.CleanupExpiredMessagesResponse;

    type State = State.State;
    type Env = State.Env;
    type Message = Common.Message;
    type MessageImmutable = Common.MessageImmutable;

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

    public func listDerivedIdentities(
        lib : MetacallsLib
    ) : async Result<ListDerivedIdentitiesResponse> {
        let identities = State.getAllDerivedIdentities(lib.state);
        #Ok({ identities = identities });
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
            original_message = req.msg;
            hashed_message = Sha256.sha256(Blob.toArray(Text.encodeUtf8(req.msg)));
            var last_updated_ts = ts;
            var signed_message = null;
            var signed_by = null;
            var status = #Created;
            var response = null;
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
        msg.last_updated_ts := Time.now();
        State.setMessage(lib.state, req.uuid, msg);

        #Ok({});
    };

    public func sendOutgoingMessage(
        lib : MetacallsLib,
        req : SendOutgoingMessageRequest,
    ) : async Result<SendOutgoingMessageResponse> {
        let ?msg = State.getMessage(lib.state, req.msg_uuid) else {
            return #Err("The message with the given uuid does not exist");
        };
        if (msg.status != #Signed) {
            return #Err("Only signed messages can be sent");
        };
        let ?signed_msg = msg.signed_message else {
            return #Err("Inconsistent state. status = #Signed but signed_message = null");
        };

        let request : Common.CanisterHttpRequestArgs = {
            url = req.url;
            max_response_bytes = req.max_response_bytes;
            headers = req.headers;
            body = ?Blob.toArray(signed_msg);
            method = req.method;
            transform = req.transform;
        };

        try {
            Cycles.add(lib.state.config.sign_cycles);
            let response = await lib.icManagement.http_request(request);

            let sendOutgoingMessageResponse : SendOutgoingMessageResponse = {
                headers = response.headers;
                status = response.status;
                body = response.body;
            };

            msg.status := #Sent;
            msg.last_updated_ts := Time.now();
            msg.response := ?response;
            State.setMessage(lib.state, req.msg_uuid, msg);

            #Ok(sendOutgoingMessageResponse);
        } catch (err) {
            #Err(Error.message(err));
        };
    };

    public func listMessages(
        lib : MetacallsLib
    ) : async Result<ListMessagesResponse> {
        let msgs = State.getAllMessages(lib.state);

        let res = Buffer.Buffer<MessageImmutable>(0);
        for (msg in Array.vals(msgs)) {
            res.add({
                uuid = msg.uuid;
                creation_ts = msg.creation_ts;
                original_message = msg.original_message;
                hashed_message = msg.hashed_message;
                last_updated_ts = msg.last_updated_ts;
                signed_message = msg.signed_message;
                signed_by = msg.signed_by;
                status = msg.status;
                response = msg.response;
            });
        };

        #Ok({ messages = Buffer.toArray(res) });
    };

    public func updateMessageTtl(lib : MetacallsLib, new_ttl_secs : Int) : async Result<()> {
        State.updateMessageTtl(lib.state, new_ttl_secs);
        #Ok(());
    };

    public func cleanupExpiredMessages(lib : MetacallsLib) : async Result<CleanupExpiredMessagesResponse> {
        let expired_msg_uuids = State.cleanupExpiredMessages(lib.state);
        #Ok({ expired_msg_uuids = expired_msg_uuids });
    };
};
