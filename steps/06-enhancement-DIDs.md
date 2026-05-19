# Step 6: Enhancement — Decentralized Identifiers (DIDs)

## What you'll learn
- What a Decentralized Identifier (DID) is
- How to store manufacturer identity on-chain (name, country, certification ID)
- How to verify a manufacturer's identity before trusting their parts
- The difference between "address certified" (Step 5) and "identity proven" (this step)

## Real-world analogy

> In Step 5, we said "this address is approved." But that's like giving someone a badge without checking their passport. **DIDs go further** — they attach a verified identity to the address.
>
> Think of it like this: Step 5 = "you have a badge." Step 6 = "your badge says Boeing, serial #FAA-2024-001, registered in USA." Now anyone can look at the blockchain and verify WHO is behind the address.

---

## What's the difference from Step 5?

| Step 5 (Certification) | Step 6 (DIDs) |
|------------------------|---------------|
| `certifiedManufacturers[addr] = true` | Stores full identity: name, country, cert ID |
| Binary: certified or not | Rich data: who they are |
| Authority says "approved" | Authority says "this is Boeing, USA, FAA-2024-001" |
| Can't verify WHO they are | Anyone can read their identity on-chain |

---

## What's new in this step

| Addition | Purpose |
|----------|---------|
| `ManufacturerIdentity` struct | Stores name, country, certification number |
| `manufacturerIdentities` mapping | Links address → identity data |
| `registerManufacturer()` function | Authority registers full identity |
| `updateManufacturer()` function | Authority can update identity info |
| `isManufacturerActive()` function | Public view to check status |
| `ManufacturerRegistered` event | Announces new identity registration |
| `ManufacturerUpdated` event | Announces identity update |

---

## What to do (Actions)

### Action 1: Deploy the DID-enhanced contract

1. In Remix, create a new file or paste `Step6_DIDs.sol`
2. **Compile** with version `0.8.19` (EVM: london) → green checkmark ✅
3. **Deploy** → Account 1 becomes the `regulatoryAuthority`

### Action 2: Register a manufacturer with full identity

1. Stay on **Account 1** (authority)
2. Call `registerManufacturer` with:
   - `_manufacturer`: [Account 2's address]
   - `_name`: `Boeing`
   - `_country`: `USA`
   - `_certificationId`: `FAA-2024-001`
3. ✅ Success → `ManufacturerRegistered` event emitted

### Action 3: Verify the identity on-chain

1. Click `manufacturerIdentities` with Account 2's address
2. You should see:
   - `name: Boeing`
   - `country: USA`
   - `certificationId: FAA-2024-001`
   - `isActive: true`
   - `registeredAt: [timestamp]`

### Action 4: Manufacture a part as Boeing

1. Switch to **Account 2** (Boeing)
2. Call `manufacturePart(999, "Boeing 737 Landing Gear")`
3. ✅ Success — the part is now linked to a verified manufacturer

### Action 5: Anyone can verify the manufacturer

1. Call `isManufacturerActive([Account 2 address])` → returns `true`
2. Call `manufacturerIdentities([Account 2 address])` → shows full identity
3. This is the DID concept: **public, verifiable, on-chain identity**

### Action 6: Test unauthorized registration (should fail)

1. Switch to **Account 3**
2. Try `registerManufacturer([any address], "Fake Corp", "XX", "FAKE-001")`
3. ❌ **FAILS** with: "Not the authority."

### Action 7: Update manufacturer info

1. Switch back to **Account 1** (authority)
2. Call `updateManufacturer([Account 2 address], "Boeing Commercial", "USA", "FAA-2024-002")`
3. ✅ Success → identity updated, `ManufacturerUpdated` event emitted

### Action 8: Deactivate a manufacturer

1. Stay on **Account 1**
2. Call `deactivateManufacturer([Account 2 address])`
3. Switch to **Account 2** → try `manufacturePart(888, "Test")` → ❌ FAILS

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | Code showing the ManufacturerIdentity struct and functions | Proves DID implementation |
| 2 | `registerManufacturer` success + event | Proves identity registration |
| 3 | `manufacturerIdentities` query showing full identity data | Proves on-chain identity storage |
| 4 | Successful `manufacturePart` by registered manufacturer | Proves the flow works |
| 5 | Failed `registerManufacturer` from non-authority | Proves only authority can register |
| 6 | `deactivateManufacturer` + failed manufacture after | Proves deactivation works |

> 💡 **Tip:** Save as `step6-code.png`, `step6-register.png`, `step6-identity-query.png`, `step6-manufacture-success.png`, `step6-unauthorized-register.png`, `step6-deactivate.png`

---

## The code explained

### ManufacturerIdentity Struct

```solidity
struct ManufacturerIdentity {
    string name;              // "Boeing", "Airbus"
    string country;           // "USA", "France"
    string certificationId;   // "FAA-2024-001"
    bool isActive;            // Can they currently manufacture?
    uint256 registeredAt;     // Timestamp of registration
}
```

This is the **on-chain identity** — anyone can read it and verify who is behind an address.

### Register Function

```solidity
function registerManufacturer(
    address _manufacturer,
    string memory _name,
    string memory _country,
    string memory _certificationId
) public onlyAuthority {
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
```

**Key insight:** This function does TWO things:
1. Stores the full identity (DID)
2. Also certifies them (sets `certifiedManufacturers[addr] = true`)

So the `onlyCertified` modifier from Step 5 still works!

---

## Why this matters (for the report)

This directly answers the lab's research question:

> "How can we cryptographically prove that the Manufacturer address actually belongs to Boeing or Airbus?"

**Answer:** The regulatory authority (FAA) registers the manufacturer's identity on-chain. Since:
1. Only the authority can call `registerManufacturer` (access control)
2. The identity data is stored immutably on the blockchain (transparency)
3. Anyone can query `manufacturerIdentities[address]` to verify (public verification)

We achieve **cryptographic proof of identity** without needing off-chain infrastructure.

---

## Key takeaways
- ✅ **DID** = attaching a verifiable identity to a blockchain address
- ✅ Goes beyond simple boolean certification (Step 5)
- ✅ Anyone can verify WHO is behind an address
- ✅ Authority controls registration (like FAA approving Boeing)
- ✅ Includes activation/deactivation for lifecycle management

## Common mistakes
| Mistake | Why it's wrong |
|---------|---------------|
| Letting manufacturers register themselves | No trust — anyone could claim to be Boeing |
| Not storing timestamp | Can't prove WHEN they were certified |
| Forgetting `isActive` flag | Can't deactivate without deleting data |
