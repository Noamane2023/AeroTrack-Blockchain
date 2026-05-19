# Step 6: Testing in Remix IDE (Full Scenario)

## What you'll learn
- How to simulate a complete supply chain scenario
- How to test access control (hacking attempt)
- How to read events in the transaction logs
- How to document your test results

---

## What to do (Actions)

### Action 1: Fresh deployment

1. Make sure your complete contract from Step 5 is compiled ✅
2. Delete any old deployed contracts (trash icon)
3. **Deploy** a fresh instance
4. Note: **Account 1** (the deployer) = Manufacturer/Authority

### Action 2: Manufacture a part

1. Select **Account 1** in the Account dropdown
2. In `manufacturePart`, enter:
   - `_serialNumber`: `999`
   - `_partName`: `"Boeing 737 Landing Gear"`
3. Click **transact** (orange button)
4. ✅ Terminal shows green checkmark
5. Expand the transaction → see `PartManufactured` event in logs

### Action 3: Verify the part data

1. Click the blue **parts** button
2. Enter `999`
3. Verify the returned data:
   - `serialNumber: 999`
   - `partName: Boeing 737 Landing Gear`
   - `manufacturer: [Account 1 address]`
   - `currentOwner: [Account 1 address]`
   - `status: 0` (Manufactured)
   - `exists: true`

### Action 4: Hacking attempt (MUST FAIL)

1. Switch to **Account 3** in the Account dropdown (the "hacker")
2. In `transferPart`, enter:
   - `_serialNumber`: `999`
   - `_newOwner`: [Account 3's own address]
3. Click **transact**
4. ❌ Transaction **FAILS** — terminal shows red error: `"Not the owner."`
5. This proves the modifier works!

### Action 5: Legitimate transfer

1. Switch back to **Account 1** (the manufacturer/owner)
2. Copy **Account 2's address** from the dropdown
3. In `transferPart`, enter:
   - `_serialNumber`: `999`
   - `_newOwner`: [Account 2's address]
4. Click **transact**
5. ✅ Success — expand to see `OwnershipTransferred` event

### Action 6: Log maintenance

1. Switch to **Account 2** (the airline, now the owner)
2. In `logMaintenance`, enter:
   - `_serialNumber`: `999`
   - `_report`: `"10,000 hour inspection passed. No fatigue detected."`
3. Click **transact**
4. ✅ Success — expand to see `MaintenanceLogged` event

### Action 7: Verify final state

1. Click **parts** with `999`
2. Verify:
   - `currentOwner`: Account 2's address ✅
   - `status: 2` (Installed) ✅

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | Fresh deployment (contract visible under "Deployed Contracts") | Clean starting point |
| 2 | `manufacturePart` success + expanded logs showing `PartManufactured` event | Proves manufacturing + event |
| 3 | `parts(999)` query result showing all fields | Proves data stored correctly |
| 4 | **Account 3 hacking attempt** — red error "Not the owner" in terminal | **KEY SCREENSHOT** — proves security |
| 5 | `transferPart` success from Account 1 + `OwnershipTransferred` event | Proves legitimate transfer |
| 6 | `logMaintenance` success from Account 2 + `MaintenanceLogged` event | Proves maintenance logging |
| 7 | Final `parts(999)` showing owner = Account 2, status = 2 (Installed) | Proves final state is correct |

> 💡 **Tip:** Save as `step6-deploy.png`, `step6-manufacture.png`, `step6-parts-query.png`, `step6-hack-fail.png`, `step6-transfer.png`, `step6-maintenance.png`, `step6-final-state.png`

> ⚠️ **The hack-fail screenshot is the most important one!** It proves your access control works. The professor will look for this.

---

## Summary of test results

| # | Test | Expected | Actual |
|---|------|----------|--------|
| 1 | Manufacture part (serial 999) | Success + event | ✅ |
| 2 | Read part data | Correct struct values | ✅ |
| 3 | Unauthorized transfer (Account 3) | Revert "Not the owner" | ✅ |
| 4 | Legitimate transfer (Account 1 → 2) | Success + event | ✅ |
| 5 | Log maintenance (Account 2) | Success + event | ✅ |
| 6 | Final state check | Owner = Account 2, Status = Installed | ✅ |

---

## Key takeaways
- ✅ Remix VM gives you free test accounts — no real ETH needed
- ✅ Green checkmark = success, red error = revert
- ✅ Events appear in the transaction logs (expand the tx in terminal)
- ✅ Always test the "unhappy path" (hacking attempts) not just the happy path
