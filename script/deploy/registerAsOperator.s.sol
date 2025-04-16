// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import {IDelegationManager} from
    "eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";

// use cast:
// cast send <DELEGATION_MANAGER_ADDRESS> "registerAsOperator((address,address,uint32),uint256,string)" \
// "(address(0), <OPERATOR_ADDRESS>, 0)" \
// 0 \
// "<METADATA_URI>" \
// --private-key <YOUR_PRIVATE_KEY>

// use forge:
// RUST_LOG=forge,foundry=trace forge script script/tasks/register_as_operator.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "run(string memory configFile,address operator,string memory metadataURI)" -- <DEPLOYMENT_OUTPUT_JSON> <OPERATOR_ADDRESS> <METADATA_URI>
// RUST_LOG=forge,foundry=trace forge script script/tasks/register_as_operator.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --sig "run(string memory configFile,address operator,string metadataURI)" -- local/slashing_output.json 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 "test"
contract RegisterAsOperator is Script, Test {
    Vm cheats = Vm(VM_ADDRESS);

    function run() public {
        // Load config
        // string memory deployConfigPath = string(bytes(string.concat("script/output/", configFile)));
        // string memory config_data = vm.readFile(deployConfigPath);

        // Pull delegation manager address
        address operator = 0xBB37b72F67A410B76Ce9b9aF9e37aa561B1C5B07;
        address delegationManager = 0xA44151489861Fe9e3055d95adC98FbD462B948e7;
        string memory metadataURI = "test";

        // START RECORDING TRANSACTIONS FOR DEPLOYMENT
        vm.startBroadcast();
        
        // Attach the delegationManager
        IDelegationManager delegation = IDelegationManager(delegationManager);

        // Register the sender as an Operator
        delegation.registerAsOperator(operator, 0, metadataURI);
        
        // STOP RECORDING TRANSACTIONS FOR DEPLOYMENT
        vm.stopBroadcast();
    }
}