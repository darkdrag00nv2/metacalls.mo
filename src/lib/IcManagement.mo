/// The IC Management Canister interface used by the library.
///
/// Used by the library for creating public keys, signing messages and outgoing calls.

import Common "../lib/Common";

module {
    public type IcManagement = actor {
        ecdsa_public_key : ({
            canister_id : ?Principal;
            derivation_path : [Blob];
            key_id : { curve : { #secp256k1 }; name : Text };
        }) -> async ({ public_key : Blob; chain_code : Blob });

        sign_with_ecdsa : ({
            message_hash : Blob;
            derivation_path : [Blob];
            key_id : { curve : { #secp256k1 }; name : Text };
        }) -> async ({ signature : Blob });

        http_request : Common.CanisterHttpRequestArgs -> async Common.CanisterHttpResponsePayload;
    };
};
