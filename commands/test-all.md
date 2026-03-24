Run the full quality gate for the current project.

First, **read CLAUDE.md** to find the project's test, lint, and import-check commands.

If CLAUDE.md specifies commands, use those. Otherwise, detect the project type and use defaults:

**Python projects** (has `pyproject.toml` or `setup.py`):
1. **Tests:** `python -m pytest tests/ -v`
2. **Lint:** `ruff check .`
3. **Import check:** Try importing the main module to verify no broken imports

**Unity projects** (has `Assets/` + `ProjectSettings/`):
1. **Compile check:** `Unity -batchmode -nographics -quit -projectPath "." -logFile /dev/stdout 2>&1`
2. **EditMode tests:** `Unity -runTests -batchmode -nographics -projectPath "." -testPlatform EditMode -testResults editmode-results.xml -logFile /dev/stdout 2>&1`
3. **Meta file check:** Find missing or orphaned .meta files under Assets/

**Web projects** (has `package.json`):
1. **Tests:** `npm test` (or the script defined in package.json)
2. **Lint:** `npm run lint` (if defined)
3. **Build check:** `npm run build` (if defined)

Report results clearly:
- Each step: PASS or FAIL with specific errors quoted
- Overall: green (all pass) or red (any failure)

If anything fails, diagnose the root cause and either fix it (if within your scope) or report it in your status.
