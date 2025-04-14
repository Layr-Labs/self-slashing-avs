// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../../src/SelfSlasher.sol";

contract DeploySelfSlasher is Script {
    function run() external {
        // Get deployment configuration from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address allocationManager = vm.envAddress("ALLOCATION_MANAGER");
        address registryCoordinator = vm.envAddress("REGISTRY_COORDINATOR");
        address slasher = vm.envAddress("SLASHER");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy SelfSlasher
        SelfSlasher selfSlasher = new SelfSlasher(
            IAllocationManager(allocationManager),
            ISlashingRegistryCoordinator(registryCoordinator),
            slasher
        );
        
        // Log the deployment address
        console.log("SelfSlasher deployed at:", address(selfSlasher));
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}