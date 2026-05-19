// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title AeroTrack - Step 3: Core Functions
/// @notice Adds manufacturePart and transferPart (no events yet)

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

    modifier partExists(uint256 _serialNumber) {
        require(parts[_serialNumber].exists == true, "Part does not exist.");
        _;
    }

    modifier onlyPartOwner(uint256 _serialNumber) {
        require(parts[_serialNumber].currentOwner == msg.sender, "Not the owner.");
        _;
    }

    // --- CORE FUNCTIONS ---

    // Register a newly manufactured part
    function manufacturePart(uint256 _serialNumber, string memory _partName) public {
        require(parts[_serialNumber].exists == false, "Serial Number taken!");

        parts[_serialNumber] = Part({
            serialNumber: _serialNumber,
            partName: _partName,
            manufacturer: msg.sender,
            currentOwner: msg.sender,
            status: PartStatus.Manufactured,
            exists: true
        });
    }

    // Transfer the part to a new owner (e.g., an Airline)
    function transferPart(uint256 _serialNumber, address _newOwner)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        require(_newOwner != address(0), "Invalid address.");

        parts[_serialNumber].currentOwner = _newOwner;
        parts[_serialNumber].status = PartStatus.InTransit;
    }
}
