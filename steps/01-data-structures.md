# Step 1: Architecting the Data Structure

## What you'll learn
- What a `struct` is and why we use it
- What a `mapping` is and how it replaces arrays
- How to define the "identity card" of an airplane part
- The `exists` pattern to avoid ghost data

## Real-world analogy

> Think of a **struct** like a form you fill out at the airport. It has fixed fields: name, passport number, nationality. In Solidity, a struct groups related data together under one name.
>
> Think of a **mapping** like a filing cabinet. You give it a serial number (the label on the drawer), and it instantly gives you the full form. No need to search through every drawer!

---

## What to do (Actions)

### Action 1: Create the file in Remix

1. Open [Remix IDE](https://remix.ethereum.org/)
2. In the left panel (File Explorer), click the **"+"** icon
3. Name the file: `AeroTrack.sol`
4. Type the code below (see "The Contract Skeleton" section)

### Action 2: Compile

1. Go to the **Solidity Compiler** tab (left sidebar, 2nd icon)
2. Select compiler version: **0.8.19**
3. Click **Compile AeroTrack.sol**
4. You should see a green checkmark ✅

### Action 3: Deploy

1. Go to the **Deploy & Run Transactions** tab (left sidebar, 3rd icon)
2. Environment: **Remix VM (Shanghai)**
3. Click **Deploy**
4. The contract appears under "Deployed Contracts" at the bottom

### Action 4: Test the state variable

1. Expand the deployed contract (click the arrow)
2. Click the blue **regulatoryAuthority** button
3. It should return your account address (the one selected in the dropdown)

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | The code in Remix editor (full screen showing AeroTrack.sol) | Proves you wrote the code |
| 2 | Successful compilation (green checkmark visible) | Proves it compiles without errors |
| 3 | Deployment success (green checkmark in terminal + contract under "Deployed Contracts") | Proves deployment works |
| 4 | Click `regulatoryAuthority` → shows your address | Proves the constructor set the authority |

> 💡 **Tip:** Save screenshots as `step1-code.png`, `step1-compile.png`, `step1-deploy.png`, `step1-authority.png` in a `screenshots/` folder.

---

## The PartStatus Enum

Before defining the part itself, we need to define its possible states:

```solidity
enum PartStatus { Manufactured, InTransit, Installed, Retired }
```

**Why?** Because a part goes through a lifecycle:
- `Manufactured` → just created in the factory
- `InTransit` → being shipped to an airline
- `Installed` → mounted on an airplane
- `Retired` → end of life, no longer usable

## The Part Struct

```solidity
struct Part {
    uint256 serialNumber;    // Unique ID (like a passport number)
    string partName;         // e.g., "Turbine Blade"
    address manufacturer;    // Who made it (Ethereum address)
    address currentOwner;    // Who has it now
    PartStatus status;       // Current lifecycle state
    bool exists;             // Security flag
}
```

**The `exists` flag trick:** In Solidity, if you ask for a part that was never created (e.g., serial number 9999), the mapping returns a struct full of zeros. The `exists` field lets us distinguish between "this part was never registered" and "this part exists but has default values."

## The parts Mapping

```solidity
mapping(uint256 => Part) public parts;
```

This reads as: "Given a serial number (`uint256`), return the corresponding `Part` struct."

**Why not an array?** Arrays require looping to find an item. With 1 million parts, that costs enormous gas. A mapping gives instant O(1) access.

## The Contract Skeleton

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AeroTrack {

    // The lifecycle states of a part
    enum PartStatus { Manufactured, InTransit, Installed, Retired }

    // The "identity card" of an airplane part
    struct Part {
        uint256 serialNumber;
        string partName;
        address manufacturer;
        address currentOwner;
        PartStatus status;
        bool exists;
    }

    // The deployer becomes the regulatory authority (FAA/EASA)
    address public regulatoryAuthority;

    // Filing cabinet: serial number → Part data
    mapping(uint256 => Part) public parts;

    // Runs once when the contract is deployed
    constructor() {
        regulatoryAuthority = msg.sender;
    }
}
```

**What happens at deployment:**
- `constructor()` runs once
- `msg.sender` = the person who deploys = becomes the regulatory authority (like the FAA)

---

## Key takeaways
- ✅ A **struct** groups related data (like a form)
- ✅ A **mapping** gives instant access by key (like a filing cabinet)
- ✅ The **exists** flag prevents confusion with default zero values
- ✅ The **constructor** sets up initial state once at deployment

## Common mistakes
| Mistake | Why it's wrong |
|---------|---------------|
| Using an array instead of mapping | Costs too much gas to search |
| Forgetting `exists` flag | Can't tell if a part is real or just zeros |
| Not setting `regulatoryAuthority` | Nobody can act as admin later |
