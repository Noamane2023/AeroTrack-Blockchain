# ✈️ AeroTrack — Blockchain Spare Parts Provenance

Ethereum smart contract for securing airplane spare parts provenance using Solidity, with IoT Oracle integration via MQTT.

## About

AeroTrack is a decentralized system that tracks the lifecycle of airplane spare parts on the Ethereum blockchain. Every manufacturing event, ownership transfer, and maintenance record is immutably recorded, ensuring supply chain integrity in aviation.

## Features

- 🏭 **Part Registration** — Manufacturers register parts with unique serial numbers
- 🔄 **Ownership Transfer** — Secure transfer between manufacturers, airlines, and mechanics
- 🔒 **Role-Based Access Control** — Modifiers prevent unauthorized access
- 📋 **Maintenance Logging** — Gas-efficient event-based maintenance records
- 🆔 **Decentralized Identifiers (DIDs)** — On-chain manufacturer identity verification
- 📡 **IoT Oracle** — Authorized sensors auto-report data to the blockchain
- 🌐 **MQTT Integration** — Real IoT pipeline with Mosquitto broker + Node.js bridge

## Architecture

```
┌──────────────┐    MQTT     ┌────────────────┐    Ethers.js    ┌────────────────┐
│ Python Sensor │ ─────────→ │ Mosquitto MQTT │ ─────────────→ │ Smart Contract │
│ (simulator)   │  publish   │ Broker (Docker)│  (Node.js)     │ (Ethereum)     │
└──────────────┘             └────────────────┘                └────────────────┘
```

## Project Structure

```
├── contracts/              # Solidity smart contracts (step by step)
│   ├── AeroTrack.sol       # Final base contract
│   ├── Step5_Enhancement.sol
│   ├── Step6_DIDs.sol
│   └── Step7_IoTOracle.sol # Full contract with IoT
├── iot-oracle/             # MQTT IoT Oracle system
│   ├── docker-compose.yml  # Mosquitto + Ganache
│   ├── bridge/             # Node.js MQTT → Blockchain bridge
│   └── sensor/             # Python sensor simulator
├── report/
│   ├── report.tex          # LaTeX source (33 pages)
│   └── report.pdf          # Compiled PDF report
├── screens/                # Remix IDE screenshots
└── steps/                  # Step-by-step markdown guides
```

## Quick Start (Remix IDE)

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Paste `contracts/Step7_IoTOracle.sol`
3. Compile with Solidity **0.8.19** (EVM: london)
4. Deploy on Remix VM
5. Follow the test scenarios in the report

## IoT Oracle Setup (Docker + MQTT)

```bash
cd iot-oracle
docker-compose up -d          # Start Mosquitto + Ganache
cd bridge && npm install      # Install bridge dependencies
cd ../sensor && pip install -r requirements.txt  # Install sensor deps

# Deploy contract via Remix (External Http Provider → localhost:8545)
# Then:
cd bridge && npm start        # Terminal 1: Start bridge
cd sensor && python sensor_simulator.py  # Terminal 2: Start sensor
```

## Technologies

| Technology | Purpose |
|-----------|---------|
| Solidity 0.8.19 | Smart contract language |
| Remix IDE | Development & testing |
| Ganache | Local Ethereum blockchain |
| MQTT (Mosquitto) | IoT messaging protocol |
| Node.js + Ethers.js | Blockchain bridge (oracle) |
| Python + paho-mqtt | Sensor simulator |
| Docker | Infrastructure containers |
| LaTeX (MiKTeX) | Report compilation |

## Author

**Noaman Makhlouf**  
ENSEM — Ecole Nationale Superieure d'Electricite et de Mecanique  
Universite Hassan II de Casablanca  
Blockchain Tools & Applications — S4 2025/2026

## License

MIT
