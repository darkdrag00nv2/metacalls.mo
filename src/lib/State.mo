/// State stored by the library.
///
/// As a library user, you should rarely have to interact with this module directly.

import Map "mo:stable_hash_map/Map/Map";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import StableBuffer "mo:stable_buffer/StableBuffer";
import Time "mo:base/Time";

module {
    type Map<K, V> = Map.Map<K, V>;
    type StableBuffer<X> = StableBuffer.StableBuffer<X>;
    type Time = Time.Time;

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

    public type State = {
        config : Config;
        var identities : Map<Text, PIdentity>;
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
        };
    };

    public func addDerivedIdentity(s : State, key_name : Text, pub_key : Blob) {
        let pident = get_pidentity(key_name, pub_key);
        ignore Map.put(s.identities, thash, key_name, pident);
    };

    private func get_pidentity(key_name : Text, pub_key : Blob) : PIdentity {
        {
            key_name = key_name;
            creation_ts = Time.now();
            public_key = pub_key;
        };
    };
};
