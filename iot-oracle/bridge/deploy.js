/**
 * AeroTrack - Deploy contract to local Ganache
 * Run this ONCE before starting the bridge.
 */

const { ethers } = require("ethers");
const fs = require("fs");

// ABI and Bytecode of Step7_IoTOracle.sol (compiled with solc)
// We use a simplified version for the demo
const CONTRACT_SOURCE = {
  abi: [
    "constructor()",
    "function regulatoryAuthority() view returns (address)",
    "function registerManufacturer(address _m, string _name, string _country, string _certId)",
    "function manufacturePart(uint256 _sn, string _name)",
    "function registerSensor(address _sensor, uint256 _sn, string _type)",
    "function revokeSensor(address _sensor)",
    "function logSensorData(string _dataType, string _value)",
    "function isSensorActive(address _sensor) view returns (bool)",
    "function sensors(address) view returns (uint256 assignedPart, string sensorType, bool isActive, uint256 registeredAt)",
    "function parts(uint256) view returns (uint256 serialNumber, string partName, address manufacturer, address currentOwner, uint8 status, bool exists)",
    "event SensorDataLogged(uint256 indexed serialNumber, address indexed sensor, string dataType, string value)",
    "event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer)",
    "event SensorRegistered(address indexed sensor, uint256 indexed serialNumber, string sensorType)"
  ]
};

// Bytecode from compiling Step7_IoTOracle.sol
// You need to compile the contract and paste the bytecode here
// For now, we'll use the ABI-only approach with a pre-deployed address

async function main() {
  console.log("=" .repeat(50));
  console.log("  AeroTrack - Contract Deployment to Ganache");
  console.log("=".repeat(50));
  console.log();

  // Connect to local Ganache
  const provider = new ethers.JsonRpcProvider("http://localhost:8545");
  
  try {
    const network = await provider.getNetwork();
    console.log(`[OK] Connected to Ganache (chainId: ${network.chainId})`);
  } catch (e) {
    console.log("[ERROR] Cannot connect to Ganache!");
    console.log("[ERROR] Make sure Ganache is running: docker-compose up -d");
    process.exit(1);
  }

  // Ganache deterministic accounts (with --deterministic flag)
  const accounts = await provider.listAccounts();
  console.log(`[OK] Found ${accounts.length} accounts`);
  console.log();

  // Account roles:
  // Account 0 = Regulatory Authority (deployer)
  // Account 1 = Manufacturer (Boeing)
  // Account 2 = Sensor (IoT device)
  const authority = await provider.getSigner(0);
  const manufacturer = await provider.getSigner(1);
  const sensor = await provider.getSigner(2);

  console.log(`  Authority:    ${await authority.getAddress()}`);
  console.log(`  Manufacturer: ${await manufacturer.getAddress()}`);
  console.log(`  Sensor:       ${await sensor.getAddress()}`);
  console.log();

  // Save config for the bridge
  const config = {
    provider: "http://localhost:8545",
    authority: await authority.getAddress(),
    manufacturer: await manufacturer.getAddress(),
    sensor: await sensor.getAddress(),
    // Contract address will be added after deployment
    // For now, use Remix to deploy and paste the address here
    contractAddress: "PASTE_CONTRACT_ADDRESS_HERE",
    note: "Deploy Step7_IoTOracle.sol on Remix connected to Ganache (Web3 Provider), then paste the address above"
  };

  fs.writeFileSync("config.json", JSON.stringify(config, null, 2));
  console.log("[OK] Config saved to config.json");
  console.log();
  console.log("NEXT STEPS:");
  console.log("1. In Remix, change Environment to 'External Http Provider'");
  console.log("   URL: http://localhost:8545");
  console.log("2. Deploy Step7_IoTOracle.sol");
  console.log("3. Copy the deployed contract address");
  console.log("4. Paste it in config.json -> contractAddress");
  console.log("5. In Remix, call registerManufacturer() for Account 1");
  console.log("6. Switch to Account 1, call manufacturePart(999, 'Turbine Blade')");
  console.log("7. Switch to Account 0, call registerSensor(Account2, 999, 'temperature')");
  console.log("8. Run: npm start");
}

main().catch(console.error);
