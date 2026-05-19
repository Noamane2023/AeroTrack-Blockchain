// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title AeroTrack - Step 5: Enhancement (Certified Manufacturers)
/// @notice Adds a manufacturer registry controlled by the regulatory authority
/// @dev This is a simplified DID approach — only certified addresses can create parts

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

    // NEW: Registry of certified manufacturers
    mapping(address => bool) public certifiedManufacturers;

    // --- EVENTS ---
    event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer);
    event OwnershipTransferred(uint256 indexed serialNumber, address oldOwner, address newOwner);
    event MaintenanceLogged(uint256 indexed serialNumber, address mechanic, string report);
    // NEW: Event when a manufacturer gets certified
    event ManufacturerCertified(address indexed manufacturer);
    // NEW: Event when a manufacturer gets revoked
    event ManufacturerRevoked(address indexed manufacturer);

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

    // NEW: Only the regulatory authority (FAA/EASA) can call this
    modifier onlyAuthority() {
        require(msg.sender == regulatoryAuthority, "Not the authority.");
        _;
    }

    // NEW: Only certified manufacturers can create parts
    modifier onlyCertified() {
        require(certifiedManufacturers[msg.sender], "Not a certified manufacturer.");
        _;
    }

    // --- AUTHORITY FUNCTIONS (NEW) ---

    // The authority certifies a manufacturer (like FAA approving Boeing)
    function certifyManufacturer(address _manufacturer) public onlyAuthority {
        require(_manufacturer != address(0), "Invalid address.");
        certifiedManufacturers[_manufacturer] = true;
        emit ManufacturerCertified(_manufacturer);
    }

    // The authority can revoke a manufacturer's certification
    function revokeManufacturer(address _manufacturer) public onlyAuthority {
        certifiedManufacturers[_manufacturer] = false;
        emit ManufacturerRevoked(_manufacturer);
    }

    // --- CORE FUNCTIONS ---

    // UPDATED: Now requires onlyCertified modifier
    function manufacturePart(uint256 _serialNumber, string memory _partName)
        public
        onlyCertified
    {
        require(parts[_serialNumber].exists == false, "Serial Number taken!");

        parts[_serialNumber] = Part({
            serialNumber: _serialNumber,
            partName: _partName,
            manufacturer: msg.sender,
            currentOwner: msg.sender,
            status: PartStatus.Manufactured,
            exists: true
        });

        emit PartManufactured(_serialNumber, _partName, msg.sender);
    }

    function transferPart(uint256 _serialNumber, address _newOwner)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        require(_newOwner != address(0), "Invalid address.");

        address oldOwner = parts[_serialNumber].currentOwner;
        parts[_serialNumber].currentOwner = _newOwner;
        parts[_serialNumber].status = PartStatus.InTransit;

        emit OwnershipTransferred(_serialNumber, oldOwner, _newOwner);
    }

    function logMaintenance(uint256 _serialNumber, string memory _report)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        emit MaintenanceLogged(_serialNumber, msg.sender, _report);
        parts[_serialNumber].status = PartStatus.Installed;
    }
}
