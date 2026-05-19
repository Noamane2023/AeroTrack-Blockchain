# Step 7: Enhancement — IoT Oracle Simulation

## What you'll learn
- What the "oracle problem" is in blockchain
- How IoT sensors can report data to a smart contract
- How to authorize specific devices to write data
- Why this matters for predictive maintenance in aviation

## Real-world analogy

> Imagine a **temperature sensor** bolted to a turbine blade. Every hour, it measures the temperature. If it detects overheating, it should automatically log a warning on the blockchain — without any human intervention.
>
> But smart contracts are **blind** — they can't read sensors. They need an **oracle**: a trusted bridge that pushes external data on-chain. In our simulation, a Remix account pretends to be that sensor.

---

## The Oracle Problem

| Question | Answer |
|----------|--------|
| Can a smart contract read a sensor? | ❌ No — contracts can't access the outside world |
| Can a sensor call a smart contract? | ✅ Yes — if it has an Ethereum address and authorization |
| What's an oracle? | A trusted entity that pushes off-chain data on-chain |
| What's our simulation? | A Remix account acts as the sensor/oracle |

---

## What's new in this step

| Addition | Purpose |
|----------|---------|
| `Sensor` struct | Stores sensor info: assigned part, type, active status |
| `sensors` mapping | Registry of authorized IoT devices |
| `onlyActiveSensor` modifier | Only registered sensors can report |
| `registerSensor()` function | Authority links a sensor to a part |
| `revokeSensor()` function | Authority removes a sensor |
| `logSensorData()` function | Sensor reports a reading |
| `SensorRegistered` event | Announces new sensor |
| `SensorDataLogged` event | Records sensor data on-chain |

---

## What to do (Actions)

### Action 1: Deploy the IoT-enhanced contract

1. In Remix, paste `Step7_IoTOracle.sol`
2. **Compile** with version `0.8.19` (EVM: london) → green checkmark ✅
3. **Deploy** → Account 1 = authority

### Action 2: Setup — register manufacturer and create a part

1. **Account 1** → `registerManufacturer(Account2, "Boeing", "USA", "FAA-2024-001")`
2. Switch to **Account 2** → `manufacturePart(999, "Turbine Blade")`
3. Part 999 now exists and is owned by Account 2

### Action 3: Register an IoT sensor

1. Switch back to **Account 1** (authority)
2. Call `registerSensor` with:
   - `_sensor`: [Account 3's address] (this pretends to be the sensor)
   - `_serialNumber`: `999`
   - `_sensorType`: `temperature`
3. ✅ Success → `SensorRegistered` event emitted

### Action 4: Verify sensor registration

1. Click `sensors` with Account 3's address
2. You should see:
   - `assignedPart: 999`
   - `sensorType: temperature`
   - `isActive: true`
   - `registeredAt: [timestamp]`

### Action 5: Sensor reports data

1. Switch to **Account 3** (the "sensor")
2. Call `logSensorData` with:
   - `_dataType`: `temperature`
   - `_value`: `85C - normal operating range`
3. ✅ Success → `SensorDataLogged` event emitted with serial 999

### Action 6: Sensor reports another reading

1. Stay on **Account 3**
2. Call `logSensorData` with:
   - `_dataType`: `vibration`
   - `_value`: `0.3g - within tolerance`
3. ✅ Success → another event logged

### Action 7: Unauthorized sensor attempt (should fail)

1. Switch to **Account 4** (NOT a registered sensor)
2. Try `logSensorData("temperature", "fake data")`
3. ❌ **FAILS** with: "Not an authorized sensor."

### Action 8: Revoke sensor

1. Switch to **Account 1** (authority)
2. Call `revokeSensor([Account 3 address])`
3. ✅ Success → `SensorRevoked` event
4. Switch to **Account 3** → try `logSensorData("temperature", "85C")` → ❌ FAILS

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | Code showing Sensor struct + IoT functions | Proves implementation |
| 2 | `registerSensor` success + event | Proves sensor registration |
| 3 | `sensors` query showing assigned part and type | Proves sensor data stored |
| 4 | `logSensorData` success + `SensorDataLogged` event | Proves sensor reporting works |
| 5 | Second `logSensorData` call (vibration) | Shows multiple readings |
| 6 | Unauthorized Account 4 fails | Proves access control |
| 7 | `revokeSensor` + failed report after | Proves revocation works |

> 💡 **Tip:** Save as `step7-code.png`, `step7-registerSensor.png`, `step7-sensor-query.png`, `step7-sensorData-temp.png`, `step7-sensorData-vibration.png`, `step7-unauthorized-fail.png`, `step7-revoke-fail.png`

---

## The code explained

### Sensor Struct

```solidity
struct Sensor {
    uint256 assignedPart;    // Which part this sensor monitors
    string sensorType;       // "temperature", "vibration", "stress"
    bool isActive;
    uint256 registeredAt;
}
```

Each sensor is linked to ONE specific part. This prevents a temperature sensor on Part A from reporting data for Part B.

### logSensorData Function

```solidity
function logSensorData(
    string memory _dataType,
    string memory _value
) public onlyActiveSensor {
    uint256 serialNumber = sensors[msg.sender].assignedPart;
    emit SensorDataLogged(serialNumber, msg.sender, _dataType, _value);
}
```

**Key design decisions:**
- The sensor doesn't pass the serial number — it's automatically looked up from the registry
- This prevents a sensor from reporting data for a part it's not assigned to
- Data is stored as an event (cheap) not in storage (expensive)

### Why events for sensor data?

A sensor might report every hour. Storing each reading in contract storage would cost thousands of dollars in gas. Events cost pennies and are still permanently recorded on the blockchain.

---

## How this maps to the real world

```
Real IoT System:
┌─────────┐     ┌──────────┐     ┌────────────────┐
│ Sensor  │ ──→ │ Gateway  │ ──→ │ Smart Contract │
│ (on part)│     │ (oracle) │     │ (blockchain)   │
└─────────┘     └──────────┘     └────────────────┘

Our Simulation:
┌─────────────┐                  ┌────────────────┐
│ Account 3   │ ────────────────→│ Smart Contract │
│ (= sensor)  │                  │ (blockchain)   │
└─────────────┘                  └────────────────┘
```

In production, the "Gateway" would be a Chainlink oracle or a custom backend that:
1. Reads sensor data via WiFi/Bluetooth
2. Signs a transaction with the sensor's private key
3. Calls `logSensorData()` on the blockchain

---

## Key takeaways
- ✅ **Oracle** = bridge between off-chain world and on-chain contracts
- ✅ Sensors are **authorized per-part** (can't report for other parts)
- ✅ Serial number is auto-resolved from sensor registry (security)
- ✅ Data stored as **events** (gas-efficient for frequent readings)
- ✅ Authority controls which sensors are trusted

## Common mistakes
| Mistake | Why it's wrong |
|---------|---------------|
| Letting sensors pass the serial number | They could fake data for other parts |
| Storing sensor data in arrays | Way too expensive for frequent readings |
| Not linking sensor to a specific part | No accountability |
| Forgetting revocation | Can't remove compromised sensors |
