import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import S "mo:matchers/Suite";
import Debug "mo:base/Debug";
import Blob "mo:base/Blob";
import Result "mo:base/Result";
import Principal "mo:base/Principal";

import Metacalls "../src/lib/Metacalls";
import IcManagement "../src/lib/IcManagement";
import State "../src/lib/State";
import Types "../src/lib/Types";
import Common "../src/lib/Common";

module {
    type Testable<V> = T.Testable<V>;
    type TestableItem<V> = T.TestableItem<V>;

    type Result<A> = Types.Result<A>;
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

    type PIdentity = Common.PIdentity;

    public func resultTestable<R>(
        rTestable : Testable<R>
    ) : Testable<Result<R>> = {
        display = func(r : Result<R>) : Text = switch r {
            case (#ok(ok)) {
                "#ok(" # rTestable.display(ok) # ")";
            };
            case (#err(err)) {
                "#err(" # T.textTestable.display(err) # ")";
            };
        };
        equals = func(r1 : Result<R>, r2 : Result<R>) : Bool = switch (r1, r2) {
            case (#ok(ok1), #ok(ok2)) {
                rTestable.equals(ok1, ok2);
            };
            case (#err(err1), #err(err2)) {
                T.textTestable.equals(err1, err2);
            };
            case (_) { false };
        };
    };

    public func result<R>(
        rTestable : Testable<R>,
        x : Result<R>,
    ) : TestableItem<Result<R>> {
        let resTestable = resultTestable(rTestable);
        {
            display = resTestable.display;
            equals = resTestable.equals;
            item = x;
        };
    };

    public let testableCreateDerivedIdentityResponse : Testable<CreateDerivedIdentityResponse> = {
        display = func(resp : CreateDerivedIdentityResponse) : Text = resp.key_name;
        equals = func(
            resp1 : CreateDerivedIdentityResponse,
            resp2 : CreateDerivedIdentityResponse,
        ) : Bool = resp1.key_name == resp2.key_name;
    };

    public let testableListDerivedIdentitiesResponse : Testable<ListDerivedIdentitiesResponse> = {
        display = func(resp : ListDerivedIdentitiesResponse) : Text = T.arrayTestable(testablePIdentity).display(resp.identities);
        equals = func(
            resp1 : ListDerivedIdentitiesResponse,
            resp2 : ListDerivedIdentitiesResponse,
        ) : Bool = T.arrayTestable(testablePIdentity).equals(resp1.identities, resp2.identities);
    };

    private let testablePIdentity : Testable<PIdentity> = {
        display = func(resp : PIdentity) : Text = "key_name = " # resp.key_name # ",";
        equals = func(
            resp1 : PIdentity,
            resp2 : PIdentity,
        ) : Bool = resp1.key_name == resp2.key_name;
    };
};
