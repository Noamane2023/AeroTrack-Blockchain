# Step 5: Enhancement — Certified Manufacturer Registry

## What you'll learn
- How to add a manufacturer certification system
- How the regulatory authority (FAA) controls who can create parts
- How to test certification and revocation
- Why this is a simplified version of Decentralized Identifiers (DIDs)

## Real-world analogy

> Imagine the FAA has a **list of approved manufacturers**. Before Boeing can stamp a part as "airworthy," they need FAA certification. Without it, they can't legally produce parts. Our smart contract does the same thing: the `regulatoryAuthority` maintains a list of certified addresses, and only those addresses can call `manufacturePart`.

---

## What's new in this step

| Addition | Purpose |
|----------|---------|
| `certifiedManufacturers` mapping | Registry of approved manufacturer addresses |
| `onlyAuthority` modifier | Only the FAA/EASA can certify manufacturers |
| `onlyCertified` modifier | Only certified addresses can create parts |
| `certifyManufacturer()` function | Authority approves a manufacturer |
| `revokeManufacturer()` function | Authority removes certification |
| `ManufacturerCertified` event | Announces a new certification |
| `ManufacturerRevoked` event | Announces a revocation |

---

## What to do (Actions)

### Action 1: Deploy the enhanced contract

1. In Remix, create a new file or replace your code with `Step5_Enhancement.sol`
2. **Compile** with version `0.8.19` (EVM: london) → green checkmark ✅
3. **Deploy** → Account 1 becomes the `regulatoryAuthority`

### Action 2: Try to manufacture WITHOUT certification (should fail)

1. Stay on **Account 1** (the authority)
2. Try `manufacturePart(999, "Turbine Blade")`
3. ❌ **FAILS** with: "Not a certified manufacturer."
4. Even the authority can't create parts without being certified first!

### Action 3: Certify a manufacturer

1. Stay on **Account 1** (the authority)
2. Copy **Account 2's address** from the dropdown
3. Call `certifyManufacturer([Account 2 address])`
4. ✅ Success → `ManufacturerCertified` event emitted
5. Click `certifiedManufacturers` with Account 2's address → returns `true`

### Action 4: Manufacture as a certified manufacturer

1. Switch to **Account 2** (now certified)
2. Call `manufacturePart(999, "Boeing 737 Landing Gear")`
3. ✅ Success → part is created!

### Action 5: Test uncertified account (should fail)

1. Switch to **Account 3** (NOT certified)
2. Try `manufacturePart(888, "Fake Part")`
3. ❌ **FAILS** with: "Not a certified manufacturer."
4. The uncertified account cannot create parts!

### Action 6: Revoke certification

1. Switch back to **Account 1** (authority)
2. Call `revokeManufacturer([Account 2 address])`
3. ✅ Success → `ManufacturerRevoked` event emitted
4. Switch to **Account 2**
5. Try `manufacturePart(888, "Another Part")`
6. ❌ **FAILS** — certification was revoked!

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | Code showing the new modifiers and functions | Proves enhancement implementation |
| 2 | Failed `manufacturePart` without certification | Proves the restriction works |
| 3 | Successful `certifyManufacturer` call + event | Proves authority can certify |
| 4 | Successful `manufacturePart` after certification | Proves certified flow works |
| 5 | Failed `manufacturePart` from uncertified Account 3 | Proves only certified can create |
| 6 | Successful `revokeManufacturer` + failed manufacture after revocation | Proves revocation works |

> 💡 **Tip:** Save as `step5-code.png`, `step5-fail-uncertified.png`, `step5-certify.png`, `step5-manufacture-certified.png`, `step5-uncertified-account3.png`, `step5-revoke.png`

---

## The new code explained

### Certified Manufacturers Mapping

```solidity
mapping(address => bool) public certifiedManufacturers;
```

Simple boolean registry: `true` = certified, `false` = not certified.

### The `onlyAuthority` Modifier

```solidity
modifier onlyAuthority() {
    require(msg.sender == regulatoryAuthority, "Not the authority.");
    _;
}
```

Only the deployer (FAA/EASA) can certify or revoke manufacturers.

### The `onlyCertified` Modifier

```solidity
modifier onlyCertified() {
    require(certifiedManufacturers[msg.sender], "Not a certified manufacturer.");
    _;
}
```

Checks if the caller's address is in the certified registry.

### Certify and Revoke Functions

```solidity
function certifyManufacturer(address _manufacturer) public onlyAuthority {
    require(_manufacturer != address(0), "Invalid address.");
    certifiedManufacturers[_manufacturer] = true;
    emit ManufacturerCertified(_manufacturer);
}

function revokeManufacturer(address _manufacturer) public onlyAuthority {
    certifiedManufacturers[_manufacturer] = false;
    emit ManufacturerRevoked(_manufacturer);
}
```

---

## Why this matters (for the report)

This enhancement addresses the **Decentralized Identifiers (DIDs)** topic from the lab's "Future Research" section. While a full DID system uses cryptographic proofs and off-chain verification, our approach demonstrates the core concept:

> **Only verified entities can perform critical actions on the blockchain.**

In the real world:
- The FAA would verify Boeing's identity off-chain (documents, audits)
- Then call `certifyManufacturer(boeing_address)` on-chain
- Now Boeing's address is publicly verifiable as a legitimate manufacturer

---

## Key takeaways
- ✅ **Manufacturer registry** = simplified DID system
- ✅ **onlyAuthority** = only the regulator controls certifications
- ✅ **onlyCertified** = only approved entities can create parts
- ✅ **Revocation** = certifications can be removed (unlike real DIDs which are harder to revoke)
- ✅ This goes **beyond the basic lab** and shows initiative

## Common mistakes
| Mistake | Why it's wrong |
|---------|---------------|
| Letting anyone certify themselves | Defeats the purpose of access control |
| Forgetting to certify before manufacturing | Even the authority needs certification to manufacture |
| Not testing revocation | Must prove the system can remove bad actors |
