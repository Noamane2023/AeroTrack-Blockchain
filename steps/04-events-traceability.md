# Step 4: Events & Traceability

## What you'll learn
- What events are and why they're cheaper than storage
- How `indexed` parameters enable filtering
- How to log maintenance without expensive storage
- The difference between on-chain storage and transaction logs

## Real-world analogy

> Think of **events** like a public announcement board at an airport. When a flight lands, the board updates. Everyone can see it, but the board doesn't store the full passenger list — it just announces what happened. Similarly, events announce actions on the blockchain without storing data in expensive contract storage.

---

## What to do (Actions)

### Action 1: Add event declarations

In Remix, add these **after your state variables** (after the `mapping` line, before the `constructor`):

```solidity
    // --- EVENTS ---
    event PartManufactured(uint256 indexed serialNumber, string partName, address manufacturer);
    event OwnershipTransferred(uint256 indexed serialNumber, address oldOwner, address newOwner);
    event MaintenanceLogged(uint256 indexed serialNumber, address mechanic, string report);
```

### Action 2: Add `emit` to `manufacturePart`

At the end of your `manufacturePart` function (before the closing `}`), add:

```solidity
        emit PartManufactured(_serialNumber, _partName, msg.sender);
```

### Action 3: Update `transferPart` to emit event

Replace your `transferPart` function body with:

```solidity
    function transferPart(uint256 _serialNumber, address _newOwner)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        require(_newOwner != address(0), "Invalid address.");

        address oldOwner = parts[_serialNumber].currentOwner;
        parts[_serialNumber].currentOwner = _newOwner;
        parts[_serialNumber].status = PartStatus.InTransit;

        emit OwnershipTransferred(_serialNumber, oldOwner, _newOwner);
    }
```

### Action 4: Add the `logMaintenance` function

Add this new function after `transferPart`:

```solidity
    // Log a maintenance report (gas-efficient via events)
    function logMaintenance(uint256 _serialNumber, string memory _report)
        public
        partExists(_serialNumber)
        onlyPartOwner(_serialNumber)
    {
        emit MaintenanceLogged(_serialNumber, msg.sender, _report);
        parts[_serialNumber].status = PartStatus.Installed;
    }
```

### Action 5: Compile and Deploy

1. **Compile** → green checkmark ✅
2. **Deploy** → fresh contract instance

### Action 6: Test the full flow with events

1. **Account 1** → `manufacturePart(999, "Turbine Blade")`
2. Expand the transaction in the terminal → you should see **logs** with `PartManufactured` event
3. **Account 1** → `transferPart(999, [Account 2 address])`
4. Expand the transaction → see `OwnershipTransferred` event with old and new owner
5. Switch to **Account 2** → `logMaintenance(999, "10,000 hour inspection passed.")`
6. Expand the transaction → see `MaintenanceLogged` event with the report text

### Action 7: Read the event logs

1. In the terminal (bottom of Remix), click on any green transaction
2. Click the **arrow** to expand it
3. Look for the **logs** section — it shows the event name and parameters
4. Notice the `serialNumber` is listed as a **topic** (because it's `indexed`)

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | Code showing event declarations + logMaintenance function | Proves implementation |
| 2 | Successful compilation | No errors with events |
| 3 | `manufacturePart` transaction expanded → showing `PartManufactured` event in logs | Proves events emit correctly |
| 4 | `transferPart` transaction expanded → showing `OwnershipTransferred` event | Proves transfer event works |
| 5 | `logMaintenance` transaction expanded → showing `MaintenanceLogged` event with report text | Proves maintenance logging works |
| 6 | The `parts(999)` query showing `status: 2` (Installed) after maintenance | Proves status updated |

> 💡 **Tip:** Save as `step4-events-code.png`, `step4-compile.png`, `step4-manufacture-event.png`, `step4-transfer-event.png`, `step4-maintenance-event.png`, `step4-final-state.png`

---

## Why events instead of arrays?

| Approach | Gas cost | Accessible by contract? | Accessible by frontend? |
|----------|----------|------------------------|------------------------|
| Store in array | Very expensive 💰💰💰 | ✅ Yes | ✅ Yes |
| Emit event | Very cheap 💰 | ❌ No | ✅ Yes |

**Key insight:** If you only need the history for display purposes (dashboards, audits), events are 10-100x cheaper than storage.

## The `indexed` keyword

Makes the parameter searchable. A frontend app can say "show me all events for serial number 999" without scanning every transaction.

---

## Key takeaways
- ✅ **Events** = cheap announcements written to transaction logs
- ✅ **indexed** = makes parameters searchable/filterable
- ✅ **emit** = the keyword to fire an event
- ✅ Use events for history/audit trails, storage for current state only

## Common mistakes
| Mistake | Why it's wrong |
|---------|---------------|
| Storing maintenance history in an array | Extremely expensive gas costs |
| Forgetting `indexed` on serial number | Can't filter events efficiently |
| Trying to read events from another contract | Events are NOT accessible on-chain |
