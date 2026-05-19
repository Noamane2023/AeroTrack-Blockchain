// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title AeroTrack - Step 6: Decentralized Identifiers (DIDs)
/// @notice Adds on-chain manufacturer identity verification
/// @dev Extends Step 5 with full identity storage (name, country, certification)

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

    // NEW: On-chain identity for manufacturers (DID)
    struct ManufacturerIdentity {
        string name;              // e.g., "Boeing", "Airbus"
        string country;           // e.g., "USA", "France"
        string certificationId;   // e.g., "FAA-2024-001"
        bool isActive;            // Can they currently manufacture?
        uint256 registeredAt;     // Block timestamp of registration
    }

    address public regulatoryAuthority;
    mapping(uint256 => Part) public parts;
    mapping(address => bool) public certifiedManufacturers;

    // NEW: Full identity registry
    mapping(address => ManufacturerIdentity) public manufacturerIdentities;

    // --- EVENTS ---
    event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer);
    event OwnershipTransferred(uint256 indexed serialNumber, address oldOwner, address newOwner);
    event MaintenanceLogged(uint256 indexed serialNumber, address mechanic, string report);
    event ManufacturerCertified(address indexed manufacturer);
    event ManufacturerRevoked(address indexed manufacturer);
    // NEW: DID events
    event ManufacturerRegistered(address indexed manufacturer, string name, string certificationId);
    event ManufacturerUpdated(address indexed manufacturer, string name, string certificationId);
    event ManufacturerDeactivated(address indexed manufacturer);

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

    modifier onlyAuthority() {
        require(msg.sender == regulatoryAuthority, "Not the authority.");
        _;
    }

    modifier onlyCertified() {
        require(certifiedManufacturers[msg.sender], "Not a certified manufacturer.");
        _;
    }

    // --- DID FUNCTIONS (NEW) ---

    /// @notice Register a manufacturer with full identity (like issuing a DID)
    /// @param _manufacturer The Ethereum address to register
    /// @param _name Company name (e.g., "Boeing")
    /// @param _country Country of origin (e.g., "USA")
    /// @param _certificationId Official certification number (e.g., "FAA-2024-001")
    function registerManufacturer(
        address _manufacturer,
        string memory _name,
        string memory _country,
        string memory _certificationId
    ) public onlyAuthority {
        require(_manufacturer != address(0), "Invalid address.");

        // Store the full identity
        manufacturerIdentities[_manufacturer] = ManufacturerIdentity({
            name: _name,
            country: _country,
            certificationId: _certificationId,
            isActive: true,
            registeredAt: block.timestamp
        });

        // Also certify them (backward compatible with Step 5)
        certifiedManufacturers[_manufacturer] = true;

        emit ManufacturerRegistered(_manufacturer, _name, _certificationId);
    }

    /// @notice Update a manufacturer's identity information
    function updateManufacturer(
        address _manufacturer,
        string memory _name,
        string memory _country,
        string memory _certificationId
    ) public onlyAuthority {
        require(manufacturerIdentities[_manufacturer].registeredAt != 0, "Manufacturer not registered.");

        manufacturerIdentities[_manufacturer].name = _name;
        manufacturerIdentities[_manufacturer].country = _country;
        manufacturerIdentities[_manufacturer].certificationId = _certificationId;

        emit ManufacturerUpdated(_manufacturer, _name, _certificationId);
    }

    /// @notice Deactivate a manufacturer (revoke their DID)
    function deactivateManufacturer(address _manufacturer) public onlyAuthority {
        manufacturerIdentities[_manufacturer].isActive = false;
        certifiedManufacturers[_manufacturer] = false;

        emit ManufacturerDeactivated(_manufacturer);
    }

    /// @notice Check if a manufacturer is currently active
    /// @return True if the manufacturer is registered and active
    function isManufacturerActive(address _manufacturer) public view returns (bool) {
        return manufacturerIdentities[_manufacturer].isActive;
    }

    // --- CORE FUNCTIONS ---

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
