/// Type declarations for the library.

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
        transform : ?Common.TransformContext;
        max_response_bytes : ?Nat64;
    };

    public type SendOutgoingMessageResponse = {
        status : Nat;
        headers : [Common.HttpHeader];
        body : [Nat8];
    };

    public type ListMessagesResponse = {
        messages : [Common.MessageImmutable];
    };

    public type Result<X> = {
        #Ok : X;
        #Err : Text;
    };
};
