# Step 5: The Complete Smart Contract

## What you'll learn
- How all pieces fit together
- The final assembled contract ready for deployment
- How to verify your code matches

---

## What to do (Actions)

### Action 1: Verify your code matches the complete version

Compare your `AeroTrack.sol` in Remix with the complete code below. Make sure:
- All 3 events are declared
- Both modifiers are present
- All 3 functions have `emit` statements
- The `transferPart` saves `oldOwner` before updating

### Action 2: Clean compile

1. Delete any old deployed contracts (click the trash icon)
2. **Compile** → green checkmark ✅
3. **Deploy** → fresh instance

### Action 3: Run the full checklist

Go through this checklist and tick each item:

- [ ] License identifier present (`MIT`)
- [ ] Pragma set to `^0.8.19`
- [ ] Enum has 4 states (Manufactured, InTransit, Installed, Retired)
- [ ] Struct has 6 fields (including `exists`)
- [ ] 3 events declared with `indexed` serial number
- [ ] 2 modifiers (`partExists`, `onlyPartOwner`)
- [ ] 3 functions (`manufacturePart`, `transferPart`, `logMaintenance`)
- [ ] All functions emit their corresponding events
- [ ] Zero-address check in `transferPart`

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | Full contract code in Remix (scroll to show all ~70 lines) — may need 2 screenshots | Final proof of complete code |
| 2 | Successful compilation of the complete contract | Proves everything works together |

> 💡 **Tip:** Save as `step5-full-code-1.png`, `step5-full-code-2.png`, `step5-compile.png`

---

## The Complete `AeroTrack.sol`

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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

    event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer);
    event OwnershipTransferred(uint256 indexed serialNumber, address oldOwner, address newOwner);
    event MaintenanceLogged(uint256 indexed serialNumber, address mechanic, string report);

    constructor() {
        regulatoryAuthority = msg.sender;
    }

    modifier partExists(uint256 _serialNumber) {
        require(parts[_serialNumber].exists == true, "Part does not exist.");
        _;
    }

    modifier onlyPartOwner(uint256 _serialNumber) {
        require(parts[_serialNumber].currentOwner == msg.sender, "Not the owner.");
        _;
    }

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

        emit PartManufactured(_serialNumber, _partName, msg.sender);
    }

    function transferPart(uint256 _serialNumber, address _newOwner)
        public partExists(_serialNumber) onlyPartOwner(_serialNumber)
    {
        require(_newOwner != address(0), "Invalid address.");

        address oldOwner = parts[_serialNumber].currentOwner;
        parts[_serialNumber].currentOwner = _newOwner;
        parts[_serialNumber].status = PartStatus.InTransit;

        emit OwnershipTransferred(_serialNumber, oldOwner, _newOwner);
    }

    function logMaintenance(uint256 _serialNumber, string memory _report)
        public partExists(_serialNumber) onlyPartOwner(_serialNumber)
    {
        emit MaintenanceLogged(_serialNumber, msg.sender, _report);
        parts[_serialNumber].status = PartStatus.Installed;
    }
}
```

---

## Key takeaways
- ✅ The contract is ~70 lines of clean, modular code
- ✅ Each component has a single responsibility
- ✅ Security is handled by modifiers, not duplicated in functions
- ✅ Events provide cheap traceability without expensive storage
