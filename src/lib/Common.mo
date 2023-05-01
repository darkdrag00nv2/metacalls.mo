/// Common definitions for the library.
///
/// As a library user, you should rarely have to interact with this module directly.

import Blob "mo:base/Blob";
import Time "mo:base/Time";
import Text "mo:base/Text";
import UUID "mo:uuid/UUID";

module {
    type Time = Time.Time;
    type UUID = UUID.UUID;

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

    public type HttpHeader = {
        name : Text;
        value : Text;
    };

    public type HttpMethod = {
        #get;
        #post;
        #head;
    };

    public type TransformContext = {
        function : shared query TransformArgs -> async CanisterHttpResponsePayload;
        context : Blob;
    };

    public type CanisterHttpRequestArgs = {
        url : Text;
        max_response_bytes : ?Nat64;
        headers : [HttpHeader];
        body : ?[Nat8];
        method : HttpMethod;
        transform : ?TransformContext;
    };

    public type CanisterHttpResponsePayload = {
        status : Nat;
        headers : [HttpHeader];
        body : [Nat8];
    };

    public type TransformArgs = {
        response : CanisterHttpResponsePayload;
        context : Blob;
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
        var response : ?CanisterHttpResponsePayload;
    };

    public type MessageImmutable = {
        uuid : UUID;
        creation_ts : Time;
        original_message : Text;
        hashed_message : [Nat8];
        last_updated_ts : Time;
        signed_message : ?Blob;
        signed_by : ?Text;
        status : MessageStatus;
        response : ?CanisterHttpResponsePayload;
    };
};
