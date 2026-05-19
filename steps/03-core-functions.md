# Step 3: Core Functions — Manufacturing & Transferring

## What you'll learn
- How to register a new part on the blockchain
- How to transfer ownership between entities
- How modifiers protect these functions automatically
- The zero-address check pattern

## Real-world analogy

> Think of **manufacturing a part** like issuing a birth certificate. The hospital (manufacturer) creates the document, and the baby (part) is officially registered in the system.
>
> Think of **transferring ownership** like selling a car. You sign the title over to the new owner, and the government (blockchain) records the change permanently.

---

## What to do (Actions)

### Action 1: Add the `manufacturePart` function

In Remix, add this code **after your modifiers** (before the closing `}` of the contract):

```solidity
    // --- CORE FUNCTIONS ---

    // Register a newly manufactured part
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
    }
```

### Action 2: Add the `transferPart` function

Right below `manufacturePart`, add:

```solidity
    // Transfer the part to a new owner (e.g., an Airline)
    function transferPart(uint256 _serialNumber, address _newOwner)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        require(_newOwner != address(0), "Invalid address.");

        parts[_serialNumber].currentOwner = _newOwner;
        parts[_serialNumber].status = PartStatus.InTransit;
    }
```

### Action 3: Compile and Deploy

1. **Compile** → green checkmark ✅
2. **Deploy** → new contract instance appears

### Action 4: Test `manufacturePart`

1. Make sure **Account 1** is selected (the default account)
2. In the deployed contract, find `manufacturePart`
3. Enter:
   - `_serialNumber`: `999`
   - `_partName`: `"Boeing 737 Landing Gear"`
4. Click **transact** (orange button)
5. Check terminal: green checkmark = success ✅

### Action 5: Verify the part was created

1. Find the blue **parts** button
2. Enter `999` and click it
3. You should see all the struct fields returned:
   - `serialNumber: 999`
   - `partName: Boeing 737 Landing Gear`
   - `manufacturer: [your address]`
   - `currentOwner: [your address]`
   - `status: 0` (= Manufactured)
   - `exists: true`

### Action 6: Test `transferPart`

1. Copy **Account 2's address** from the Account dropdown
2. In `transferPart`, enter:
   - `_serialNumber`: `999`
   - `_newOwner`: [paste Account 2's address]
3. Click **transact**
4. Check terminal: green checkmark ✅
5. Click **parts** with `999` again → `currentOwner` should now be Account 2

### Action 7: Test the security (hacking attempt!)

1. Switch to **Account 3** in the Account dropdown
2. Try `transferPart` with serial `999` and any address
3. Click **transact**
4. ❌ It should **FAIL** with error: "Not the owner."

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | Code showing both functions in the editor | Proves implementation |
| 2 | Successful compilation | No errors |
| 3 | `manufacturePart` transaction success (green check in terminal) | Proves manufacturing works |
| 4 | `parts(999)` result showing all struct fields | Proves data is stored correctly |
| 5 | `transferPart` success (green check) | Proves transfer works |
| 6 | `parts(999)` after transfer → new owner visible | Proves ownership changed |
| 7 | Failed transfer from Account 3 (red error in terminal showing "Not the owner") | Proves security works! |

> 💡 **Tip:** Save as `step3-code.png`, `step3-compile.png`, `step3-manufacture.png`, `step3-parts-query.png`, `step3-transfer.png`, `step3-after-transfer.png`, `step3-hack-fail.png`

---

## Line-by-line breakdown: `manufacturePart`

1. `require(... exists == false ...)` → Can't register the same serial number twice
2. `manufacturer: msg.sender` → Whoever calls this function is recorded as the maker
3. `currentOwner: msg.sender` → The manufacturer starts as the owner
4. `status: PartStatus.Manufactured` → Initial lifecycle state
5. `exists: true` → Now this serial number is "real" in the system

**Why no modifier?** Anyone can be a manufacturer. The only rule is: don't reuse serial numbers.

## Line-by-line breakdown: `transferPart`

1. `partExists` modifier → Part must be registered
2. `onlyPartOwner` modifier → Only the current owner can transfer
3. `address(0)` check → Prevents sending to a "black hole" address
4. Update `currentOwner` → New owner is recorded
5. Update `status` → Part is now "in transit"

**The aha moment:** Notice there's NO `require` for ownership inside the function body. The `onlyPartOwner` modifier handles it cleanly. This is modular, reusable security.

---

## Key takeaways
- ✅ `manufacturePart` = birth certificate for a part
- ✅ `transferPart` = title transfer with automatic security
- ✅ `address(0)` = the "null" address in Ethereum, must be blocked
- ✅ Modifiers keep function bodies clean and focused on logic

## Common mistakes
| Mistake | Why it's wrong |
|---------|---------------|
| Allowing duplicate serial numbers | Two parts with same ID = chaos |
| Not checking `address(0)` | Tokens sent to zero address are lost forever |
| Putting ownership check inside function | Duplicates logic, harder to maintain |
