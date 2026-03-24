---
name: unity-verify
description: Run full Unity project verification — compile, test, analyze, meta check
---

Run the following verification sequence on the current Unity project:

1. **Read Unity version** from `ProjectSettings/ProjectVersion.txt`
2. **Compile check:**
   ```bash
   Unity -batchmode -nographics -quit -projectPath "." -logFile /dev/stdout 2>&1
   ```
   Parse output for: `compilationhadfailure`, `error CS`, `Scripts have compiler errors`

3. **Run EditMode tests:**
   ```bash
   Unity -runTests -batchmode -nographics -projectPath "." -testPlatform EditMode -testResults editmode-results.xml -logFile /dev/stdout 2>&1
   ```
   Parse results.xml for `<test-case result="Failed">`

4. **Meta file check:**
   ```bash
   # Find .cs files without matching .meta
   find Assets/ -name "*.cs" | while read f; do
     [ ! -f "$f.meta" ] && echo "MISSING META: $f"
   done
   # Find orphaned .meta files
   find Assets/ -name "*.cs.meta" | while read f; do
     [ ! -f "${f%.meta}" ] && echo "ORPHANED META: $f"
   done
   ```

5. **Report results** — pass/fail for each step, with specific errors quoted.
