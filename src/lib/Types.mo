/// Type declarations for the library.

import Result "mo:base/Result";
import UUID "mo:uuid/UUID";
import Common "Common";

module {
    type UUID = UUID.UUID;
    type PIdentity = Common.PIdentity;

    public type CreateDerivedIdentityResponse = {
        key_name : Text;
    };

    public type ListDerivedIdentitiesResponse = {
        identities : [PIdentity];
    };

    /// The request to create a message with given body which can be later signed and sent via `http_request`.
    public type CreateMessageRequest = {
        msg : Text;
    };

    /// The response to the createMessage call.
    ///
    /// Contains the uuid of the stored message which can be used as an identifier for future requests.
    public type CreateMessageResponse = {
        uuid : UUID;
    };

    /// The request to sign a message identified by the uuid and to be signed by an earlier generated key.
    public type SignMessageRequest = {
        uuid : UUID;
        key_name : Text;
    };

    public type SignMessageResponse = {};

    public type SendOutgoingMessageRequest = {
        msg_uuid : UUID;
        url : Text;
        headers : [Common.HttpHeader];
        method : Common.HttpMethod;
        /// This is useful when number of replicas > 1.
        /// Each replica sends the http request to the target.
        /// If the response received from the service can be different (say because of timestamp),
        /// this transformation function can be used to ignore the fields that don't matter.
        transform : ?Common.TransformContext;
        /// Set this to a reasonable value to avoid huge costs. 
        /// The default is 2MB which can be very expensive.
        max_response_bytes : ?Nat64;
    };

    public type SendOutgoingMessageResponse = {
        status : Nat;
        headers : [Common.HttpHeader];
        /// The response body sent by the target service.
        /// Consider using a json library like NatLabs/serde to parse into a static type.
        body : [Nat8];
    };

    public type ListMessagesResponse = {
        messages : [Common.MessageImmutable];
    };

    public type CleanupExpiredMessagesResponse = {
        expired_msg_uuids : [UUID];
    };

    public type Result<X> = Result.Result<X, Text>;
};
