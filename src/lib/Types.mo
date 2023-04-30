/// Type declarations for the library.

import UUID "mo:uuid/UUID";

module {
    type UUID = UUID.UUID;

    public type CreateDerivedIdentityResponse = {
        key_name : Text;
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

    public type SignMessageRequest = {
        uuid : UUID;
        key_name : Text;
    };

    public type SignMessageResponse = {};

    public type Result<X> = {
        #Ok : X;
        #Err : Text;
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
};
