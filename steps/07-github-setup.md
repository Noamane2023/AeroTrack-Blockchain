# Step 7: GitHub Repository Setup

## What you'll learn
- How to create a public GitHub repository
- How to push your project code
- How to structure the repo for the professor

---

## What to do (Actions)

### Action 1: Create the repo on GitHub

1. Go to [github.com/new](https://github.com/new)
2. Fill in:
   - **Repository name**: `AeroTrack-Blockchain-Lab`
   - **Description**: `Ethereum smart contract for airplane spare parts provenance tracking - ENSEM S4 Blockchain Lab`
   - **Visibility**: ⚠️ **Public** (required!)
   - Check ✅ "Add a README file"
3. Click **Create repository**

### Action 2: Clone the repo to your computer

Open a terminal (PowerShell or CMD) and run:

```bash
cd C:\Users\Noaman\Desktop\Ensem\second year\S4\BlockchainTools\FInal lab
git clone https://github.com/YOUR_USERNAME/AeroTrack-Blockchain-Lab.git
```

### Action 3: Copy your project files into the repo

Copy these folders/files into the cloned repo:
```
AeroTrack-Blockchain-Lab/
├── contracts/
│   └── AeroTrack.sol
├── report/
│   ├── report.tex
│   └── report.pdf
├── screenshots/
│   ├── step1-*.png
│   ├── step2-*.png
│   ├── ...
│   └── step6-*.png
└── .gitignore
```

### Action 4: Create a proper README.md

Replace the default README with a proper one (I'll create this for you — see below).

### Action 5: Commit and push

```bash
cd AeroTrack-Blockchain-Lab
git add .
git commit -m "feat: add AeroTrack smart contract + LaTeX report"
git push origin main
```

### Action 6: Verify on GitHub

1. Go to your repo URL: `https://github.com/YOUR_USERNAME/AeroTrack-Blockchain-Lab`
2. Check that all files are visible
3. Check that the README renders nicely

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | GitHub repo creation page (filled in, before clicking Create) | Shows you created it |
| 2 | The repo page on GitHub after pushing (showing file list + README) | Proves code is public and accessible |
| 3 | Terminal showing successful `git push` output | Proves you pushed the code |

> 💡 **Tip:** Save as `step7-create-repo.png`, `step7-repo-page.png`, `step7-git-push.png`

---

## README.md template

Use this for your repo:

```markdown
# ✈️ AeroTrack — Blockchain Spare Parts Provenance

Ethereum smart contract for securing airplane spare parts provenance using Solidity.

## About

AeroTrack is a decentralized application that tracks the lifecycle of airplane spare parts on the Ethereum blockchain. It ensures that every part's manufacturing, ownership transfers, and maintenance records are immutable and transparent.

## Features

- 🏭 **Part Registration** — Manufacturers register parts with unique serial numbers
- 🔄 **Ownership Transfer** — Secure transfer between manufacturers, airlines, and mechanics
- 🔒 **Access Control** — Only authorized owners can modify part data
- 📋 **Maintenance Logging** — Gas-efficient event-based maintenance records
- 🛡️ **Security** — Role-based modifiers prevent unauthorized access

## How to Deploy

1. Open [Remix IDE](https://remix.ethereum.org/)
2. Create a new file and paste `contracts/AeroTrack.sol`
3. Compile with Solidity 0.8.19
4. Deploy on Remix VM (Shanghai)
5. Test using the scenarios in the report

## Project Structure

```
├── contracts/
│   └── AeroTrack.sol      # Smart contract source code
├── report/
│   ├── report.tex         # LaTeX report source
│   └── report.pdf         # Compiled PDF report
└── screenshots/           # Remix IDE test screenshots
```

## Author

- **Name:** [YOUR NAME]
- **University:** ENSEM — Université Hassan II de Casablanca
- **Module:** Blockchain Tools & Applications (S4)
- **Year:** 2025/2026

## License

MIT
```

---

## Key takeaways
- ✅ Repo MUST be **public** (professor requirement)
- ✅ Include both source code AND compiled report
- ✅ A good README shows professionalism
- ✅ Commit messages should be descriptive (use `feat:`, `docs:`, etc.)
