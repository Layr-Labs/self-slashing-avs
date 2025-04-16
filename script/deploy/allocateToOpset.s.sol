// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import {
    IAllocationManager,
    IAllocationManagerTypes
} from "eigenlayer-contracts/src/contracts/interfaces/IAllocationManager.sol";
import {IStrategy} from "eigenlayer-contracts/src/contracts/interfaces/IStrategy.sol";
import {OperatorSet} from "eigenlayer-contracts/src/contracts/interfaces/IAllocationManager.sol";


import "forge-std/Script.sol";
import "forge-std/Test.sol";

// use forge:
// RUST_LOG=forge,foundry=trace forge script script/tasks/allocate_operatorSet.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "run(string memory configFile,address strategy,address avs,uint32 operatorSetId,uint64 magnitude)" -- <DEPLOYMENT_OUTPUT_JSON> <STRATEGY_ADDRESS> <AVS_ADDRESS> <OPERATOR_SET_ID> <MAGNITUDE>
// RUST_LOG=forge,foundry=trace forge script script/tasks/allocate_operatorSet.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "run(string memory configFile,address strategy,address avs,uint32 operatorSetId,uint64 magnitude)" -- local/slashing_output.json 0x8aCd85898458400f7Db866d53FCFF6f0D49741FF 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 00000001 0500000000000000000
contract AllocateOperatorSet is Script, Test {
    Vm cheats = Vm(VM_ADDRESS);

    function run() public {
        // Load config
        address avs = 0xF267bDB5361c1d356b74785bcC8E1792d52CF732;
        IAllocationManager allocationManager = IAllocationManager(0x78469728304326CBc65f8f95FA756B0B73164462);
        address operator = 0xBB37b72F67A410B76Ce9b9aF9e37aa561B1C5B07;
        uint32 operatorSetId = 0;
        uint64 magnitude = 1e18;
        address strategy = 0x80528D6e9A2BAbFc766965E0E26d5aB08D9CFaF9; // weth strategy

        // START RECORDING TRANSACTIONS FOR DEPLOYMENT
        vm.startBroadcast();

        // Attach to the AllocationManager
        IAllocationManager am = IAllocationManager(allocationManager);

        // Correct array initialization
        IStrategy[] memory strategies = new IStrategy[](1);
        strategies[0] = IStrategy(strategy);

        // Set OperatorSets
        OperatorSet[] memory sets = new OperatorSet[](1);
        sets[0] = OperatorSet({
            avs: avs,
            id: operatorSetId
        });

        // Set new mangitudes
        uint64[] memory magnitudes = new uint64[](1);
        magnitudes[0] = magnitude;

        // Define a single MagnitudeAllocation and wrap it in an array
        IAllocationManagerTypes.AllocateParams[] memory allocations = new IAllocationManagerTypes.AllocateParams[](1);
        allocations[0] = IAllocationManagerTypes.AllocateParams({
            operatorSet: sets[0],
            strategies: strategies,
            newMagnitudes: magnitudes
        });

        // Perform allocation
        am.modifyAllocations(msg.sender, allocations);
        
        // STOP RECORDING TRANSACTIONS FOR DEPLOYMENT
        vm.stopBroadcast();
    }
}