// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.27;
import {IAVSRegistrar} from "eigenlayer-contracts/src/contracts/interfaces/IAVSRegistrar.sol";

contract SimpleAVSRegistrar is IAVSRegistrar {
    address public immutable avsAddress;
    
    // Events to track registrations and deregistrations
    event OperatorRegistered(address operator, address avs, uint32[] operatorSetIds, bytes data);
    event OperatorDeregistered(address operator, address avs, uint32[] operatorSetIds);
    
    /**
     * @notice Constructor sets the AVS address this registrar supports
     * @param _avsAddress The address of the AVS this registrar supports
     */
    constructor(address _avsAddress) {
        avsAddress = _avsAddress;
    }
    
    /**
     * @notice Accepts all operator registrations
     * @param operator The operator being registered
     * @param avs The AVS address 
     * @param operatorSetIds The operator set IDs
     * @param data Registration data (ignored)
     */
    function registerOperator(
        address operator,
        address avs,
        uint32[] calldata operatorSetIds,
        bytes calldata data
    ) external override {
        emit OperatorRegistered(operator, avs, operatorSetIds, data);
    }
    
    /**
     * @notice Accepts all operator deregistrations
     * @param operator The operator being deregistered
     * @param avs The AVS address 
     * @param operatorSetIds The operator set IDs
     */
    function deregisterOperator(
        address operator,
        address avs,
        uint32[] calldata operatorSetIds
    ) external override {
        emit OperatorDeregistered(operator, avs, operatorSetIds);
    }
    
    /**
     * @notice Checks if this registrar supports the given AVS
     * @param avs The AVS address to check
     * @return True if supported, false otherwise
     */
    function supportsAVS(
        address avs
    ) external view override returns (bool) {
        return avs == avsAddress;
    }
}