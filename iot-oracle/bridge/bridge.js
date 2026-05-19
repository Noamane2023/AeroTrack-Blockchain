/**
 * AeroTrack IoT Oracle Bridge
 * 
 * This script acts as the "oracle" - the bridge between the physical world
 * (MQTT sensor data) and the blockchain (Ethereum smart contract).
 * 
 * Flow: MQTT Broker -> This Bridge -> Smart Contract (logSensorData)
 */

const mqtt = require("mqtt");
const { ethers } = require("ethers");
const fs = require("fs");

// Load config
let config;
try {
  config = JSON.parse(fs.readFileSync("config.json", "utf8"));
} catch (e) {
  console.log("[ERROR] config.json not found! Run 'npm run deploy' first.");
  process.exit(1);
}

if (config.contractAddress === "PASTE_CONTRACT_ADDRESS_HERE") {
  console.log("[ERROR] You need to paste the contract address in config.json!");
  console.log("[ERROR] Deploy the contract in Remix first (see deploy.js output).");
  process.exit(1);
}

// --- Configuration ---
const MQTT_BROKER = "mqtt://localhost:1883";
const MQTT_TOPIC = "aerotrack/sensors/#";  // Subscribe to all sensor topics
const GANACHE_URL = config.provider;
const CONTRACT_ADDRESS = config.contractAddress;

// Simplified ABI (only what we need)
const CONTRACT_ABI = [
  "function logSensorData(string _dataType, string _value)",
  "function isSensorActive(address _sensor) view returns (bool)",
  "function sensors(address) view returns (uint256 assignedPart, string sensorType, bool isActive, uint256 registeredAt)",
  "event SensorDataLogged(uint256 indexed serialNumber, address indexed sensor, string dataType, string value)"
];

// --- Blockchain Setup ---
const provider = new ethers.JsonRpcProvider(GANACHE_URL);
// Account 2 = the sensor's private key (Ganache deterministic)
// With --deterministic flag, Account 2 private key is:
const SENSOR_PRIVATE_KEY = "0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356";
const sensorWallet = new ethers.Wallet(SENSOR_PRIVATE_KEY, provider);
const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, sensorWallet);

// --- Stats ---
let stats = {
  messagesReceived: 0,
  transactionsSent: 0,
  transactionsSuccess: 0,
  transactionsFailed: 0
};

// --- MQTT Setup ---
console.log("=".repeat(50));
console.log("  AeroTrack IoT Oracle Bridge");
console.log("  MQTT -> Ethereum Blockchain");
console.log("=".repeat(50));
console.log();
console.log(`  MQTT Broker:  ${MQTT_BROKER}`);
console.log(`  Blockchain:   ${GANACHE_URL}`);
console.log(`  Contract:     ${CONTRACT_ADDRESS}`);
console.log(`  Sensor Addr:  ${sensorWallet.address}`);
console.log();

const mqttClient = mqtt.connect(MQTT_BROKER);

mqttClient.on("connect", () => {
  console.log("[MQTT] Connected to broker");
  mqttClient.subscribe(MQTT_TOPIC, (err) => {
    if (err) {
      console.log("[MQTT] Subscribe error:", err.message);
    } else {
      console.log(`[MQTT] Subscribed to: ${MQTT_TOPIC}`);
      console.log();
      console.log("[BRIDGE] Waiting for sensor data...");
      console.log("-".repeat(50));
    }
  });
});

mqttClient.on("message", async (topic, message) => {
  stats.messagesReceived++;

  try {
    const data = JSON.parse(message.toString());
    
    console.log();
    console.log(`[MQTT] Received from ${topic}:`);
    console.log(`       Sensor: ${data.sensorId} | Part: ${data.partSerial}`);
    console.log(`       Type: ${data.dataType} | Value: ${data.value} | Status: ${data.status}`);

    // Send to blockchain
    console.log("[CHAIN] Sending transaction to smart contract...");
    stats.transactionsSent++;

    const tx = await contract.logSensorData(data.dataType, data.value);
    const receipt = await tx.wait();

    stats.transactionsSuccess++;
    console.log(`[CHAIN] ✅ Transaction confirmed!`);
    console.log(`       TX Hash: ${receipt.hash}`);
    console.log(`       Block:   ${receipt.blockNumber}`);
    console.log(`       Gas:     ${receipt.gasUsed.toString()}`);

    // Parse the event
    if (receipt.logs.length > 0) {
      console.log(`[EVENT] SensorDataLogged emitted on-chain`);
    }

    console.log(`[STATS] Messages: ${stats.messagesReceived} | TX Sent: ${stats.transactionsSent} | Success: ${stats.transactionsSuccess} | Failed: ${stats.transactionsFailed}`);
    console.log("-".repeat(50));

  } catch (error) {
    stats.transactionsFailed++;
    console.log(`[ERROR] Transaction failed: ${error.reason || error.message}`);
    console.log("-".repeat(50));
  }
});

mqttClient.on("error", (err) => {
  console.log("[MQTT] Connection error:", err.message);
  console.log("[MQTT] Make sure Mosquitto is running: docker-compose up -d");
});

// Graceful shutdown
process.on("SIGINT", () => {
  console.log("\n[BRIDGE] Shutting down...");
  console.log(`[STATS] Final: ${stats.messagesReceived} messages, ${stats.transactionsSuccess} on-chain`);
  mqttClient.end();
  process.exit(0);
});
