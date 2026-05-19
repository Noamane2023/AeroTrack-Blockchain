// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title AeroTrack - Step 2: Access Control
/// @notice Adds modifiers for role-based security

contract AeroTrack {

    enum PartStatus { Manufactured, InTransit, Installed, Retired }

    struct Part {
        uint256 serialNumber;
        string partName;
        address manufacturer;
        address currentOwner;
        PartStatus status;
        bool exists;
    }

    address public regulatoryAuthority;
    mapping(uint256 => Part) public parts;

    constructor() {
        regulatoryAuthority = msg.sender;
    }

    // --- MODIFIERS ---

    // Check: does this part exist in the registry?
    modifier partExists(uint256 _serialNumber) {
        require(parts[_serialNumber].exists == true, "Part does not exist.");
        _;
    }

    // Check: is the caller the current owner of this part?
    modifier onlyPartOwner(uint256 _serialNumber) {
        require(parts[_serialNumber].currentOwner == msg.sender, "Not the owner.");
        _;
    }
}
