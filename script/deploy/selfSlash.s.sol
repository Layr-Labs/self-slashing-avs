// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import { ISelfSlasher } from "src/interfaces/ISelfSlasher.sol";
import "forge-std/Script.sol";
import "forge-std/Test.sol";


contract SelfSlash is Script, Test {
    Vm cheats = Vm(VM_ADDRESS);

    function run() public {
        ISelfSlasher selfSlasher = ISelfSlasher(0x4C12323f00A41CCf8c787AC482552C01b650EFFF);

        vm.startBroadcast();

        selfSlasher.selfSlash(0, 1e17, "test");

        vm.stopBroadcast();
    }
}