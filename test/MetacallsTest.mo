import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";
import S "mo:matchers/Suite";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

import Metacalls "../src/lib/Metacalls";
import IcManagement "../src/lib/IcManagement";
import State "../src/lib/State";

shared (deployer) actor class MetacallsTestRunner() = this {
    let ic_management : IcManagement.IcManagement = actor ("aaaaa-aa");
    let env : State.Env = #Local;
    stable let lib = Metacalls.init(ic_management, env);

    public shared func test() : async { #success; #fail : Text } {
        let suite = S.suite(
            "Test metacalls",
            [
                S.test("10 is 10", 10, M.equals(T.nat(10)))
            ],
        );
        S.run(suite);
        return #success;
    };
};
