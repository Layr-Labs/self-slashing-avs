// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;

import {
    IAllocationManager,
    IAllocationManagerTypes
} from "eigenlayer-contracts/src/contracts/interfaces/IAllocationManager.sol";
import {IStrategy} from "eigenlayer-contracts/src/contracts/interfaces/IStrategy.sol";
import {OperatorSet} from "eigenlayer-contracts/src/contracts/libraries/OperatorSetLib.sol";

/// @title SelfSlasherSimploe
/// @notice Example contract allowing operators to slash themselves for testing purposes
/// @dev Doesn't use registryCoordinator functionality, provides a simplified way to test slashing effects
contract SelfSlasherSimple {
    /// @notice Emitted when an operator is successfully slashed
    event OperatorSlashed(
        uint256 indexed slashingRequestId,
        address indexed operator,
        uint32 indexed operatorSetId,
        uint256[] wadsToSlash,
        string description
    );
    
    /// @notice the AllocationManager that tracks OperatorSets and Slashing in EigenLayer
    IAllocationManager public immutable allocationManager;
    /// @notice the address of the slasher
    address public immutable avs;

    uint256 public nextRequestId;


    /// @notice Error thrown when wad to slash is invalid
    error InvalidWadToSlash();

    /// @notice Error thrown when no strategies are found in the operator set
    error NoStrategiesInOperatorSet();

    /// @notice Error thrown when operator is not slashable in this operator set
    error OperatorNotSlashable();

    /// @notice Constructs the SelfSlasher contract
    /// @param _allocationManager The EigenLayer allocation manager contract
    /// @param _avs The address of the avs (admin)
    constructor(
        IAllocationManager _allocationManager,
        address _avs
    ) {
        allocationManager = _allocationManager;
        avs = _avs;
    }

    /// @notice Allows an operator to slash their own stake
    /// @param operatorSetId The ID of the operator set in which to slash the operator
    /// @param wadToSlash The proportion to slash from each strategy (between 0 and 1e18)
    /// @param description A description of why the operator is slashing themselves
    function selfSlash(
        uint32 operatorSetId,
        uint256 wadToSlash,
        string calldata description
    ) external {
        if (wadToSlash == 0 || wadToSlash > 1e18) {
            revert InvalidWadToSlash();
        }

        OperatorSet memory operatorSet =
            OperatorSet(avs, operatorSetId);

        if (!allocationManager.isOperatorSlashable(msg.sender, operatorSet)) {
            revert OperatorNotSlashable();
        }

        IStrategy[] memory strategies = allocationManager.getStrategiesInOperatorSet(operatorSet);

        if (strategies.length == 0) {
            revert NoStrategiesInOperatorSet();
        }

        // Create wadsToSlash array with the same value for all strategies
        uint256[] memory wadsToSlash = new uint256[](strategies.length);
        for (uint256 i = 0; i < strategies.length; i++) {
            wadsToSlash[i] = wadToSlash;
        }

        // Create slashing parameters
        IAllocationManagerTypes.SlashingParams memory params = IAllocationManagerTypes
            .SlashingParams({
            operator: msg.sender,
            operatorSetId: operatorSetId,
            strategies: strategies,
            wadsToSlash: wadsToSlash,
            description: description
        });

        uint256 requestId = nextRequestId++;
        _fulfillSlashingRequest(requestId, params);
    }

    function _fulfillSlashingRequest(
        uint256 _requestId,
        IAllocationManager.SlashingParams memory _params
    ) internal virtual {
        allocationManager.slashOperator({avs: avs, params: _params});
        emit OperatorSlashed(
            _requestId,
            _params.operator,
            _params.operatorSetId,
            _params.wadsToSlash,
            _params.description
        );
    }
}