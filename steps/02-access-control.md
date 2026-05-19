# Step 2: Role-Based Access Control (Modifiers)

## What you'll learn
- What a `modifier` is and why it exists
- How `require()` enforces rules
- How to implement role-based security
- The meaning of `_;` (the underscore placeholder)

## Real-world analogy

> Imagine a **security checkpoint** at an airport. Before you board the plane (execute the function), a guard checks your boarding pass (modifier). If your pass is invalid, you're turned away (transaction reverts). The guard doesn't care what you do on the plane — they only check if you're allowed in.

---

## What to do (Actions)

### Action 1: Add modifiers to your contract

In Remix, open your `AeroTrack.sol` file. Add the following code **after the constructor** (before the closing `}` of the contract):

```solidity
    // --- MODIFIERS ---

    // Check: does this part exist in the registry?
    modifier partExists(uint256 _serialNumber) {
        require(parts[_serialNumber].exists == true, "Part does not exist.");
        _;
    }

    // Check: is the caller the current owner of this part?
    modifier onlyPartOwner(uint256 _serialNumber) {
        require(parts[_serialNumber].currentOwner == msg.sender, "Not the owner.");
        _;
    }
```

### Action 2: Recompile

1. Go to **Solidity Compiler** tab
2. Click **Compile AeroTrack.sol**
3. Verify: green checkmark ✅ (no errors)

### Action 3: Redeploy

1. Go to **Deploy & Run** tab
2. Click **Deploy** (a new instance appears)
3. The contract now has modifiers ready — but they won't do anything visible yet (they activate when we add functions in Step 3)

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | The code showing both modifiers in the editor | Proves you added the access control |
| 2 | Successful compilation after adding modifiers | Proves the syntax is correct |

> 💡 **Tip:** Save as `step2-modifiers-code.png`, `step2-compile.png`

---

## Why access control matters

Without access control, **anyone** could:
- Register fake parts as a "manufacturer"
- Transfer parts they don't own
- Corrupt the entire supply chain

In aviation, this could literally cost lives.

## Modifier 1: `partExists`

```solidity
modifier partExists(uint256 _serialNumber) {
    require(parts[_serialNumber].exists == true, "Part does not exist.");
    _;
}
```

**What it does:** Before running the function, check that the part was actually registered. If not, revert with an error message.

**The `_;` symbol:** This is where the actual function code gets inserted. Think of it as "OK, checks passed, now run the real code."

## Modifier 2: `onlyPartOwner`

```solidity
modifier onlyPartOwner(uint256 _serialNumber) {
    require(parts[_serialNumber].currentOwner == msg.sender, "Not the owner.");
    _;
}
```

**What it does:** Only the current owner of a specific part can call this function. If Airline A owns the part, Airline B cannot transfer it.

## How modifiers attach to functions (preview of Step 3)

```solidity
function transferPart(uint256 _serialNumber, address _newOwner)
    public
    partExists(_serialNumber)      // Check 1: part is real
    onlyPartOwner(_serialNumber)   // Check 2: caller owns it
{
    // ... actual logic here
}
```

**Execution order:**
1. `partExists` runs → checks if part exists
2. `onlyPartOwner` runs → checks if caller is the owner
3. If both pass → function body executes
4. If any fails → transaction reverts, no gas wasted on logic

---

## Key takeaways
- ✅ **Modifiers** = reusable security checks that run before a function
- ✅ **require()** = "if this condition is false, cancel everything"
- ✅ **`_;`** = placeholder for "insert the function body here"
- ✅ You can stack multiple modifiers on one function

## Common mistakes
| Mistake | Why it's wrong |
|---------|---------------|
| Putting access checks inside the function body | Less reusable, harder to audit |
| Forgetting `_;` in a modifier | The function body never executes! |
| Using `==` with strings for comparison | Strings can't be compared with `==` in Solidity |
