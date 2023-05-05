import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import S "mo:matchers/Suite";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Blob "mo:base/Blob";

import Metacalls "../src/lib/Metacalls";
import IcManagement "../src/lib/IcManagement";
import State "../src/lib/State";
import Types "../src/lib/Types";

import TestUtils "TestUtils";
import Array "mo:base/Array";

shared (deployer) actor class MetacallsTestRunner() = this {
    type Testable<V> = T.Testable<V>;

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

    let ic_management : IcManagement.IcManagement = actor ("aaaaa-aa");
    let env : State.Env = #Local;
    stable let lib = Metacalls.init(ic_management, env);

    public shared func test() : async { #success; #fail : Text } {
        let suite = S.suite(
            "Test metacalls",
            [
                S.test(
                    "testCreateAndListDerivedIdentity",
                    switch (await testCreateAndListDerivedIdentity()) {
                        case (#success) { true };
                        case (_) { false };
                    },
                    M.equals<Bool>(T.bool(true)),
                ),
                S.test(
                    "testCreateListAndSignMessage",
                    switch (await testCreateListAndSignMessage()) {
                        case (#success) { true };
                        case (_) { false };
                    },
                    M.equals<Bool>(T.bool(true)),
                ),
            ],
        );
        S.run(suite);
        return #success;
    };

    private func testCreateAndListDerivedIdentity() : async {
        #success;
        #fail : Text;
    } {
        Debug.print("testing CreateAndListDerivedIdentity");

        let suite = S.suite(
            "identity_creation_and_list_basic",
            [
                S.test(
                    "createDerivedIdentity success",
                    await Metacalls.createDerivedIdentity(lib, "test_key_1"),
                    M.equals<Result<CreateDerivedIdentityResponse>>(
                        TestUtils.result<CreateDerivedIdentityResponse>(
                            TestUtils.testableCreateDerivedIdentityResponse,
                            #ok({ key_name = "test_key_1" }),
                        )
                    ),
                ),
                S.test(
                    "listDerivedIdentity success",
                    await Metacalls.listDerivedIdentities(lib),
                    M.equals<Result<ListDerivedIdentitiesResponse>>(
                        TestUtils.result<ListDerivedIdentitiesResponse>(
                            TestUtils.testableListDerivedIdentitiesResponse,
                            #ok({
                                identities = [{
                                    key_name = "test_key_1";
                                    creation_ts = Time.now();
                                    public_key = Blob.fromArray([]);
                                }];
                            }),
                        )
                    ),
                ),
            ],
        );

        S.run(suite);
        return #success;
    };

    private func testCreateListAndSignMessage() : async {
        #success;
        #fail : Text;
    } {
        Debug.print("testing CreateListAndSignMessage");

        let identity = await Metacalls.createDerivedIdentity(lib, "test_key_1");

        // Create Message.
        let message_response = await Metacalls.createMessage(lib, { msg = "RequestMessage" });
        let #ok(msg) = message_response else {
            return #fail("Unexpected failure in createMessage");
        };
        assert (Array.size(msg.uuid) > 0);

        // List Message.
        let list_message_response = await Metacalls.listMessages(lib);
        let #ok(list_msg) = list_message_response else {
            return #fail("Unexpected failure in listMessages");
        };
        assert (Array.size(list_msg.messages) == 1);
        assert (list_msg.messages[0].uuid == msg.uuid);
        assert (list_msg.messages[0].original_message == "RequestMessage");
        assert (list_msg.messages[0].status == #Created);
        assert (list_msg.messages[0].signed_message == null);
        assert (list_msg.messages[0].signed_by == null);
        assert (list_msg.messages[0].response == null);

        // Sign Message.
        let sign_message_response = await Metacalls.signMessage(
            lib,
            {
                uuid = msg.uuid;
                key_name = "test_key_1";
            },
        );
        let #ok(signed_msg) = sign_message_response else {
            return #fail("Unexpected failure in signMessage");
        };

        // List Message.
        let list_message_response_2 = await Metacalls.listMessages(lib);
        let #ok(list_msg_2) = list_message_response_2 else {
            return #fail("Unexpected failure in listMessages");
        };
        assert (Array.size(list_msg_2.messages) == 1);
        assert (list_msg_2.messages[0].uuid == msg.uuid);
        assert (list_msg_2.messages[0].original_message == "RequestMessage");
        assert (list_msg_2.messages[0].status == #Signed);
        assert (list_msg_2.messages[0].signed_message != null);
        assert (list_msg_2.messages[0].signed_by != null);
        assert (list_msg_2.messages[0].response == null);

        return #success;
    };
};
