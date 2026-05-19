// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title AeroTrack - Step 1: Data Structure
/// @notice Only the skeleton: enum, struct, mapping, constructor

contract AeroTrack {

    // The lifecycle states of a part
    enum PartStatus { Manufactured, InTransit, Installed, Retired }

    // The "identity card" of an airplane part
    struct Part {
        uint256 serialNumber;
        string partName;
        address manufacturer;
        address currentOwner;
        PartStatus status;
        bool exists;
    }

    // The deployer becomes the regulatory authority (FAA/EASA)
    address public regulatoryAuthority;

    // Filing cabinet: serial number -> Part data
    mapping(uint256 => Part) public parts;

    // Runs once when the contract is deployed
    constructor() {
        regulatoryAuthority = msg.sender;
    }
}
