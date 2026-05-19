# Step 8: Real IoT Oracle with MQTT Broker

## What you'll learn
- How to set up a real MQTT broker (Mosquitto)
- How to simulate a sensor publishing data
- How a Node.js bridge acts as an oracle
- How sensor data flows from MQTT to the blockchain automatically

## Architecture

```
┌──────────────────┐     MQTT publish      ┌──────────────────┐
│  Python Sensor   │ ───────────────────→  │  Mosquitto MQTT  │
│  (simulator)     │   topic: aerotrack/   │  Broker (Docker) │
└──────────────────┘   sensors/part999     └────────┬─────────┘
                                                    │ subscribe
                                                    ▼
┌──────────────────┐     ethers.js TX      ┌──────────────────┐
│  Ganache Local   │ ←─────────────────── │  Node.js Bridge  │
│  Blockchain      │   logSensorData()     │  (Oracle)        │
└──────────────────┘                       └──────────────────┘
```

---

## Prerequisites

- Docker Desktop installed and running
- Node.js installed ✅
- Python installed ✅

---

## What to do (Actions)

### Action 1: Start Docker services

Open a terminal in the `iot-oracle/` folder:

```bash
cd iot-oracle
docker-compose up -d
```

This starts:
- **Mosquitto** MQTT broker on port 1883
- **Ganache** local blockchain on port 8545

Verify:
```bash
docker ps
```
You should see both containers running.

### Action 2: Deploy the contract via Remix (connected to Ganache)

1. Open Remix IDE
2. Go to **Deploy & Run** tab
3. Change Environment to **"External Http Provider"**
4. Enter URL: `http://localhost:8545`
5. Click OK — you should see Ganache's 10 accounts
6. Paste `Step7_IoTOracle.sol` and compile
7. Deploy (Account 0 = authority)
8. **Copy the deployed contract address**

### Action 3: Setup the contract (in Remix)

1. Account 0 → `registerManufacturer(Account1, "Boeing", "USA", "FAA-2024-001")`
2. Switch to Account 1 → `manufacturePart(999, "Turbine Blade")`
3. Switch to Account 0 → `registerSensor(Account2, 999, "temperature")`

### Action 4: Configure the bridge

1. Open `iot-oracle/bridge/config.json`
2. Paste the contract address in `contractAddress`

Or run the deploy helper:
```bash
cd bridge
npm install
npm run deploy
```
Then paste the contract address in the generated `config.json`.

### Action 5: Install dependencies

```bash
# Bridge (Node.js)
cd iot-oracle/bridge
npm install

# Sensor (Python)
cd ../sensor
pip install -r requirements.txt
```

### Action 6: Start the bridge (Terminal 1)

```bash
cd iot-oracle/bridge
npm start
```

You should see:
```
==================================================
  AeroTrack IoT Oracle Bridge
  MQTT -> Ethereum Blockchain
==================================================
[MQTT] Connected to broker
[MQTT] Subscribed to: aerotrack/sensors/#
[BRIDGE] Waiting for sensor data...
```

### Action 7: Start the sensor simulator (Terminal 2)

```bash
cd iot-oracle/sensor
python sensor_simulator.py
```

You should see:
```
==================================================
  AeroTrack IoT Sensor Simulator
  Turbine Blade Temperature Sensor
==================================================
[SENSOR] Connected to MQTT broker
[SENSOR] Starting readings (every 5 seconds)...
  [1] ✅ 82.3C (NORMAL) -> aerotrack/sensors/part999
  [2] ✅ 76.1C (NORMAL) -> aerotrack/sensors/part999
  [3] ⚠️ 98.7C (WARNING) -> aerotrack/sensors/part999
```

### Action 8: Watch the bridge relay to blockchain

In Terminal 1 (bridge), you should see:
```
[MQTT] Received from aerotrack/sensors/part999:
       Sensor: SENSOR-TEMP-001 | Part: 999
       Type: temperature | Value: 82.3C | Status: NORMAL
[CHAIN] Sending transaction to smart contract...
[CHAIN] ✅ Transaction confirmed!
       TX Hash: 0x1234...
       Block:   5
       Gas:     28431
[EVENT] SensorDataLogged emitted on-chain
```

### Action 9: Verify on Remix

1. In Remix, check the transaction logs
2. You should see `SensorDataLogged` events appearing automatically
3. Each event has the temperature reading from the Python sensor

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | `docker ps` showing both containers running | Proves infrastructure |
| 2 | Remix connected to Ganache (External Http Provider) | Proves blockchain connection |
| 3 | Bridge terminal showing MQTT → blockchain flow | Proves the oracle works |
| 4 | Sensor terminal showing readings being published | Proves sensor simulation |
| 5 | Both terminals side by side (sensor + bridge) | Best screenshot for the video |
| 6 | Remix showing SensorDataLogged events from the bridge | Proves on-chain recording |

> 💡 **Tip:** Save as `step8-docker-ps.png`, `step8-remix-ganache.png`, `step8-bridge-running.png`, `step8-sensor-running.png`, `step8-both-terminals.png`, `step8-remix-events.png`

---

## How it works (for the report)

1. **Python sensor** generates random temperature readings every 5 seconds
2. Publishes to MQTT topic `aerotrack/sensors/part999`
3. **Mosquitto broker** receives and forwards to subscribers
4. **Node.js bridge** subscribes to all `aerotrack/sensors/#` topics
5. When a message arrives, bridge calls `logSensorData()` on the smart contract
6. Transaction is signed with the sensor's private key (Account 2)
7. **Ganache** mines the block and emits `SensorDataLogged` event
8. The event is permanently recorded on the blockchain

---

## Stopping everything

```bash
# Stop sensor: Ctrl+C in Terminal 2
# Stop bridge: Ctrl+C in Terminal 1
# Stop Docker:
cd iot-oracle
docker-compose down
```

---

## Key takeaways
- ✅ **MQTT** = lightweight IoT messaging protocol (publish/subscribe)
- ✅ **Mosquitto** = open-source MQTT broker
- ✅ **Bridge/Oracle** = the missing link between off-chain and on-chain
- ✅ **Ganache** = local Ethereum blockchain for testing
- ✅ Real sensors would replace the Python simulator
- ✅ In production, use Chainlink oracles instead of a custom bridge
