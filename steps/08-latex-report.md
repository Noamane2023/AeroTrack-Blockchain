# Step 8: Compiling the LaTeX Report

## What you'll learn
- How to compile the report with MiKTeX
- How to add your personal info
- How to fix common compilation errors
- What to include in the final PDF

---

## What to do (Actions)

### Action 1: Edit your personal info

Open `report/report.tex` and find these lines (around line 95-98):

```latex
{\large\bfseries Student:} [YOUR NAME HERE]\\[0.3cm]
{\large\bfseries Student ID:} [YOUR ID HERE]\\[0.3cm]
```

Replace with your actual name and student ID.

### Action 2: Compile the report

Open a terminal in the `report/` folder and run:

```bash
cd "C:\Users\Noaman\Desktop\Ensem\second year\S4\BlockchainTools\FInal lab\report"
pdflatex report.tex
pdflatex report.tex
```

**Why twice?** First pass generates table of contents data. Second pass inserts it.

### Action 3: Verify the PDF

1. Open `report.pdf`
2. Check:
   - Title page shows your name ✅
   - Table of contents has correct page numbers ✅
   - Code listings are syntax-highlighted ✅
   - All sections are present (Introduction → Conclusion) ✅

### Action 4: (Optional) Add screenshots to the report

If you want to include Remix screenshots in the report, add this in the Testing section:

```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=0.8\textwidth]{../screenshots/step6-hack-fail.png}
    \caption{Access control test: unauthorized transfer attempt fails}
\end{figure}
```

Then recompile (twice).

---

## Screenshots to take 📸

| # | What to screenshot | Why |
|---|-------------------|-----|
| 1 | Terminal showing successful `pdflatex` compilation (no errors) | Proves you compiled it yourself |
| 2 | The PDF title page (showing your name) | Proves it's your report |
| 3 | The table of contents page | Shows report structure |

> 💡 **Tip:** Save as `step8-compile-terminal.png`, `step8-title-page.png`, `step8-toc.png`

---

## Common errors and fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `Undefined control sequence` | Typo in a command or missing package | Check spelling, add `\usepackage{...}` |
| `Missing $ inserted` | Math symbol outside math mode | Wrap with `$...$` |
| `File not found` | Wrong path to an image | Check the filename and path |
| `Too many }'s` | Unmatched braces | Count your `{` and `}` |
| Package not found | MiKTeX needs to download it | Click "Install" when prompted |

## Output files

After successful compilation:
- `report.pdf` ← **This is what you submit** ✅
- `report.aux` ← Temporary (don't submit)
- `report.log` ← Temporary (don't submit)
- `report.toc` ← Temporary (don't submit)
- `report.out` ← Temporary (don't submit)

---

## Key takeaways
- ✅ Always compile **twice** for table of contents
- ✅ MiKTeX auto-installs missing packages
- ✅ Only submit the `.tex` source and `.pdf` output
- ✅ The `.gitignore` already excludes temp files
