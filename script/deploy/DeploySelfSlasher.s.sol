// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../../src/SelfSlasherSimple.sol";
import "../../src/SimpleAVSRegistrar.sol";
import {IAVSRegistrar} from "eigenlayer-contracts/src/contracts/interfaces/IAVSRegistrar.sol";

contract DeploySelfSlasher is Script {
    function run() external {
        // Get deployment configuration from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        address allocationManager = vm.envAddress("ALLOCATION_MANAGER");
        address strategy = vm.envAddress("STRATEGY_ADDRESS");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy SelfSlasher
        SelfSlasherSimple selfSlasher = new SelfSlasherSimple(
            IAllocationManager(allocationManager),
            deployerAddress
        );
        
        // Log the deployment address
        console.log("SelfSlasher deployed at:", address(selfSlasher));

        //Deploy the SimpleAVSRegistrar with the deployer as the AVS
        SimpleAVSRegistrar avsRegistrar = new SimpleAVSRegistrar(deployerAddress);
        console.log("SimpleAVSRegistrar deployed at:", address(avsRegistrar));

        // Step 2: Update AVS metadata URI
        console.log("Updating AVS metadata URI...");
        try IAllocationManager(allocationManager).updateAVSMetadataURI(
            deployerAddress, 
            "dummy avs metadata"
        ) {
            console.log("Successfully updated AVS metadata URI");
        } catch {
            console.log("Failed to update AVS metadata URI");
        }
        
        // Step 3: Create operator set
        console.log("Creating operator set...");
        IAllocationManagerTypes.CreateSetParams[] memory createParams = 
            new IAllocationManagerTypes.CreateSetParams[](1);
        
        // Prepare strategy array
        IStrategy[] memory strategies = new IStrategy[](1);
        strategies[0] = IStrategy(strategy);
        
        createParams[0] = IAllocationManagerTypes.CreateSetParams({
            operatorSetId: 0,
            strategies: strategies
        });
        
        IAllocationManager(allocationManager).createOperatorSets(deployerAddress, createParams);
        console.log("Successfully created operator set");

        
        // Step 4: Set AVS Registrar
        console.log("Setting AVS registrar...");
        IAllocationManager(allocationManager).setAVSRegistrar(
            deployerAddress, 
            IAVSRegistrar(avsRegistrar)
        );
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}