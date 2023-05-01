/// Common definitions for the library.
///
/// As a library user, you should rarely have to interact with this module directly.

import Blob "mo:base/Blob";
import Time "mo:base/Time";
import Text "mo:base/Text";

module {
    type Time = Time.Time;

    public type PIdentity = {
        key_name : Text;
        creation_ts : Time;
        public_key : Blob;
    };
};
