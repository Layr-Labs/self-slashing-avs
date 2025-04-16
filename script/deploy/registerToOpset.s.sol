// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import {
    IAllocationManager,
    IAllocationManagerTypes
} from "eigenlayer-contracts/src/contracts/interfaces/IAllocationManager.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";

// use forge:
// RUST_LOG=forge,foundry=trace forge script script/tasks/register_operator_to_operatorSet.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "run(string memory configFile)" -- <DEPLOYMENT_OUTPUT_JSON>
// RUST_LOG=forge,foundry=trace forge script script/tasks/register_operator_to_operatorSet.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "run(string memory configFile)" -- local/slashing_output.json
contract RegisterOperatorToOperatorSets is Script, Test {
    Vm cheats = Vm(VM_ADDRESS);

    function run() public {

        address avs = 0xF267bDB5361c1d356b74785bcC8E1792d52CF732;
        IAllocationManager allocationManager = IAllocationManager(0x78469728304326CBc65f8f95FA756B0B73164462);
        address operator = 0xBB37b72F67A410B76Ce9b9aF9e37aa561B1C5B07;
        uint32[] memory oids = new uint32[](1);
        oids[0] = 0;

        vm.startBroadcast();

        // Register OperatorSet(s)
        IAllocationManagerTypes.RegisterParams memory registerParams = IAllocationManagerTypes.RegisterParams({
            avs: avs,
            operatorSetIds: oids,
            data: ""
        });
        allocationManager.registerForOperatorSets(operator, registerParams);

        // STOP RECORDING TRANSACTIONS FOR DEPLOYMENT
        vm.stopBroadcast();
    }
}