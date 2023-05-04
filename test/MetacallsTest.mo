import C "mo:matchers/Canister";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import S "mo:matchers/Suite";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

import Metacalls "../src/lib/Metacalls";

shared (deployer) actor class MetacallsTestRunner() = this {
    let it = C.Tester({ batchSize = 8 });

    public shared func test() : async { #success; #fail : Text } {
        return #success;
    };
};
