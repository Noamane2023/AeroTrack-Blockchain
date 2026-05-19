// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title AeroTrack - Step 7: IoT Oracle Simulation
/// @notice Adds authorized sensor addresses that can auto-log data for parts
/// @dev Simulates IoT devices reporting maintenance data to the blockchain

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

    // DID identity struct (from Step 6)
    struct ManufacturerIdentity {
        string name;
        string country;
        string certificationId;
        bool isActive;
        uint256 registeredAt;
    }

    // NEW: IoT Sensor struct
    struct Sensor {
        uint256 assignedPart;    // Which part this sensor monitors
        string sensorType;       // e.g., "temperature", "vibration", "stress"
        bool isActive;
        uint256 registeredAt;
    }

    address public regulatoryAuthority;
    mapping(uint256 => Part) public parts;
    mapping(address => bool) public certifiedManufacturers;
    mapping(address => ManufacturerIdentity) public manufacturerIdentities;

    // NEW: Sensor registry
    mapping(address => Sensor) public sensors;

    // --- EVENTS ---
    event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer);
    event OwnershipTransferred(uint256 indexed serialNumber, address oldOwner, address newOwner);
    event MaintenanceLogged(uint256 indexed serialNumber, address mechanic, string report);
    event ManufacturerRegistered(address indexed manufacturer, string name, string certificationId);
    event ManufacturerDeactivated(address indexed manufacturer);
    // NEW: IoT events
    event SensorRegistered(address indexed sensor, uint256 indexed serialNumber, string sensorType);
    event SensorRevoked(address indexed sensor);
    event SensorDataLogged(uint256 indexed serialNumber, address indexed sensor, string dataType, string value);

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

    // NEW: Only registered and active sensors can report
    modifier onlyActiveSensor() {
        require(sensors[msg.sender].isActive, "Not an authorized sensor.");
        _;
    }

    // --- DID FUNCTIONS (from Step 6) ---

    function registerManufacturer(
        address _manufacturer,
        string memory _name,
        string memory _country,
        string memory _certificationId
    ) public onlyAuthority {
        require(_manufacturer != address(0), "Invalid address.");

        manufacturerIdentities[_manufacturer] = ManufacturerIdentity({
            name: _name,
            country: _country,
            certificationId: _certificationId,
            isActive: true,
            registeredAt: block.timestamp
        });

        certifiedManufacturers[_manufacturer] = true;
        emit ManufacturerRegistered(_manufacturer, _name, _certificationId);
    }

    function deactivateManufacturer(address _manufacturer) public onlyAuthority {
        manufacturerIdentities[_manufacturer].isActive = false;
        certifiedManufacturers[_manufacturer] = false;
        emit ManufacturerDeactivated(_manufacturer);
    }

    // --- IoT SENSOR FUNCTIONS (NEW) ---

    /// @notice Register an IoT sensor and assign it to a specific part
    /// @param _sensor The Ethereum address representing the IoT device
    /// @param _serialNumber The part this sensor monitors
    /// @param _sensorType Type of sensor (e.g., "temperature", "vibration")
    function registerSensor(
        address _sensor,
        uint256 _serialNumber,
        string memory _sensorType
    ) public onlyAuthority partExists(_serialNumber) {
        require(_sensor != address(0), "Invalid sensor address.");

        sensors[_sensor] = Sensor({
            assignedPart: _serialNumber,
            sensorType: _sensorType,
            isActive: true,
            registeredAt: block.timestamp
        });

        emit SensorRegistered(_sensor, _serialNumber, _sensorType);
    }

    /// @notice Revoke a sensor's authorization
    function revokeSensor(address _sensor) public onlyAuthority {
        sensors[_sensor].isActive = false;
        emit SensorRevoked(_sensor);
    }

    /// @notice Sensor reports data for its assigned part (simulates IoT oracle)
    /// @param _dataType What is being measured (e.g., "temperature", "vibration")
    /// @param _value The reading (e.g., "85C", "0.3g", "no cracks detected")
    function logSensorData(
        string memory _dataType,
        string memory _value
    ) public onlyActiveSensor {
        uint256 serialNumber = sensors[msg.sender].assignedPart;

        emit SensorDataLogged(serialNumber, msg.sender, _dataType, _value);
    }

    /// @notice Check if a sensor is currently active
    function isSensorActive(address _sensor) public view returns (bool) {
        return sensors[_sensor].isActive;
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
