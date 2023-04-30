/// State stored by the library.
///
/// As a library user, you should rarely have to interact with this module directly.

import Map "mo:stable_hash_map/Map/Map";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import StableBuffer "mo:stable_buffer/StableBuffer";
import Time "mo:base/Time";
import UUID "mo:uuid/UUID";
import Text "mo:base/Text";
import Types "Types";

module {
    type Map<K, V> = Map.Map<K, V>;
    type StableBuffer<X> = StableBuffer.StableBuffer<X>;
    type Time = Time.Time;
    type UUID = UUID.UUID;

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
    };

    public type PIdentity = {
        key_name : Text;
        creation_ts : Time;
        public_key : Blob;
    };

    public type MessageStatus = {
        #Created;
        #Signed;
        #Sent;
    };

    public type Message = {
        uuid : UUID;
        creation_ts : Time;
        original_message : Text;
        hashed_message : [Nat8];
        var last_updated_ts : Time;
        var signed_message : ?Blob;
        var signed_by : ?Text;
        var status : MessageStatus;
        var response : ?SendOutgoingMessageResponse;
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
                };
            };
            case (#Staging) {
                {
                    env = env;
                    key_name = "test_key_1";
                    sign_cycles = 10_000_000_000;
                };
            };
            case (#Production) {
                {
                    env = env;
                    key_name = "key_1";
                    sign_cycles = 26_153_846_153;
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

    public func setMessage(s : State, uuid : UUID, msg : Message) {
        Map.set(s.messages, thash, UUID.toText(uuid), msg);
    };

    public func getMessage(s : State, uuid : UUID) : ?Message {
        Map.get(s.messages, thash, UUID.toText(uuid));
    };
};
