/// State stored by the library.
///
/// As a library user, you should rarely have to interact with this module directly.

import Map "mo:stable_hash_map/Map/Map";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import StableBuffer "mo:stable_buffer/StableBuffer";
import Time "mo:base/Time";
import UUID "mo:uuid/UUID";
import Text "mo:base/Text";
import Types "Types";
import Buffer "mo:base/Buffer";
import Common "Common";

module {
    type Buffer<X> = Buffer.Buffer<X>;
    type Map<K, V> = Map.Map<K, V>;
    type StableBuffer<X> = StableBuffer.StableBuffer<X>;
    type Time = Time.Time;
    type UUID = UUID.UUID;
    type PIdentity = Common.PIdentity;
    type Message = Common.Message;

    type SendOutgoingMessageResponse = Types.SendOutgoingMessageResponse;

    let { thash } = Map;

    public type Env = {
        #Local;
        #Staging;
        #Production;
    };

    public type Config = {
        env : Env;
        key_name : Text;
        sign_cycles : Nat;
        var message_ttl_secs : Int;
    };

    public type MessageStatus = {
        #Created;
        #Signed;
        #Sent;
    };

    public type State = {
        config : Config;
        var identities : Map<Text, PIdentity>;
        var messages : Map<Text, Message>;
    };

    public func initState(env : Env) : State {
        let config : Config = switch (env) {
            case (#Local) {
                {
                    env = env;
                    key_name = "dfx_test_key";
                    sign_cycles = 0;
                    var message_ttl_secs = 3600;
                };
            };
            case (#Staging) {
                {
                    env = env;
                    key_name = "test_key_1";
                    sign_cycles = 10_000_000_000;
                    var message_ttl_secs = 3600;
                };
            };
            case (#Production) {
                {
                    env = env;
                    key_name = "key_1";
                    sign_cycles = 26_153_846_153;
                    var message_ttl_secs = 3600;
                };
            };
        };

        {
            config = config;
            var identities = Map.new<Text, PIdentity>(thash);
            var messages = Map.new<Text, Message>(thash);
        };
    };

    public func addDerivedIdentity(s : State, key_name : Text, pub_key : Blob) {
        let pident = get_pidentity(key_name, pub_key);
        Map.set(s.identities, thash, key_name, pident);
    };

    private func get_pidentity(key_name : Text, pub_key : Blob) : PIdentity {
        {
            key_name = key_name;
            creation_ts = Time.now();
            public_key = pub_key;
        };
    };

    public func getDerivedIdentity(s : State, key_name : Text) : ?PIdentity {
        Map.get(s.identities, thash, key_name);
    };

    public func getAllDerivedIdentities(s : State) : [PIdentity] {
        let res = Buffer.Buffer<PIdentity>(0);
        for (identities in Map.vals(s.identities)) {
            res.add(identities);
        };
        Buffer.toArray(res);
    };

    public func setMessage(s : State, uuid : UUID, msg : Message) {
        Map.set(s.messages, thash, UUID.toText(uuid), msg);
    };

    public func getMessage(s : State, uuid : UUID) : ?Message {
        Map.get(s.messages, thash, UUID.toText(uuid));
    };

    public func getAllMessages(s : State) : [Message] {
        let res = Buffer.Buffer<Message>(0);
        for (msg in Map.vals(s.messages)) {
            res.add(msg);
        };
        Buffer.toArray(res);
    };

    public func updateMessageTtl(s : State, new_ttl_secs : Int) {
        s.config.message_ttl_secs := new_ttl_secs;
    };

    public func cleanupExpiredMessages(s : State) : [UUID] {
        let now = Time.now();

        let expired_msg_ids = Buffer.Buffer<UUID>(0);
        for (msg in Map.vals(s.messages)) {
            let elapsedSeconds = (now - msg.creation_ts) / 1000_000_000;
            if (elapsedSeconds >= s.config.message_ttl_secs) {
                expired_msg_ids.add(msg.uuid);
            };
        };

        for (id in expired_msg_ids.vals()) {
            Map.delete(s.messages, thash, UUID.toText(id));
        };

        Buffer.toArray(expired_msg_ids);
    };
};
