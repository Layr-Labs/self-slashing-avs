// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import "forge-std/Script.sol";
import "../../src/SelfSlasher.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SelfSlasher} from "../../src/SelfSlasher.sol";
import {
    IAllocationManager,
    IAllocationManagerTypes
} from "eigenlayer-contracts/src/contracts/interfaces/IAllocationManager.sol";
import {IAVSRegistrar} from "eigenlayer-contracts/src/contracts/interfaces/IAVSRegistrar.sol";
import {IAVSDirectory} from "eigenlayer-contracts/src/contracts/interfaces/IAVSDirectory.sol";
import {IRegistryCoordinator} from "eigenlayer-middleware/src/interfaces/IRegistryCoordinator.sol";
import {IStrategy} from "eigenlayer-contracts/src/contracts/interfaces/IStrategy.sol";
import {IPermissionController} from
    "eigenlayer-contracts/src/contracts/interfaces/IPermissionController.sol";
import {ISlasher, ISlasherTypes, ISlasherErrors} from "eigenlayer-middleware/src/interfaces/ISlasher.sol";
import {ISlashingRegistryCoordinator} from "eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";
import {IStakeRegistry, IStakeRegistryTypes} from "eigenlayer-middleware/src/interfaces/IStakeRegistry.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from
    "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {EmptyContract} from "eigenlayer-contracts/src/test/mocks/EmptyContract.sol";
import {AllocationManager} from "eigenlayer-contracts/src/contracts/core/AllocationManager.sol";
import {PermissionController} from
    "eigenlayer-contracts/src/contracts/permissions/PermissionController.sol";
import {PauserRegistry} from "eigenlayer-contracts/src/contracts/permissions/PauserRegistry.sol";
import {IPauserRegistry} from "eigenlayer-contracts/src/contracts/interfaces/IPauserRegistry.sol";
import {IDelegationManager} from
    "eigenlayer-contracts/src/contracts/interfaces/IDelegationManager.sol";
import {IStrategyManager} from "eigenlayer-contracts/src/contracts/interfaces/IStrategyManager.sol";
import {DelegationMock} from "eigenlayer-middleware/test/mocks/DelegationMock.sol";
import {SlashingRegistryCoordinator} from "eigenlayer-middleware/src/SlashingRegistryCoordinator.sol";
import {ISlashingRegistryCoordinatorTypes} from
    "eigenlayer-middleware/src/interfaces/ISlashingRegistryCoordinator.sol";
import {IBLSApkRegistry, IBLSApkRegistryTypes} from "eigenlayer-middleware/src/interfaces/IBLSApkRegistry.sol";
import {IIndexRegistry} from "eigenlayer-middleware/src/interfaces/IIndexRegistry.sol";
import {ISocketRegistry} from "eigenlayer-middleware/src/interfaces/ISocketRegistry.sol";
import {CoreDeployLib} from "eigenlayer-middleware/test/utils/CoreDeployLib.sol";
import {
    OperatorWalletLib,
    Operator,
    Wallet,
    BLSWallet,
    SigningKeyOperationsLib
} from "eigenlayer-middleware/test/utils/OperatorWalletLib.sol";
import {OperatorSet} from "eigenlayer-contracts/src/contracts/interfaces/IAllocationManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {StrategyFactory} from "eigenlayer-contracts/src/contracts/strategies/StrategyFactory.sol";
import {StakeRegistry} from "eigenlayer-middleware/src/StakeRegistry.sol";
import {BLSApkRegistry} from "eigenlayer-middleware/src/BLSApkRegistry.sol";
import {IndexRegistry} from "eigenlayer-middleware/src/IndexRegistry.sol";
import {SocketRegistry} from "eigenlayer-middleware/src/SocketRegistry.sol";
import {MiddlewareDeployLib} from "eigenlayer-middleware/test/utils/MiddlewareDeployLib.sol";

contract DeploySelfSlasher is Script {
    address public pauser = address(uint160(uint256(keccak256("pauser"))));
    address public unpauser = address(uint160(uint256(keccak256("unpauser"))));
    address public churnApprover = address(uint160(uint256(keccak256("churnApprover"))));
    address public ejector = address(uint160(uint256(keccak256("ejector"))));

    function run() external {
        // Get deployment configuration from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);
        address allocationManager = vm.envAddress("ALLOCATION_MANAGER");
        address avsDirectory = vm.envAddress("AVS_DIRECTORY");
        address delegationManager = vm.envAddress("DELEGATION_MANAGER");
        address strategy = vm.envAddress("STRATEGY_ADDRESS");


        address[] memory pausers = new address[](1);
        pausers[0] = pauser;
        PauserRegistry pauserRegistry = new PauserRegistry(pausers, unpauser);
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        MiddlewareDeployLib.MiddlewareDeployConfig memory middlewareConfig;
        middlewareConfig.instantSlasher.initialOwner = deployerAddress;
        middlewareConfig.instantSlasher.slasher = deployerAddress;
        middlewareConfig.slashingRegistryCoordinator.initialOwner = deployerAddress;
        middlewareConfig.slashingRegistryCoordinator.churnApprover = churnApprover;
        middlewareConfig.slashingRegistryCoordinator.ejector = ejector;
        middlewareConfig.slashingRegistryCoordinator.initPausedStatus = 0;
        middlewareConfig.slashingRegistryCoordinator.serviceManager = deployerAddress;
        middlewareConfig.socketRegistry.initialOwner = deployerAddress;
        middlewareConfig.indexRegistry.initialOwner = deployerAddress;
        middlewareConfig.stakeRegistry.initialOwner = deployerAddress;
        middlewareConfig.stakeRegistry.minimumStake = .01 ether;
        middlewareConfig.stakeRegistry.strategyParams = 0;
        middlewareConfig.stakeRegistry.delegationManager = delegationManager;
        middlewareConfig.stakeRegistry.avsDirectory = avsDirectory;
        middlewareConfig.instantSlasher.slasher = deployerAddress;
        {
            IStakeRegistryTypes.StrategyParams[] memory stratParams =
                new IStakeRegistryTypes.StrategyParams[](1);
            stratParams[0] =
                IStakeRegistryTypes.StrategyParams({strategy: IStrategy(strategy), multiplier: 1 ether});
            middlewareConfig.stakeRegistry.strategyParamsArray = stratParams;
        }
        middlewareConfig.stakeRegistry.lookAheadPeriod = 0;
        middlewareConfig.stakeRegistry.stakeType = IStakeRegistryTypes.StakeType(1);
        middlewareConfig.blsApkRegistry.initialOwner = deployerAddress;

        MiddlewareDeployLib.MiddlewareDeployData memory middlewareDeployments = MiddlewareDeployLib
            .deployMiddleware(
            deployerAddress,
            allocationManager,
            address(pauserRegistry),
            middlewareConfig
        );

        SlashingRegistryCoordinator  slashingRegistryCoordinator =
            SlashingRegistryCoordinator(payable(middlewareDeployments.slashingRegistryCoordinator));
        
        // Deploy SelfSlasher
        SelfSlasher selfSlasher = new SelfSlasher(
            IAllocationManager(allocationManager),
            ISlashingRegistryCoordinator(slashingRegistryCoordinator),
            deployerAddress
        );
        
        // Log the deployment address
        console.log("SelfSlasher deployed at:", address(selfSlasher));
        console.log("SlashingRegistryCoordinator deployed at:", address(middlewareDeployments.slashingRegistryCoordinator));

        
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
            slashingRegistryCoordinator
        );
        
        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}